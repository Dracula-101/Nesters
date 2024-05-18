const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.testNotification = functions.https.onRequest(async (req, res) => {
  try {
    let message;
    if (req.method === "GET") {
      return res.status(405).send("Method Not Allowed");
    } else if (req.method === "POST") {
      message = {
        token: req.body.token,
        notification: {
          title: req.body.title,
          body: req.body.body,
        },
        data: {
          photoUrl: req.body.photoUrl,
          notificationType: req.body.notificationType,
          chatId: req.body.chatId,
          senderName: req.body.senderName,
          senderId: req.body.senderId,
        },
      };
    }
    const notificationResponse = await admin.messaging().send(message);
    console.log("notificationResponse", notificationResponse);
    res.send("Notification sent successfully");
  } catch (e) {
    console.log(e);
    res.status(500).send("Error sending notification");
  }
});

exports.sendNotification = functions.firestore
  .document("chats/{chatId}")
  .onUpdate(async (change, context) => {
    try {
      const data = change.after.data();
      const previousData = change.before.data();
      const chatId = context.params.chatId;
      const lastMessage = data.messages[data.messages.length - 1];
      const lastMessageContent = lastMessage.content;
      const senderId = lastMessage.senderId;
      const participants = data.participants;
      const receiverId = participants.filter((id) => id !== senderId)[0];
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
      const senderName = senderUser.data().name;
      const senderPhotoUrl = senderUser.data().photoUrl;
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
      console.log("notificationResponse", notificationResponse);
    } catch (e) {
      console.log(e);
    }
  });
