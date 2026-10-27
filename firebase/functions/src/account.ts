import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { ENFORCE_APP_CHECK, REGION } from "./config";

const RECENT_LOGIN_SECONDS = 5 * 60;

/**
 * Deletes the caller's account. Requires a sign-in within the last five
 * minutes (the app re-authenticates with the password first).
 *
 * Personal data is deleted. Business records that must be retained
 * (enquiries, quotations, projects, tickets) are kept but anonymised.
 */
export const deleteAccount = onCall(
  { region: REGION, enforceAppCheck: ENFORCE_APP_CHECK, timeoutSeconds: 120 },
  async (request) => {
    const auth = request.auth;
    if (!auth) throw new HttpsError("unauthenticated", "Sign in to continue.");
    const authTime = Number(auth.token.auth_time ?? 0);
    if (Date.now() / 1000 - authTime > RECENT_LOGIN_SECONDS) {
      throw new HttpsError("unauthenticated", "For your security, sign in again and retry.");
    }

    const uid = auth.uid;
    const db = getFirestore();
    const reason = typeof request.data?.reason === "string" ? request.data.reason.slice(0, 500) : null;

    // 1. Anonymise retained business records.
    const anonymise = async (collection: string, patch: Record<string, unknown>) => {
      const snap = await db.collection(collection).where("customerId", "==", uid).get();
      let batch = db.batch();
      let n = 0;
      for (const doc of snap.docs) {
        batch.update(doc.ref, { ...patch, customerId: null, anonymisedAt: FieldValue.serverTimestamp() });
        if (++n % 400 === 0) {
          await batch.commit();
          batch = db.batch();
        }
      }
      await batch.commit();
      return snap.size;
    };

    const counts = {
      enquiries: await anonymise("enquiries", { name: "Deleted user", email: null, phone: null, company: null }),
      quotations: await anonymise("quotations", {}),
      projects: await anonymise("projects", {}),
      tickets: await anonymise("tickets", {}),
    };

    // 2. Delete the profile and its subcollections (devices, notifications).
    await db.recursiveDelete(db.doc(`users/${uid}`));

    // 3. Minimal audit record without personal data.
    await db.collection("_deletionLog").add({ deletedAt: FieldValue.serverTimestamp(), reason, counts });

    // 4. Delete the Auth user last so a failure above can be retried.
    await getAuth().deleteUser(uid);

    logger.info("account deleted", { counts });
    return { deleted: true };
  },
);
