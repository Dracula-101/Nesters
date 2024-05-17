const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document("chats/{chatId}")
  .onUpdate(async (change, context) => {
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
      .where("id", "in", [receiverId, senderId])
      .get();

    if (querySnapshot.empty) {
      return;
    }

    const receiverUser = querySnapshot.docs.filter((doc) => {
      return doc.data().id === receiverId;
    });
    const receiverFcmToken = receiverUser.token;

    const senderUser = querySnapshot.docs.filter((doc) => {
      return doc.data().id === senderId;
    });
    const senderName = senderUser.data().name;
    const senderPhotoURL = senderUser.data().photoUrl;

    const message = {
      token: receiverFcmToken,
      notification: {
        title: senderName,
        body: lastMessageContent,
      },
      data: { photoUrl: senderPhotoURL },
    };
    await admin.messaging().send(message);
  });
