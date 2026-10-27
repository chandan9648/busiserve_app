# Cloud Functions — not deployed

This project runs on the Spark plan, so none of these functions are live. They are kept
intact because they are the better design: server-side validation, a real rate limit, and
roles in Auth custom claims where a client cannot reach them.

What replaced each one on Spark is listed in the root `README.md` under
**Firebase setup → Spark plan: no Cloud Functions**.

## Re-enabling them

1. Upgrade the project to Blaze and set a budget alert.
2. Put the `functions` block back in `../firebase.json`:

   ```json
   "functions": [
     {
       "source": "functions",
       "codebase": "default",
       "predeploy": ["npm --prefix \"$RESOURCE_DIR\" run build"]
     }
   ]
   ```

3. `npm install && npm run build && npm test`, then
   `firebase deploy --only functions`.
4. Move roles back to custom claims: run `scripts/grant-admin.ts` for the first admin, change
   `role()` in `../firestore.rules` and `isStaff()` in `../storage.rules` back to reading
   `request.auth.token.role`, and delete the `role` field from the `users` documents.
5. Point `FirebaseEnquiryDataSource.create` and `FirebasePrivacyDataSource.deleteAccount` back
   at the `createEnquiry` and `deleteAccount` callables, and tighten `enquiries` and
   `users/{uid}` in `../firestore.rules` so clients can no longer write them directly.

Until then, `npm test` here still exercises `validation.ts`, which documents the rules the
Firestore security rules now enforce.
