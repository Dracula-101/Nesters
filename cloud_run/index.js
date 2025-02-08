//==================== Environment Configuration ==============================
const dotenv = require("dotenv").config();
const FIREBASE_DATABASE_URL = process.env.FIREBASE_DATABASE_URL;
const PORT = parseInt(process.env.PORT) || 8080;
//================ Firebase Admin SDK ================
// read the service account from the file
const fs = require("fs");
const serviceAccount = JSON.parse(atob(process.env.BASE64_SERVICE_ACCOUNT));
const firebaseAdmin = require("firebase-admin");
const { getFirestore } = require("firebase-admin/firestore");

//================ Express ================
const express = require("express");
const app = express();
const http = require("http");
const server = http.createServer(app);

//================ Socket.io ================
const { Server } = require("socket.io");
const io = new Server(server);

//====================== Database ============================
var database;
var userRef;
var userStatusRef;
var firestoreDb;
//====================== User Status ============================
const USER_OFFLINE = "Offline";
const USER_ONLINE = "Online";
const CONNECTION = "connection";
const DISCONNECT = "disconnect";
const UPDATE_USER_STATUS = "update";

function initializeApp() {
  try {
    firebaseAdmin.initializeApp({
      credential: firebaseAdmin.credential.cert(serviceAccount),
      databaseURL: FIREBASE_DATABASE_URL,
    });
    database = firebaseAdmin.database();
    firestoreDb = getFirestore();
    userRef = firestoreDb.collection("users");
    userStatusRef = database.ref("user_status");
    console.log("Firebase Admin SDK initialized successfully");
  } catch (error) {
    console.error("Firebase Admin SDK initialization failed", error.stack);
  }
}

function checkSocketConnection(socket) {
  const userId = socket.handshake.headers["userid"];
  if (!userId) {
    socket.disconnect();
    throw new Error("User id not found in the header");
  }
  console.log("Socket connected: ", socket.id);
  return userId;
}

async function getUser(userId) {
  const userInfoRef = userRef.doc(userId);
  const userInfo = await userInfoRef.get();
  if (!userInfo.exists) {
    socket.disconnect();
    throw new Error("User not found in the database");
  }
  const user = userInfo.data();
  console.log("User connected: ", user.fullName);
  return user;
}

async function updateUserStatus(userId, status) {
  await userStatusRef.child(userId).update(status);
}

//====================== Socket Connections ============================
async function onSocketDisconnection(socket) {
  const userId = checkSocketConnection(socket);
  await updateUserStatus(userId, {
    status: USER_OFFLINE,
    lastSeen: Date.now(),
  });
}

async function onUpdateUserStatus(userId, status) {
  const userStatus = status.user_status ? USER_ONLINE : USER_OFFLINE;
  await updateUserStatus(userId, {
    status: userStatus,
    lastSeen: Date.now(),
  });
}

async function onSocketConnection(socket) {
  const userId = checkSocketConnection(socket);
  const user = await getUser(userId);
  await updateUserStatus(userId, { status: USER_ONLINE });
  socket.on(
    UPDATE_USER_STATUS,
    async (status) => await onUpdateUserStatus(userId, status)
  );
  socket.on(DISCONNECT, async () => await onSocketDisconnection(socket));
}

function initializeServer() {
  try {
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
    io.on(CONNECTION, async (socket) => await onSocketConnection(socket));
  } catch (error) {
    console.error("Server initialization failed", error.stack);
  }
}

initializeApp();
initializeServer();
