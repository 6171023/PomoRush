import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  //A function to store a different data in a string format
  static Future storeDataInSecureStorage(
      {required String key, required String data}) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: key, value: data);
  }

  static Future<String?> readDataFromSecureStorage(
      {required String key}) async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: key);
  }
}