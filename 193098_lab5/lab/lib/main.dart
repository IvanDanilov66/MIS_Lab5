import 'package:flutter/material.dart';
import 'model/exam.dart';
import 'model/user.dart';
import 'model/notifications.dart';
import 'model/map.dart';
import 'package:geocoder/geocoder.dart';

void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        title: "Лаб 3 (193098)",
        home: new TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotifications();
  }

  void listenNotifications() =>
      NotificationApi.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String payload) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => null,
      ));

  List<User> _users = [];
  User _loggedInUser = null;
  String _newCourse = "";
  String _newUser = "";
  String _newPass = "";
  DateTime _newDateTime = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('lab3 193098'),
        toolbarHeight: 75,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _loggedInUser == null
                  ? IconButton(
                      onPressed: _login,
                      icon: Icon(
                        Icons.login,
                        size: 40,
                      ),
                    )
                  : IconButton(
                      onPressed: _logout,
                      icon: Icon(
                        Icons.logout,
                        size: 40,
                      )),
              _loggedInUser != null
                  ? IconButton(
                      onPressed: _pushAddCourse,
                      icon: Icon(
                        Icons.add_box_outlined,
                        size: 40,
                      ))
                  : IconButton(
                      icon: Icon(
                        Icons.add,
                        size: 40,
                      ),
                      onPressed: _nothing,
                    ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 40,
                ),
                onPressed: notifikacii,
              ),
              IconButton(
                icon: Icon(
                  Icons.map,
                  size: 40,
                ),
                onPressed: mapa,
              ),
            ],
          )
        ],
      ),
      body: _buildListOfCourses(),
      bottomNavigationBar: IconButton(
          onPressed: () => showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2200),
              ),
          icon: Icon(
            Icons.calendar_today_rounded,
          )),
    );
  }

  void _addCourse() {
    if (_newCourse.length > 0) {
      if (_loggedInUser != null) {
        for (User u in _users) {
          if (u.username == _loggedInUser.username) {
            setState(() {
              u.listOfScheduledExams
                  .add(ScheduledExam(_newCourse, _newDateTime, _selectedTime));
            });
          }
        }
      }
    }
  }


  void _logout() {
    setState(() {
      _loggedInUser = null;
    });
  }

  notifikacii() {
    return NotificationApi.showNotification(
      title: "Yes",
      body: "yes",
      payload: 'sarah.abs',
    );
  }

  void mapa() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSample()),
    );
  }

  void _nothing() {
    showAlertDialog(context);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Најавете се прво!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _login() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: _buildLogIn(),
            // title: Text('Add Course'),
            // content: _buildAddCourse(),
          );
        });
  }

  void _deleteCourse(int index) {
    ScheduledExam deleted;
    setState(() {
      deleted = _loggedInUser.listOfScheduledExams.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Deleted ${deleted.name}'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _loggedInUser.listOfScheduledExams.insert(
              _loggedInUser.listOfScheduledExams.length > index ? index : 0,
              deleted);
          setState(() {});
        },
      ),
    ));
  }

  void _pushAddCourse() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: _buildAddCourse(),
            // title: Text('Add Course'),
            // content: _buildAddCourse(),
          );
        });
  }

  void _promptEndCourse(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Are you sure you want to delete the exam?'),
            actions: <Widget>[
              ElevatedButton(
                child: Padding(
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.all(10),
                ),
                onPressed: () {
                  _deleteCourse(index);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  void _setNewCourseState(String course) {
    if (course.length > 0) {
      setState(() => _newCourse = course);
    }
  }

  void _setNewUserState(String user) {
    if (user.length > 0) {
      setState(() => _newUser = user);
    }
  }

  void _setNewPassState(String pass) {
    if (pass.length > 0) {
      setState(() => _newPass = pass);
    }
  }

  void _setNewDateTime(DateTime dateTime) {
    setState(() {
      _newDateTime = dateTime ?? _newDateTime;
    });
  }

  void _setNewTime(TimeOfDay timeOfDay) {
    setState(() {
      _selectedTime = timeOfDay ?? _selectedTime;
    });
  }

  Widget _buildListOfCourses() {
    if (_loggedInUser != null) {
      return new ListView.builder(
        itemCount: _loggedInUser.listOfScheduledExams.length,
        itemBuilder: (context, index) {
          return new Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          "${_loggedInUser.listOfScheduledExams[index].name}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        new Text(
                          "${_loggedInUser.listOfScheduledExams[index].dateTime.toString().split(' ')[0]}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        new Text(
                            "${_loggedInUser.listOfScheduledExams[index].timeOfDay.format(context)}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                        new IconButton(
                            onPressed: mapa,
                            icon: Icon(Icons.directions)),
                      ]),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: IconButton(
                      onPressed: () => _promptEndCourse(index),
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 35,
                      )),
                )
              ],
            ),
            margin: EdgeInsets.all(15),
          );
        },
      );
    }
    return null;
  }

  void _logInUser() {
    for (User u in _users) {
      if (u.username == _newUser && u.password == _newPass) {
        setState(() {
          _loggedInUser = u;
        });
      }
    }
  }

  void _registerUser() {
    User newUser = new User(_newUser, _newPass);
    setState(() {
      _users.add(newUser);
    });
  }

  Widget _buildLogIn() {
    Widget _input() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              'Authentication',
              style: TextStyle(fontSize: 20),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          ),
          new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _logInUser();
            },
            onChanged: (val) {
              _setNewUserState(val);
            },
            decoration: new InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'username',
                contentPadding: EdgeInsets.all(16)),
          ),
          new TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (val) {
              _logInUser();
            },
            onChanged: (val) {
              _setNewPassState(val);
            },
            decoration: new InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'password',
                contentPadding: EdgeInsets.all(16)),
          ),
        ],
      );
    }

    return Container(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _input(),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        _registerUser();
                        Navigator.pop(context);
                      },
                      child: new Text("Register"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        _logInUser();
                        Navigator.pop(context);
                      },
                      child: new Text("Log in"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  Widget _buildAddCourse() {
    Widget _input() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1,
            child: Text(
              'Schedule a new Exam',
              style: TextStyle(fontSize: 15),
            ),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          ),
          new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _addCourse();
            },
            onChanged: (val) {
              _setNewCourseState(val);
            },
            decoration: new InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Name of subject',
                contentPadding: EdgeInsets.all(16)),
          ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2200),
                      ).then(
                        (value) => _setNewDateTime(value),
                      ),
                  child: Text('Choose date'))),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        initialEntryMode: TimePickerEntryMode.dial,
                      ).then((value) => _setNewTime(value)),
                  child: Text('Choose time'))),
      ],
      );
    }

    return Container(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _input(),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: new Text(
                        "Cancel",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        _addCourse();
                        Navigator.pop(context);
                      },
                      child: new Text("ОK"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
