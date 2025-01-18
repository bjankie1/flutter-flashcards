const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
admin.initializeApp();

exports.onUserUpdate = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const userId = context.params.userId;

    // Check if email has changed
    if (beforeData.email !== afterData.email) {
      const oldEmail = beforeData.email;
      const newEmail = afterData.email;

      const db = admin.firestore();

      // Hashing
      const oldHashedEmail = crypto
        .createHash("sha256")
        .update(oldEmail)
        .digest("hex");
      const newHashedEmail = crypto
        .createHash("sha256")
        .update(newEmail)
        .digest("hex");

      const batch = db.batch();

      // Remove old mapping
      batch.delete(db.collection("emailToUid").doc(oldHashedEmail));

      // Add new mapping
      batch.set(db.collection("emailToUid").doc(newHashedEmail), {
        uid: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await batch.commit();
      console.log(
        `Email mapping updated for user ${userId} from ${oldEmail} to ${newEmail}`
      );
    }
    return null;
  });
