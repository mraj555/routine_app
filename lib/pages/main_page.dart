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
  Future<List<Routine>>? _routine;
  final TextEditingController _search = TextEditingController();
  bool searching = false;
  String feedback = "";
  MaterialColor feedbackColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _routine = _readAllRoutines();
    createWatcher();
  }

  Future<List<Routine>> _readAllRoutines({String? search}) async {
    if (search != null && search.isNotEmpty) {
      return await widget.isar.routines
          .filter()
          .titleContains(search, caseSensitive: false)
          .findAll();
    }

    return await widget.isar.routines.where().findAll();
  }

  Future<void> onClearAll() async {
    await widget.isar.writeTxn(() async {
      await widget.isar.routines.clear();
    });

    setState(() {
      _routine = _readAllRoutines();
    });
  }

  createWatcher() async {
    Query<Routine> getRoutines = await widget.isar.routines.where().build();

    Stream<List<Routine>> queryChanged = getRoutines.watch(
      fireImmediately: true,
    );
    queryChanged.listen((routine) {
      if (routine.length - 1 > 3) {
        feedback = "You have more than 3 tasks to do.";
        feedbackColor = Colors.red;
      } else {
        feedback = "You are right on track.";
        feedbackColor = Colors.blue;
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routine"),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRoutinePage(isar: widget.isar),
                ),
              );

              setState(() {
                _routine = _readAllRoutines();
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            TextFormField(
              controller: _search,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
                hintText: 'Search routine',
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              onChanged: (value) {
                setState(() {
                  _routine = _readAllRoutines(search: value);
                });
              },
            ),
            SizedBox(height: 8),
            Text(
              feedback,
              style: TextStyle(
                color: feedbackColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            FutureBuilder(
              future: _routine,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasData && asyncSnapshot.data!.isNotEmpty) {
                  final routines = asyncSnapshot.data ?? [];

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
                                        child: Icon(
                                          Icons.calendar_month,
                                          size: 18,
                                        ),
                                      ),
                                      TextSpan(text: " ${routines[index].day}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext ctx) =>
                                      UpdateRoutinePage(
                                        isar: widget.isar,
                                        routine: routines[index],
                                      ),
                                ),
                              );

                              setState(() {
                                _routine = _readAllRoutines();
                              });
                            },
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: onClearAll,
            child: Text("Clear All"),
          ),
        ),
      ),
    );
  }
}
