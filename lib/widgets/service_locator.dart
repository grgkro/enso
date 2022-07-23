import 'package:ensobox/widgets/ble/bluetooth_service.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:get_it/get_it.dart';

import 'firebase_repository/auth_repo.dart';
import 'firebase_repository/storage_repo.dart';
import 'firestore_repository/database_repo.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<StorageRepo>(() => StorageRepo());
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo());
  getIt.registerLazySingleton<BluetoothService>(() => BluetoothService());
  getIt.registerLazySingleton<GlobalService>(() => GlobalService());
  getIt.registerLazySingleton<DatabaseRepo>(() => DatabaseRepo());
}
