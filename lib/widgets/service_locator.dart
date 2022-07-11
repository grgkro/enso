import 'package:get_it/get_it.dart';

import 'auth/register_service.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<RegisterService>(() => RegisterService());
}
