import 'package:isar/isar.dart';

@collection
class Category {
  int id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
}
