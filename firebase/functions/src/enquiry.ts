import { createHash } from "node:crypto";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { ENFORCE_APP_CHECK, REGION } from "./config";
import { validateEnquiry } from "./validation";

const MAX_PER_HOUR = 5;

/**
 * Creates an enquiry. Idempotent on `idempotencyKey`: the document id is the
 * key, so a retried call returns the original enquiry instead of a new one.
 * `customerId` comes from the verified auth token, never from the payload.
 */
export const createEnquiry = onCall(
  { region: REGION, enforceAppCheck: ENFORCE_APP_CHECK, maxInstances: 10 },
  async (request) => {
    const result = validateEnquiry(request.data);
    if (!result.ok) {
      throw new HttpsError("invalid-argument", "Some details are not valid. Check the form and try again.", {
        fields: result.fields,
      });
    }
    const input = result.value;
    const db = getFirestore();
    const ref = db.collection("enquiries").doc(input.idempotencyKey);
    const emailHash = createHash("sha256").update(input.email).digest("hex");
    const limitRef = db.collection("_rateLimits").doc(`enquiry_${emailHash}`);
    const uid = request.auth?.uid ?? null;

    const outcome = await db.runTransaction(async (tx) => {
      const [existing, limit] = await Promise.all([tx.get(ref), tx.get(limitRef)]);

      if (existing.exists) {
        const same = existing.get("emailHash") === emailHash;
        if (!same) throw new HttpsError("invalid-argument", "Invalid request id.");
        return { enquiryId: ref.id, duplicate: true };
      }

      const now = Date.now();
      const windowStart = (limit.get("windowStart") as number | undefined) ?? 0;
      const count = now - windowStart < 3_600_000 ? ((limit.get("count") as number | undefined) ?? 0) : 0;
      if (count >= MAX_PER_HOUR) {
        throw new HttpsError("resource-exhausted", "Too many enquiries. Try again later.");
      }

      tx.set(limitRef, {
        windowStart: count === 0 ? now : windowStart,
        count: count + 1,
      });
      tx.create(ref, {
        name: input.name,
        email: input.email,
        emailHash,
        phone: input.phone ?? null,
        company: input.company ?? null,
        subject: input.subject,
        message: input.message,
        source: input.source,
        customerId: uid,
        status: "received",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return { enquiryId: ref.id, duplicate: false };
    });

    logger.info("enquiry", { enquiryId: outcome.enquiryId, duplicate: outcome.duplicate, signedIn: uid !== null });
    return outcome;
  },
);
