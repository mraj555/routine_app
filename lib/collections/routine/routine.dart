import 'package:isar/isar.dart';
import 'package:routine_app/collections/category/category.dart';

part 'routine.g.dart';

@collection
class Routine {
  Id id = Isar.autoIncrement;

  late String title;

  @Index()
  late String startTime;

  @Index(caseSensitive: false)
  late String day;

  @Index(composite: [CompositeIndex('title')])
  final category = IsarLink<Category>();
}
