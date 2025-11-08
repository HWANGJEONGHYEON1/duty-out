import 'package:equatable/equatable.dart';

/// 에러 추상 클래스
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 인증 에러
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
