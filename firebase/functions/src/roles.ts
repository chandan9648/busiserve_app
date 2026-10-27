import { getAuth } from "firebase-admin/auth";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { ENFORCE_APP_CHECK, REGION } from "./config";

const ROLES = ["customer", "staff", "admin"] as const;

/**
 * Admin-only. Sets the `role` custom claim that Firestore and Storage rules
 * check. The first admin is granted with scripts/grant-admin.ts using a
 * service account on a trusted machine, never from the app.
 */
export const setUserRole = onCall({ region: REGION, enforceAppCheck: ENFORCE_APP_CHECK }, async (request) => {
  if (request.auth?.token.role !== "admin") {
    throw new HttpsError("permission-denied", "You do not have access to this.");
  }
  const uid = typeof request.data?.uid === "string" ? request.data.uid : "";
  const role = request.data?.role;
  if (!uid || !(ROLES as readonly string[]).includes(role)) {
    throw new HttpsError("invalid-argument", "Provide a uid and a valid role.");
  }
  if (uid === request.auth.uid && role !== "admin") {
    throw new HttpsError("failed-precondition", "Admins cannot remove their own admin role.");
  }
  await getAuth().setCustomUserClaims(uid, role === "customer" ? {} : { role });
  // Force the user's existing tokens to refresh so the change applies quickly.
  await getAuth().revokeRefreshTokens(uid);
  return { uid, role };
});
