import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/collections/routine/routine.dart';
import 'package:routine_app/pages/create_routine_page.dart';
import 'package:routine_app/pages/update_routine_page.dart';

class MainPage extends StatefulWidget {
  final Isar isar;
  const MainPage({super.key, required this.isar});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Routine> routines = [];
  @override
  void initState() {
    super.initState();
    _readAllRoutines();
  }

  Future<List<Routine>> _readAllRoutines() async {
    final _routines = await widget.isar.routines.where().findAll();

    setState(() {
      routines = _routines;
    });
    return _routines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routine"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateRoutinePage(isar: widget.isar),
              ),
            ),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: FutureBuilder(
          future: _readAllRoutines(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData || asyncSnapshot.data!.isNotEmpty) {
              return Column(
                children: [
                  ...List.generate(
                    routines.length,
                    (index) => Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routines[index].title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.schedule, size: 18),
                                  ),
                                  TextSpan(
                                    text: " ${routines[index].startTime}",
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.calendar_month, size: 18),
                                  ),
                                  TextSpan(text: " ${routines[index].day}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext ctx) => UpdateRoutinePage(
                              isar: widget.isar,
                              routine: routines[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ),
    );
  }
}
