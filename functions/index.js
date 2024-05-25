const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.testNotification = functions.https.onRequest(async (req, res) => {
  try {
    let message;
    if (req.method === "GET") {
      return res.status(405).send("Method Not Allowed");
    } else if (req.method === "POST") {
      if (!req.body.chatId) {
        return res.status(400).send("Chat ID is required");
      }
      if (!req.body.senderId) {
        return res.status(400).send("Sender ID is required");
      }
      const senderData = await admin
        .firestore()
        .collection("users")
        .doc(req.body.senderId)
        .get();
      if (!senderData) {
        return res.status(400).send("Sender data not found");
      }
      const senderName = senderData.data().fullName;
      const senderPhotoUrl = senderData.data().photoUrl;
      const senderToken = senderData.data().token;
      if (!senderToken) {
        return res.status(400).send("Sender token not found");
      }

      message = {
        token: senderToken,
        notification: {
          title: req.body.title || "New Message",
          body: req.body.body || "You have a new message",
        },
        data: {
          photoUrl: req.body.photoUrl || "https://via.placeholder.com/150",
          notificationType: req.body.notificationType || "chat",
          chatId: req.body.chatId,
          senderName: senderName || "Unknown",
          senderId: req.body.senderId,
        },
      };
    }
    const notificationResponse = await admin.messaging().send(message);
    console.log("notificationResponse", notificationResponse);
    res.send("Notification sent successfully");
  } catch (e) {
    console.log(e);
    res.status(500).send({
      error: e,
      message: "An error occurred while sending notification",
    });
  }
});

exports.sendNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    try {
      const data = snapshot.data();
      const chatId = context.params.chatId;
      const lastMessageContent = data.content;
      const senderId = data.senderId;
      const participants = chatId.split("_");
      const receiverId =
        participants[0] == senderId ? participants[1] : participants[0];

      const querySnapshot = await admin
        .firestore()
        .collection("users")
        .where("userId", "in", [receiverId, senderId])
        .get();
      if (querySnapshot.empty) {
        return;
      }

      const receiverUser = querySnapshot.docs.find(
        (doc) => doc.data().userId === receiverId
      );

      const receiverFcmToken = receiverUser.data().token;
      const senderUser = querySnapshot.docs.find(
        (doc) => doc.data().userId === senderId
      );
      const senderName = senderUser.data().fullName;
      const senderPhotoUrl = senderUser.data().photoUrl;
      if (!receiverFcmToken || !senderName || !senderPhotoUrl) {
        return;
      }

      const message = {
        token: receiverFcmToken,
        notification: {
          title: senderName,
          body: lastMessageContent,
        },
        data: {
          photoUrl: senderPhotoUrl,
          notificationType: "chat",
          chatId: chatId,
          senderName: senderName,
          senderId: senderId,
        },
      };
      const notificationResponse = await admin.messaging().send(message);
      console.log("Notifcation sent successfully", notificationResponse);
    } catch (e) {
      console.error(e);
    }
  });
