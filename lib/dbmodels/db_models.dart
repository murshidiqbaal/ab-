import 'package:hive/hive.dart';

part 'db_models.g.dart'; // Run `flutter packages pub run build_runner build` to generate this file

@HiveType(typeId: 2)
class Memory {
  @HiveField(10)
  String imagePath;

  Memory({required this.imagePath});
}
