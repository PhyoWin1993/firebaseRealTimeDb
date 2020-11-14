import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'model/board.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Board App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  Board board;
  List<Board> boardMessage = List();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  //

  @override
  void initState() {
    super.initState();
    board = Board("", "");
    databaseReference = database.reference().child("community_board");

    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  // void _incrementCounter() {
  //   database
  //       .reference()
  //       .child('messages')
  //       .set({"name": "Kay Kay", "nickName": "kk", "age": 222});
  //   setState(() {
  //     database
  //         .reference()
  //         .child('messages')
  //         .once()
  //         .then((DataSnapshot snapshop) {
  //       Map<dynamic, dynamic> list = snapshop.value;
  //       print(" Data is ==>${list.values}");
  //     });

  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Community Board"),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 0,
            child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val) => board.subject = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),

                  //

                  ListTile(
                    leading: Icon(Icons.message),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val) => board.body = val,
                      validator: (val) => val == "" ? val : null,
                    ),
                  ),

                  //

                  FlatButton(
                    child: Text("Post"),
                    color: Colors.redAccent,
                    onPressed: () {
                      handleSubmitted();
                    },
                  )
                ],
              ),
            ),
          ),

          // second Flexible

          Flexible(
            child: FirebaseAnimatedList(
              query: databaseReference,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    title: Text(boardMessage[index].subject),
                    subtitle: Text(boardMessage[index].body),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessage.add(Board.fromSnapshot(event.snapshot));
    });
  }

  void handleSubmitted() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();

      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessage.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      boardMessage[boardMessage.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
  }
}
