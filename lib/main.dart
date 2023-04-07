import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dbHelper.dart';
import 'model/item.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          // useMaterial3: false,
          fontFamily: 'MyFont'),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> colorCodes = <int>[600, 500, 100];
  String textvalue = "";
  final nameController = TextEditingController();
  final editText = TextEditingController();

  // late Database _database;
  final DBHelper dbHelper = DBHelper();
  int _checkboxValue = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setValueEdit();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          title: const Text(
            "Todo List",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
      body: listView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            //border bottom sheet
            shape: const RoundedRectangleBorder(
              // <-- SEE HERE
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            //du het gia tri len
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return showBottomSheet(context);
            },
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> listView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Map<String, dynamic>> data = snapshot.data!;
          return ListView.separated(
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: _checkboxValue != data[index]['complete'],
                                fillColor:
                                    MaterialStateProperty.all(Colors.green),
                                visualDensity:
                                    VisualDensity.adaptivePlatformDensity,
                                onChanged: (value) => {
                                  updateComplete(data[index]['id'],value)
                                }),
                            Text(
                              '${data[index]['name']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.edit),
                            //   onPressed: () {
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) => AlertDialog(
                            //         title: Text("Chỉnh sửa"),
                            //         content: Padding(
                            //           padding: const EdgeInsets.all(8.0),
                            //           child: TextField(
                            //             controller: editText,
                            //             decoration: const InputDecoration(
                            //               hintText: 'Vui lòng nhập dữ liệu',
                            //             ),
                            //           ),
                            //         ),
                            //         actions: [
                            //           TextButton(
                            //               onPressed: () {
                            //                 btnEdit(data[index]['id'],
                            //                     editText.text, context);
                            //               },
                            //               child: Text("Sửa")),
                            //           TextButton(
                            //               onPressed: () {
                            //                 Navigator.pop(context);
                            //               },
                            //               child: Text("Hủy"))
                            //         ],
                            //       ),
                            //     );
                            //   },
                            // ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Add your code here
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Bạn có muốn xóa không?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            btnRemove(data[index]['id']);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Có")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Không"))
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: data.length);
        } else if (snapshot.hasError) {
          return Text("error ${snapshot.error}");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Padding showBottomSheet(context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Your task"),
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        btnAdd("999", nameController.text,false, context),
                    child: const Text(
                      "Thêm",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  btnAdd(String id, String name, bool complete, context) {
    // DataItems dataItems = new DataItems(id, name);
    // list.add(dataItems);
    // nameController.clear();
    // Navigator.of(context as BuildContext);
    // setState(() {});
    // insertData(name);
    if (name.isNotEmpty) {
      final Map<String, dynamic> row = {'name': name, 'complete': complete};
      dbHelper.insertData(row);
      showToast("Thêm thành công");
      nameController.clear();
      setState(() {});
      Navigator.of(context).pop();
    } else {
      showToast("Vui lòng không để trống");
    }
  }

  void btnRemove(index) {
    // list.removeAt(index);
    // deleteData(index);
    dbHelper.deleteData(index);
    print(index);
    showToast("Xóa thành công");
    setState(() {});
  }

  // //crud sql
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _initDatabase();
  //   getData();
  // }
  //
  // Future<void> _initDatabase() async {
  //   var databasesPath = await getDatabasesPath();
  //   String path = join(databasesPath, 'demo.db');
  //   _database = await openDatabase(path, version: 1,
  //       onCreate: (Database db, int version) async {
  //     await db.execute(
  //         'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT)');
  //   });
  // }
  //
  // //// add
  // Future<void> insertData(name) async {
  //   if (name.isNotEmpty) {
  //     final Map<String, dynamic> row = {'name': name};
  //     final int id = await _database.insert('users', row);
  //     print('User inserted with id: $id');
  //     showToast("Thêm thành công");
  //     nameController.clear();
  //     setState(() {});
  //   } else {
  //     showToast("Vui lòng nhập thông tin");
  //   }
  // }
  //
  // //// update
  // Future<void> updateData(id, name) async {
  //   if (name.isNotEmpty) {
  //     final Map<String, dynamic> row = {'name': name};
  //     final int ids =
  //         await _database.update('users', row, where: "id=?", whereArgs: [id]);
  //     print('User inserted with id: $ids');
  //     showToast("Sửa thành công");
  //     nameController.clear();
  //     setState(() {});
  //   } else {
  //     showToast("Vui lòng nhập thông tin");
  //   }
  // }
  //
  // //delete
  // Future<void> deleteData(id) async {
  //   final int ids =
  //       await _database.delete('users', where: "id = ?", whereArgs: [id]);
  //   print('User inserted with id: $ids');
  //   showToast("Xóa thành công");
  //   setState(() {});
  // }
  //
  // //get data
  //
  // Future getData() async {
  //   final db = await _database;
  //   final alldata = await db!.query("users");
  //   print(alldata);
  // }

  void showToast(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
    );
  }

  void btnEdit(id, String editText, context) {
    if (editText.isNotEmpty) {
      var value = {'name': editText};
      dbHelper.updateData(id, value);
      setState(() {});
    } else {
      showToast("Vui không để trống");
    }
  }

  void setValueEdit() {
    editText.text = '';
  }

  updateComplete(id,value) {
    if(value != true){
      var data123 = {
        'complete': value
      };
      dbHelper.updateData(id, data123);
    }else{
      var data123 = {
        'complete': value
      };
      dbHelper.updateData(id, data123);
    }
    setState(() {
    });
  }
}
