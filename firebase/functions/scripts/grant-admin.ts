/**
 * One-off: grant the first admin. Run on a trusted machine only:
 *
 *   export GOOGLE_APPLICATION_CREDENTIALS=/secure/path/service-account.json
 *   npx ts-node scripts/grant-admin.ts user@example.com
 *
 * Never commit the service-account file or put it in the Flutter app.
 */
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

async function main() {
  const email = process.argv[2];
  if (!email) throw new Error("Usage: grant-admin.ts <email>");
  initializeApp({ credential: applicationDefault() });
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, { role: "admin" });
  console.log(`Granted admin to ${user.uid}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
