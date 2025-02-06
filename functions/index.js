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
        apns: {
          headers: {
            "apns-priority": "5",
          },
          payload: {
            aps: {
              category: "NEW_MESSAGE_CATEGORY",
            },
          },
        },
        android: {
          collapse_key: chatId,
          priority: "high",
          notification: {
            channel_id: "nester_notification_channel",
            notification_priority: "PRIORITY_HIGH",
            default_sound: true,
            tag: chatId,
          },
        },
      };
      const notificationResponse = await admin.messaging().send(message);
      console.log("Notifcation sent successfully", notificationResponse);
    } catch (e) {
      console.error(e);
    }
  });

exports.sendRequestNotification = functions.firestore
  .document("users/{userId}/receivedRequests/{requestId}")
  .onCreate(async (snapshot, context) => {
    try {
      const data = snapshot.data();
      const senderId = context.params.requestId;
      const receiverId = context.params.userId;

      const userInfoPromise = [
        admin.firestore().collection("users").doc(senderId).get(),
        admin.firestore().collection("users").doc(receiverId).get(),
      ];

      const [senderData, receiverData] = await Promise.all(userInfoPromise);

      if (!senderData.exists || !receiverData.exists) {
        return;
      }

      const receiverUser = receiverData.data();
      const receiverName = receiverUser.fullName;
      const receiverPhotoUrl = receiverUser.photoUrl;
      const receiverFCMToken = receiverUser.token;

      const senderUser = senderData.data();

      if (!receiverFCMToken) {
        return;
      }
      if (!receiverName || !receiverPhotoUrl) {
        return;
      }

      const message = {
        token: receiverFCMToken,
        notification: {
          title: receiverName,
          body: "You have a new request",
        },
        data: {
          photoUrl: receiverPhotoUrl,
          notificationType: "request",
          time: Date.now().toString(),
        },
      };
      const notificationResponse = await admin.messaging().send(message);
      console.log("Notifcation sent successfully", notificationResponse);
    } catch (e) {
      console.error(e);
    }
  });

exports.sendAcceptNotification = functions.https.onRequest(async (req, res) => {
  try {
    let message;
    let chatId;
    if (req.method === "GET") {
      return res.status(405).send("Method Not Allowed");
    } else if (req.method === "POST") {
      if (!req.body.senderId) {
        return res.status(400).send("Sender ID is required");
      }
      if (!req.body.receiverId) {
        return res.status(400).send("Receiver ID is required");
      }
      const senderId = req.body.senderId;
      const receiverId = req.body.receiverId;
      const userInfoPromise = [
        admin.firestore().collection("users").doc(senderId).get(),
        admin.firestore().collection("users").doc(receiverId).get(),
      ];
      const [senderData, receiverData] = await Promise.all(userInfoPromise);

      chatId = [req.body.senderId, req.body.receiverId].sort().join("_");

      if (!senderData) {
        return res.status(400).send("Sender data not found");
      }
      const senderName = senderData.data().fullName;
      const senderPhotoUrl = senderData.data().photoUrl;
      const receiverToken = receiverData.data().token;
      if (!receiverToken) {
        return res.status(400).send("Sender token not found");
      }

      message = {
        token: receiverToken,
        notification: {
          title: "Request Accepted",
          body: "Your request has been accepted from " + senderName,
        },
        data: {
          photoUrl: req.body.photoUrl || "https://via.placeholder.com/150",
          notificationType: req.body.notificationType || "request",
          senderName: senderName || "Unknown",
          senderId: req.body.senderId,
        },
      };
    }
    console.log("notificationResponse", notificationResponse);
    // create a new chat document
    const chatCollection = admin.firestore().collection("chats");
    const chatData = {
      participants: [req.body.senderId, req.body.receiverId],
      createdAt: new Date().toISOString().replace("Z", ""),
      id: chatId,
    };
    await chatCollection.doc(chatId).set(chatData);
    const notificationResponse = await admin.messaging().send(message);
    res.send("Notification sent successfully");
  } catch (e) {
    console.log(e);
    res.status(500).send({
      error: e,
      message: "An error occurred while sending notification",
    });
  }
});
exports.testMessage = functions.https.onRequest(async (req, res) => {
  try {
    let message;
    if (req.method === "GET") {
      return res.status(405).send("Method Not Allowed");
    } else if (req.method === "POST") {
      if (!req.body.senderId) {
        return res.status(400).send("Sender ID is required");
      }
      if (!req.body.receiverId) {
        return res.status(400).send("Receiver ID is required");
      }
      const chatId = [req.body.senderId, req.body.receiverId].sort().join("_");
      const chatRef = admin
        .firestore()
        .collection("chats/" + chatId + "/messages");
      const messageData = {
        content: req.body.content ?? "Test message",
        epochTime: Date.now(),
        messageType: "TEXT",
        senderId: req.body.senderId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };
      const messageId = await chatRef.add(messageData);
      res.send("Message sent successfully with ID: " + messageId.id);
    }
  } catch (e) {
    console.log(e);
    res.status(500).send({
      error: e,
      message: "An error occurred while sending message",
    });
  }
});

exports.testRequest = functions.https.onRequest(async (req, res) => {
  try {
    let message;
    if (req.method === "GET") {
      return res.status(405).send("Method Not Allowed");
    } else if (req.method === "POST") {
      if (!req.body.senderId) {
        return res.status(400).send("Sender ID is required");
      }
      if (!req.body.receiverId) {
        return res.status(400).send("Receiver ID is required");
      }
      const makeDuplicate = req.body?.makeDuplicate ?? false;
      const userRef = admin.firestore().collection("users");
      const userPromises = [
        userRef.doc(req.body.senderId).get(),
        userRef.doc(req.body.receiverId).get(),
      ];
      const [senderData, receiverData] = await Promise.all(userPromises);
      if (!senderData.exists) {
        return res.status(400).send("Sender data not found");
      }
      if (!receiverData.exists) {
        return res.status(400).send("Receiver data not found");
      }
      // Sender data
      const senderName = senderData.data().fullName;
      const senderPhotoUrl = senderData.data().photoUrl;
      // Receiver data
      const receiverName = receiverData.data().fullName;
      const receiverPhotoUrl = receiverData.data().photoUrl;

      const senderRequestRef = admin
        .firestore()
        .collection("users")
        .doc(req.body.senderId)
        .collection("sentRequests");
      const receiverRequestRef = admin
        .firestore()
        .collection("users")
        .doc(req.body.receiverId)
        .collection("receivedRequests");
      const sentAtTime = Date.now();
      const senderRequestBody = {
        attempt: 0,
        info: {
          id: req.body.receiverId,
          name: receiverName,
          photoUrl: receiverPhotoUrl,
          type: "Sender",
        },
        isAccepted: false,
        isBanned: false,
        sentAt: sentAtTime,
      };
      const receiverRequestBody = {
        attempt: 0,
        info: {
          id: req.body.senderId,
          name: senderName,
          photoUrl: senderPhotoUrl,
          type: "Receiver",
        },
        isAccepted: false,
        isBanned: false,
        sentAt: sentAtTime,
      };
      const addRequestPromises = !makeDuplicate
        ? [
            senderRequestRef.doc(req.body.receiverId).set(senderRequestBody),
            receiverRequestRef.doc(req.body.senderId).set(receiverRequestBody),
          ]
        : [
            senderRequestRef.add(senderRequestBody),
            receiverRequestRef.add(receiverRequestBody),
          ];
      await Promise.all(addRequestPromises);
      res.send("Request sent successfully");
    }
  } catch (e) {
    console.log(e);
    res.status(500).send({
      error: e,
      message: "An error occurred while sending request",
    });
  }
});
