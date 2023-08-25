import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hatchout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TopPage(),
    );
  }
}

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダイアログ内でsetState'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return SimpleDialog(
                    contentPadding: const EdgeInsets.all(0.0),
                    titlePadding: const EdgeInsets.all(0.0),
                    title: SizedBox(
                      height: 400,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text(
                            'ダイアログ内でsetState',
                            style: TextStyle(fontSize: 15.0),
                          ),
                          centerTitle: true,
                        ),
                        body: Center(
                            child: Text(
                          '$_counter',
                          style: const TextStyle(fontSize: 40.0),
                        )),
                        floatingActionButton: FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _counter++;
                            });
                          },
                        ),
                      ),
                    ));
              });
            },
          );
        },
      ),
    );
  }
}


///SOURCE : https://note.com/hatchoutschool/n/nda33cfa5f2d4