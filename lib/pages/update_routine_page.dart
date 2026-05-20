import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/category/category.dart';
import 'package:routine_app/collections/routine/routine.dart';
import 'package:routine_app/pages/main_page.dart';

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
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        title: const Text(
          'Update Routine',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) => AlertDialog(
                  backgroundColor: Color(0xFF1A1A2E),
                  title: Text("Delete Routine", style: TextStyle(color: Colors.white)),
                  content: Text(
                    "Are you sure you want to delete this routine?",
                    style: TextStyle(color: Color(0xFFB0B0C3)),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await widget.isar.writeTxn(() async {
                          await widget.isar.routines.delete(widget.routine.id);
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(isar: widget.isar),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete, color: Color(0xFFFF4757)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Category
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0C3),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF6C63FF), width: 1),
                      ),
                      child: DropdownButton(
                        dropdownColor: Color(0xFF1A1A2E),
                        value: categoryValue,
                        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFB0B0C3)),
                        items: categories
                            ?.map<DropdownMenuItem<Category>>(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text(e.name, style: TextStyle(color: Colors.white))),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            categoryValue = value!;
                          });
                        },
                        isExpanded: true,
                        underline: SizedBox(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 56,
                    width: 48,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF6C63FF), width: 1),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) => AlertDialog(
                            backgroundColor: Color(0xFF1A1A2E),
                            title: Text("Add New Category", style: TextStyle(color: Colors.white)),
                            content: TextFormField(
                              controller: _category,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFF0D0D0D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_category.text.trim().isNotEmpty) {
                                    onAddCategory(widget.isar);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Add'),
                              ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.add, color: Color(0xFF6C63FF)),
                    ),
                  ),
                ],
              ),

              /// Title
              SizedBox(height: 16),
              Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0C3),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _title,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF1A1A2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                  ),
                ),
              ),

              ///Start Time
              SizedBox(height: 16),
              Text(
                'Start Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0C3),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormField(
                      controller: _startTime,
                      enabled: false,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 1),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _onSelectTime(context),
                    icon: Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
                  ),
                ],
              ),

              /// Day
              SizedBox(height: 16),
              Text(
                'Day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB0B0C3),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF6C63FF), width: 1),
                ),
                child: DropdownButton(
                  dropdownColor: Color(0xFF1A1A2E),
                  value: dayValue,
                  icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFB0B0C3)),
                  items: days
                      .map<DropdownMenuItem<String>>(
                        (e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Colors.white))),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      dayValue = value!;
                    });
                  },
                  isExpanded: true,
                  underline: SizedBox(),
                ),
              ),

              /// Add Button
              SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () => onUpdateRoutine(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Update Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
