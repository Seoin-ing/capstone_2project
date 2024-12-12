/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 댓글 추가 시 알림 전송 트리거
exports.sendNotificationOnComment = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentData = snapshot.data();

    const postRef = admin.firestore().collection("posts").doc(postId);
    const postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      const postOwner = postSnapshot.data().ownerId; // 게시글 소유자 ID

      // notifications 컬렉션에 알림 추가
      await admin
        .firestore()
        .collection("notifications")
        .add({
          message: `${commentData.userName}님이 새 댓글을 작성했습니다.`,
          postId: postId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          recipientId: postOwner, // 게시글 소유자에게만 알림
        });
    }
  });
