import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nesters/utils/logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver();

  final AppLogger _appLogger = GetIt.I<AppLogger>();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _appLogger.debug(event);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _appLogger.error(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _appLogger.debug(transition);
  }
}
