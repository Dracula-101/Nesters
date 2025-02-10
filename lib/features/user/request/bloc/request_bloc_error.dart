import 'package:nesters/data/repository/utils/app_exception.dart';

class RequestStreamError implements AppException {
  @override
  String message;

  RequestStreamError([this.message = "Error in Request Stream"]);
}

class GetUserRequestError implements AppException {
  @override
  String message;

  GetUserRequestError([this.message = "Error in getting user requests"]);
}

class RequestAlreadySentError implements AppException {
  @override
  String message;

  RequestAlreadySentError([this.message = "Request already sent"]);
}
