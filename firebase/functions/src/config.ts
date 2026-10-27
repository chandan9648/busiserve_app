import { initializeApp, getApps } from "firebase-admin/app";

if (getApps().length === 0) initializeApp();

export const REGION = "asia-south1";

/**
 * App Check is enforced in staging and production. Set
 * ENFORCE_APP_CHECK=false in functions/.env.<project> for local development.
 */
export const ENFORCE_APP_CHECK = process.env.ENFORCE_APP_CHECK !== "false";
