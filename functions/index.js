const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.testNotification = functions.https.onRequest(async (req, res) => {
  try {
    const message = {
      token:
        "ds3gMe2hROmX7TpkTGjH_v:APA91bHqQX5ILjPRTXK7Dh3VTyKj1_8_6deFxxi54w7_3RncmS9sPI0Lzp1I9IJYLexZZS4geq35VpcuFSBQjv12Up2to8GHsjhtBNMpLXxOLnMOQzhAZ1RaW8uRWgVm5wtm8TkvlvMz",
      notification: {
        title: "Pratik Pujari",
        body: "Hello from Firebase!",
      },
      data: {
        photoUrl:
          "https://lh3.googleusercontent.com/a/ACg8ocIFK85rGX95I0Zz8G7BFOPw1D3XnMUYr-pejmpTlgqNSsZjOzLs=s96-c",
      },
    };
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
      const senderPhotoURL = senderUser.data().photoUrl;
      console.log(
        "Sending notification to",
        receiverId,
        "with token",
        receiverFcmToken,
        "from",
        senderId,
        "with name",
        senderName,
        "and photo",
        senderPhotoURL
      );
      const message = {
        token: receiverFcmToken,
        notification: {
          title: senderName,
          body: lastMessageContent,
        },
        data: { photoUrl: senderPhotoURL },
      };
      const notificationResponse = await admin.messaging().send(message);
      console.log("notificationResponse", notificationResponse);
    } catch (e) {
      console.log(e);
    }
  });
