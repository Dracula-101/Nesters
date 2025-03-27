import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/data/repository/user/error/user_profile_error.dart';
import 'package:nesters/data/repository/user/profile/user_chat_profile_repository.dart';
import 'package:nesters/data/repository/utils/app_exception.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/user/request/request.dart';
import 'package:nesters/domain/models/user/user.dart';
import 'package:http/http.dart' as http;

class FirebaseUserChatProfileRepository implements UserChatProfileRepository {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final String _userCollectionName = 'users';
  final String _userIdKey = 'userId';
  final String _acceptedRequestKey = 'isAccepted';
  final String _bannedRequestKey = 'isBanned';
  final String _sentRequestPath = 'sentRequests';
  final String _receivedRequestPath = 'receivedRequests';

  @override
  Future<QuickChatUser?> getUserNameAndProfile(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _store
          .collection(_userCollectionName)
          .where(_userIdKey, isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? user =
            querySnapshot.docs.first.data() as Map<String, dynamic>?;
        if (user == null) return null;
        return QuickChatUser.fromJson(user);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.GET_PROFILE_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Stream<List<Request>> getReceivedUserRequests(User currentUser) {
    try {
      return _store
          .collection(_userCollectionName)
          .doc(currentUser.id)
          .collection(_receivedRequestPath)
          .snapshots()
          .map((event) {
        List<Request> requests = [];
        List<Request> bannedRequests = [];
        for (var element in event.docs) {
          Map<String, dynamic> data = element.data();
          Request request = Request.fromReceiverRequest(data, currentUser);
          if (request.isBanned) {
            bannedRequests.add(request);
          } else {
            requests.add(request);
          }
        }
        requests.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        bannedRequests.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        requests.addAll(bannedRequests);
        return requests;
      });
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.GET_RECEIVED_REQ_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Stream<List<Request>> getSentUserRequests(User currentUser) {
    try {
      return _store
          .collection(_userCollectionName)
          .doc(currentUser.id)
          .collection(_sentRequestPath)
          .snapshots()
          .map((event) {
        List<Request> requests = [];
        List<Request> bannedRequests = [];
        for (var element in event.docs) {
          Map<String, dynamic> data = element.data();
          Request request = Request.fromSenderRequest(data, currentUser);
          if (request.isBanned) {
            bannedRequests.add(request);
          } else {
            requests.add(request);
          }
        }
        requests.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        bannedRequests.sort((a, b) => a.sentAt.compareTo(b.sentAt));
        requests.addAll(bannedRequests);
        return requests;
      });
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.GET_SENT_REQ_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Future<void> sendRequest(String currentUserId, String recipientUserId) async {
    try {
      List<QuickChatUser?> users = await Future.wait([
        getUserNameAndProfile(currentUserId),
        getUserNameAndProfile(recipientUserId)
      ]);
      if (users.contains(null)) {
        throw UserChatProfileErrorFactory.create(
          UserChatProfileErrorCode.SEND_REQ_ERR,
          'User no longer exists',
        );
      }
      Request data = Request.createReq(users[0]!, users[1]!);
      CollectionReference senderCollection = _store
          .collection(_userCollectionName)
          .doc(currentUserId)
          .collection(_sentRequestPath);
      CollectionReference receiverCollection = _store
          .collection(_userCollectionName)
          .doc(recipientUserId)
          .collection(_receivedRequestPath);
      await Future.wait([
        senderCollection.doc(recipientUserId).set(data.toReceiverMap()),
        receiverCollection.doc(currentUserId).set(data.toSenderMap())
      ]);
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on AppException {
      rethrow;
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Future<void> acceptRequest(String currentUserId, String recipientUserId) {
    try {
      CollectionReference senderCollection = _store
          .collection(_userCollectionName)
          .doc(currentUserId)
          .collection(_receivedRequestPath);
      CollectionReference receiverCollection = _store
          .collection(_userCollectionName)
          .doc(recipientUserId)
          .collection(_sentRequestPath);
      return Future.wait([
        senderCollection
            .doc(recipientUserId)
            .update({_acceptedRequestKey: true, _bannedRequestKey: false}),
        receiverCollection
            .doc(currentUserId)
            .update({_acceptedRequestKey: true, _bannedRequestKey: false})
      ]);
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.ACCEPT_REQ_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Future<void> rejectRequest(String senderUserId, String recipientUserId) {
    try {
      CollectionReference senderCollection = _store
          .collection(_userCollectionName)
          .doc(recipientUserId)
          .collection(_sentRequestPath);
      CollectionReference receiverCollection = _store
          .collection(_userCollectionName)
          .doc(senderUserId)
          .collection(_receivedRequestPath);
      return Future.wait([
        senderCollection
            .doc(senderUserId)
            .update({_acceptedRequestKey: false, _bannedRequestKey: true}),
        receiverCollection
            .doc(recipientUserId)
            .update({_acceptedRequestKey: false, _bannedRequestKey: true})
      ]);
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.REJECT_REQ_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Future<void> createChatRoom(String senderId, String receiverId) async {
    try {
      String firebaseUrl =
          _appSecretsRepository.getSecret(AppSecretsKeys.CLOUD_FUNCTION_URL);
      await http.post(
        Uri.parse('$firebaseUrl/sendAcceptNotification'),
        body: {
          'senderId': senderId,
          'receiverId': receiverId,
        },
      );
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.CREATE_CHAT_ROOM_ERR,
        'Unknown Error',
      );
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _store.collection(_userCollectionName).doc(userId).update({
        'isDeleted': true,
      });
    } on FirebaseException catch (e) {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.SEND_REQ_ERR,
        e.message ?? 'Database Error',
      );
    } on Exception {
      throw UserChatProfileErrorFactory.create(
        UserChatProfileErrorCode.DELETE_USER_ERR,
        'Unknown Error',
      );
    }
  }

  AppSecretsRepository get _appSecretsRepository =>
      GetIt.instance.get<AppSecretsRepository>();
}
