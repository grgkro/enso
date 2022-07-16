import 'package:ensobox/widgets/ble/bluetooth_service.dart';
import 'package:ensobox/widgets/id_scanner/user_details_service.dart';
import 'package:get_it/get_it.dart';

import 'auth/register_service.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<RegisterService>(() => RegisterService());
  getIt.registerLazySingleton<BluetoothService>(() => BluetoothService());
  getIt.registerLazySingleton<UserDetailsService>(() => UserDetailsService());
}
