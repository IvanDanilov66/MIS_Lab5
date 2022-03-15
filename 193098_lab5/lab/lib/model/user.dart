import './exam.dart';

class User {
  String username;
  String password;
  List<ScheduledExam> listOfScheduledExams = [];
  User(this.username, this.password);
}
