import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:routine_app/pages/create_routine_page.dart';

class MainPage extends StatefulWidget {
  final Isar isar;
  const MainPage({super.key, required this.isar});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    );
  }
}
