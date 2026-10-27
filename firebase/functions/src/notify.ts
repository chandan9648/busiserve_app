import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";

import { REGION } from "./config";

type NotificationType = "enquiry" | "quotation" | "project" | "support" | "general";

/** Writes an in-app notification and sends a push to the user's devices. */
async function notify(uid: string, type: NotificationType, title: string, body: string, route: string) {
  const db = getFirestore();
  await db.collection(`users/${uid}/notifications`).add({
    type, title, body, route, read: false, createdAt: FieldValue.serverTimestamp(),
  });

  const devices = await db.collection(`users/${uid}/devices`).get();
  const tokens = devices.docs.map((d) => d.id);
  if (tokens.length === 0) return;

  const res = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: { route, type },
    android: { priority: "high" },
  });

  // Remove tokens that are no longer valid.
  const stale = res.responses
    .map((r, i) => (!r.success && r.error?.code.includes("registration-token-not-registered") ? tokens[i] : null))
    .filter((t): t is string => t !== null);
  await Promise.all(stale.map((t) => db.doc(`users/${uid}/devices/${t}`).delete()));
  logger.info("notify", { type, sent: res.successCount, failed: res.failureCount, removed: stale.length });
}

export const onQuotationCreated = onDocumentCreated({ document: "quotations/{id}", region: REGION }, async (event) => {
  const data = event.data?.data();
  if (!data?.customerId) return;
  await notify(
    data.customerId,
    "quotation",
    "New quotation ready",
    `${data.title ?? "Your quotation"} is ready to review.`,
    `/quotations/${event.params.id}`,
  );
});

export const onProjectUpdated = onDocumentUpdated({ document: "projects/{id}", region: REGION }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!after?.customerId || !before) return;
  if (before.status === after.status && before.progress === after.progress) return;
  await notify(
    after.customerId,
    "project",
    "Project update",
    `${after.title ?? "Your project"} is now ${after.progress ?? 0}% complete.`,
    `/projects/${event.params.id}`,
  );
});

export const onTicketMessageCreated = onDocumentCreated(
  { document: "tickets/{ticketId}/messages/{messageId}", region: REGION },
  async (event) => {
    const msg = event.data?.data();
    if (msg?.authorRole !== "staff") return;
    const db = getFirestore();
    const ticketRef = db.doc(`tickets/${event.params.ticketId}`);
    const ticket = (await ticketRef.get()).data();
    if (!ticket?.customerId) return;
    await ticketRef.update({
      status: "awaiting_customer",
      lastMessage: String(msg.text ?? "").slice(0, 2000),
      updatedAt: FieldValue.serverTimestamp(),
    });
    await notify(
      ticket.customerId,
      "support",
      "New reply from Busiserve",
      String(ticket.subject ?? "Your support request"),
      `/tickets/${event.params.ticketId}`,
    );
  },
);
