import 'package:hive/hive.dart';

part 'profile.g.dart'; // Ensure this file is generated

@HiveType(typeId: 0)
class Profile extends HiveObject {
  @HiveField(11)
  String? name;

  @HiveField(1)
  String? bio;

  @HiveField(2)
  String? imagePath;

  Profile({this.name, this.bio, this.imagePath});
}
