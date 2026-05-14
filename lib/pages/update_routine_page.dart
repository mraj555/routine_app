import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/category/category.dart';
import 'package:routine_app/collections/routine/routine.dart';

class UpdateRoutinePage extends StatefulWidget {
  final Isar isar;
  final Routine routine;
  const UpdateRoutinePage({
    super.key,
    required this.isar,
    required this.routine,
  });

  @override
  State<UpdateRoutinePage> createState() => _UpdateRoutinePageState();
}

class _UpdateRoutinePageState extends State<UpdateRoutinePage> {
  List<Category>? categories;
  Category? categoryValue;
  final TextEditingController _category = TextEditingController();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _startTime = TextEditingController();

  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String dayValue = 'Sunday';

  TimeOfDay? selectedTime = TimeOfDay.now();

  Future<void> _onSelectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime!,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        _startTime.text = selectedTime!.format(context);
      });
    }
  }

  Future<void> onAddCategory(Isar isar) async {
    final categories = isar.categorys;

    final newCategory = Category()..name = _category.text.trim();

    await isar.writeTxn(() async {
      await categories.put(newCategory);
    });

    _category.clear();
    readCategories();
  }

  Future<void> onUpdateRoutine(BuildContext context) async {
    final routine = widget.isar.routines;

    final newRoutine = widget.routine
      ..title = _title.text.trim()
      ..category.value = categoryValue
      ..day = dayValue
      ..startTime = _startTime.text.trim();

    await widget.isar.writeTxn(() async {

      await routine.put(newRoutine);

      await newRoutine.category.save();
    });

    _title.clear();
    _startTime.clear();
    setState(() {
      categoryValue = null;
      dayValue = 'Sunday';
    });

    Navigator.pop(context, true);
  }

  Future<void> readCategories() async {
    final _categories = widget.isar.categorys;
    final List<Category> allCategories = await _categories.where().findAll();

    setState(() {
      categories = allCategories;
    });

    _title.text = widget.routine.title;
    _startTime.text = widget.routine.startTime;
    dayValue = widget.routine.day;

    await widget.routine.category.load();
    int? getId = widget.routine.category.value?.id;
    setState(() {
      categoryValue = categories?[getId! - 1];
    });
  }

  @override
  void initState() {
    super.initState();
    readCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Update Routine')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Category
              Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: DropdownButton(
                      focusColor: Colors.white,
                      dropdownColor: Colors.white,
                      value: categoryValue,
                      icon: Icon(Icons.keyboard_arrow_down),
                      items: categories
                          ?.map<DropdownMenuItem<Category>>(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          categoryValue = value!;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) => AlertDialog(
                          title: Text("Add New Category"),
                          content: TextFormField(controller: _category),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                if (_category.text.trim().isNotEmpty) {
                                  onAddCategory(widget.isar);
                                }
                              },
                              child: Text('Add'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),

              /// Title
              SizedBox(height: 10),
              Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: _title),

              ///Start Time
              SizedBox(height: 10),
              Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      controller: _startTime,
                      enabled: false,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _onSelectTime(context),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
              ),

              /// Day
              SizedBox(height: 10),
              Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: DropdownButton(
                  focusColor: Colors.white,
                  dropdownColor: Colors.white,
                  value: dayValue,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: days
                      .map<DropdownMenuItem<String>>(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      dayValue = value!;
                    });
                  },
                  isExpanded: true,
                ),
              ),

              /// Add Button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => onUpdateRoutine(context),
                  child: Text('Update Routine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
