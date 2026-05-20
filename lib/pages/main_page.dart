import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:routine_app/collections/product/product.dart';
import 'package:routine_app/collections/routine/routine.dart';
import 'package:routine_app/config.dart';
import 'package:routine_app/pages/create_routine_page.dart';
import 'package:routine_app/pages/update_routine_page.dart';
import 'package:routine_app/service/api_service.dart';

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
  APIService apiService = APIService();
  bool showProducts = false;

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

  Future<void> _apiToIsar() async {
    apiService.init(
      BaseOptions(baseUrl: baseUrl, contentType: 'application/json'),
    );

    final response = await apiService.request(
      endpoint: 'products?limit=6',
      method: Method.GET,
    );

    List<Map<String, dynamic>> products = (response.data! as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    await widget.isar.writeTxn(() async {
      await widget.isar.products.clear();
      await widget.isar.products.importJson(products);
    });

    setState(() {});
  }

  Future<List<Product>> _readProducts() async {
    return await widget.isar.products.where().findAll();
  }

  _isarToAPI() async {
    final prodt = await widget.isar.products.where().findAll();
    List<Map<String, dynamic>>? listProducts = prodt
        .map((e) => e.toJson())
        .toList();
    apiService.init(BaseOptions(baseUrl: serverUrl));
    Map<String, dynamic> params = {'products': listProducts};
    final response = await apiService.request(
      endpoint: '/products',
      method: Method.POST,
      params: params,
    );
    Logger().i(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        title: Text(
          "Routine",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            icon: Icon(Icons.add, color: Color(0xFF6C63FF)),
          ),

          IconButton(
            onPressed: () async {
              await _apiToIsar();
              setState(() {
                showProducts = true;
              });
            },
            icon: Icon(Icons.download, color: Color(0xFF6C63FF)),
          ),

          IconButton(
            onPressed: () async {
              await _isarToAPI();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Products uploaded successfully!')),
                );
              }
            },
            icon: Icon(Icons.upload, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            TextFormField(
              controller: _search,
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
                hintText: 'Search routine',
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFB0B0C3),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _routine = _readAllRoutines(search: value);
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(
                color: feedbackColor,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
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
                                      color: Color(0xFFB0B0C3),
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: Icon(Icons.schedule, size: 18, color: Color(0xFFB0B0C3)),
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
                                      color: Color(0xFFB0B0C3),
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.calendar_month,
                                          size: 18,
                                          color: Color(0xFFB0B0C3),
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

            if (showProducts)
              FutureBuilder<List<Product>>(
                future: showProducts ? _readProducts() : Future.value([]),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.hasData && asyncSnapshot.data!.isNotEmpty) {
                    final product = asyncSnapshot.data!;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: List.generate(
                      product.length,
                      (index) => Card(
                        color: Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 90,
                                child: Image.network(
                                  product[index].image!,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                product[index].title!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text("View"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox();
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF4757),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Clear All"),
          ),
        ),
      ),
    );
  }
}
