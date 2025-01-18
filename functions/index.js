const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.updateEmailToUidMapping = onDocumentWritten(
  {
    document: "users/{userId}",
    region: "europe-central2",
  },
  async (event) => {
    console.log("User change triggered");
    const change = event.data;
    const context = event;
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
  }
);
