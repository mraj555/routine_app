import 'package:flutter/material.dart';
import 'package:routine_app/pages/create_routine_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
                builder: (context) => const CreateRoutinePage(),
              ),
            ),
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
