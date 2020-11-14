import 'package:firebase_database/firebase_database.dart';

class Board {
  String key, subject, body;

  Board(this.subject, this.body);

  Board.fromSnapshot(DataSnapshot snapshot) {
    key = snapshot.key;
    subject = snapshot.value['subject'];
    body = snapshot.value['body'];
  }

  toJson() {
    return {"subject": subject, "body": body};
  }
}
