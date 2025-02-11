import 'package:nesters/data/repository/config/app_secrets_repository.dart';
import 'package:nesters/domain/models/chat/home/chat_quick_user.dart';
import 'package:nesters/domain/models/user/request/request.dart';
import 'package:nesters/domain/models/user/user.dart';

abstract class UserChatProfileRepository {
  final AppSecretsRepository _appSecretsRepository;
  UserChatProfileRepository(
      {required AppSecretsRepository appSecretsRepository})
      : _appSecretsRepository = appSecretsRepository;

  Future<QuickChatUser?> getUserNameAndProfile(String userId);
  Stream<List<Request>> getSentUserRequests(User currentUser);
  Stream<List<Request>> getReceivedUserRequests(User currentUser);
  Future<void> sendRequest(String currentUserId, String recipientUserId);
  Future<void> acceptRequest(String currentUserId, String recipientUserId);
  Future<void> rejectRequest(String currentUserId, String recipientUserId);
  Future<void> createChatRoom(String senderId, String receiverId);
  Future<void> deleteUser(String userId);
}
