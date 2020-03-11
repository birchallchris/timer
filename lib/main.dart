import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'timer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color clockColour = Colors.blueGrey;
  bool intRun = true;
  bool recRun = false;
  int _currentMin = 1;
  int _currentSecond = 30;
  int _currentMinRecovery = 0;
  int _currentSecondRecovery = 30;
  bool firstStart = true;
  bool firstRunRec = true;
  bool started = false;
  bool stopped = true;
  int timeForTimer = 0;
  int timeForRecover = 0;
  String timeToDisplay = "00:00";
  bool checkTimer = true;
  int repeats = 1;
  int cycles = 0;
  int repeatsLeft = 1;
  int repeatsCache = 1;

  void start(){
    if(intRun == false && recRun == true) {
      runRec();
    }else{
      if (firstStart == true) {
        timeForTimer = (_currentMin * 60) + _currentSecond;
        repeatsCache = repeats; // remember what repeats was set to for reset
        firstStart = false; // whether to reset clock or not
      }
      if(timeForTimer>0) {
        Duration durStart = Duration(seconds: timeForTimer.round());
        setState(() {
          clockColour = Colors.green;
          timeToDisplay = [durStart.inMinutes, durStart.inSeconds].map((seg) =>
              seg.remainder(60).toString().padLeft(2, '0')).join(':');
        });
        started = true;  // start button disabled
        stopped = false; // stop button enabled
        checkTimer = true; // true = keep timer running
        Timer.periodic(Duration(
          seconds: 1,
        ), (Timer t) {
          if (timeForTimer < 2 || checkTimer == false) {
            t.cancel(); // cancels the next one...
            checkTimer = true;
            if (timeForTimer < 2) {
              firstStart = true;
              //stopped = true; // only do in runRec??
              //started = false;
              timeForTimer = (_currentMin * 60) + _currentSecond;
              setState(() {
                clockColour = Colors.blueGrey;
              });
              runRec();
            }
          } else {
            timeForTimer = timeForTimer - 1;
            // update timeToDisplay only here to avoid overriding runRec updates
            Duration durStart2 = Duration(seconds: timeForTimer.round());
            setState(() {
              timeToDisplay =
                  [durStart2.inMinutes, durStart2.inSeconds].map((seg) =>
                      seg.remainder(60).toString().padLeft(2, '0')).join(':');
            });
          }
        });
      }else{
        //timeForTimer  = 0
        firstStart = true;
        timeForTimer = (_currentMin * 60) + _currentSecond;
        setState(() {
          //stopped = true;  // only do in runRec
          //started = false;
          clockColour = Colors.blueGrey;
        });
        runRec();
      }
    }
  }
  void stop(){
    setState(() {
      stopped = true;  // disable  stop button
      started = false; // enable start button
      checkTimer = false; // flag says stop timer
      clockColour = Colors.grey;
    });
  }
  void reset(){
    firstStart = true;
    firstRunRec = true;
    intRun = true;
    recRun = false;
    timeForTimer = (_currentMin * 60) + _currentSecond;
    Duration durReset = Duration(seconds: timeForTimer.round());
    cycles = 0; // take this out to leave reset to current level only
    repeats = repeatsCache;
    setState(() {
      timeToDisplay =  [durReset.inMinutes, durReset.inSeconds].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
      clockColour = Colors.blueGrey;
      repeatsLeft = repeats;
    });
  }
  void runRec(){
    if(firstRunRec == true){
      setState(() {
        timeForRecover = (_currentMinRecovery * 60) + _currentSecondRecovery;
        cycles = cycles + 1;
        repeatsLeft = repeats - cycles;
      });
      firstRunRec = false;
    }
    if(timeForRecover>0){
      Duration durRecover = Duration(seconds: timeForRecover.round());
      setState(() {
        clockColour = Colors.redAccent;
        timeToDisplay = [durRecover.inMinutes, durRecover.inSeconds].map((seg) =>
            seg.remainder(60).toString().padLeft(2, '0')).join(':');
      });
      intRun = false;
      recRun = true;
      stopped = false;  //enable stop button
      started = true; //disable start button
      Timer.periodic(Duration(
        seconds: 1,
      ), (Timer t) {
        if (timeForRecover < 2 || checkTimer == false) {
          t.cancel();
          checkTimer = true;
          if (timeForRecover < 2) {
            firstStart = true;
            firstRunRec = true;
            stopped = true;  //disable stop button
            started = false; //enable start button
            intRun = true;
            recRun = false;
            setState(() {
              clockColour = Colors.blueGrey;
            });
            runRepeat();
          }
        } else {
          timeForRecover = timeForRecover - 1;
          // update timeToDisplay only here to avoid overriding start updates
          Duration durRecover2 = Duration(seconds: timeForRecover.round());
          setState(() {
            timeToDisplay =
                [durRecover2.inMinutes, durRecover2.inSeconds].map((seg) =>
                    seg.remainder(60).toString().padLeft(2, '0')).join(':');
          });
        }
      });
    }else{
      firstStart = true;
      firstRunRec = true;
      //checkTimer = false; // flag says stop timer
      intRun = true;
      recRun = false;
      clockColour = Colors.blueGrey;
      runRepeat();
    }
  }
  void runRepeat(){
    if(cycles<repeats){
      firstStart = true;
      firstRunRec = true;
      start();
    }else{
      cycles = 0;
      repeats = repeatsCache;
      setState(() {
        started = false; // enable start button at the end
        stopped = true;  // disable stop button at the end
        repeatsLeft = repeats;
        timeToDisplay = "00:00"; // avoid hanging '1' at very end
      });
    }
  }
  Widget timer(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              color: clockColour,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: Colors.black,
                        child: Text(
                          timeToDisplay,
                          style: TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        padding: EdgeInsets.all(10.0)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Text(
                                      'Interval',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      "MM",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.integer(
                                      initialValue: _currentMin,
                                      minValue: 0,
                                      maxValue: 59,
                                      zeroPad: true,
                                      listViewWidth: 50.0,
                                      itemExtent: 30.0,
                                      onChanged: (newValue) => setState(() => _currentMin = newValue)
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      "SS",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.integer(
                                      initialValue: _currentSecond,
                                      minValue: 0,
                                      maxValue: 59,
                                      step: 5,
                                      zeroPad: true,
                                      listViewWidth: 50.0,
                                      itemExtent: 30.0,
                                      onChanged: (newValue) => setState(() => _currentSecond = newValue)
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ButtonTheme(
                                      minWidth: 100.0,
                                      height: 70.0,
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        color: Colors.green,
                                        onPressed: started ? null : () {
                                          start();
                                        },
                                        child: Text(
                                          "Start",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ButtonTheme(
                                      minWidth: 100.0,
                                      height: 70.0,
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        color: Colors.redAccent,
                                        onPressed: stopped ? null : () {
                                          stop();
                                        },
                                        child: Text(
                                          "Pause",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ButtonTheme(
                                      minWidth: 100.0,
                                      height: 70.0,
                                      child: RaisedButton(
                                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        color: Colors.blueAccent,
                                        onPressed: () {
                                          stop();
                                          reset();
                                        },
                                        child: Text(
                                          "Reset",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Text(
                                      'Recover',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      "MM",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.integer(
                                      initialValue: _currentMinRecovery,
                                      minValue: 0,
                                      maxValue: 59,
                                      zeroPad: true,
                                      listViewWidth: 50.0,
                                      itemExtent: 30.0,
                                      onChanged: (newValue) => setState(() => _currentMinRecovery = newValue)
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(
                                      "SS",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  NumberPicker.integer(
                                      initialValue: _currentSecondRecovery,
                                      minValue: 0,
                                      maxValue: 59,
                                      step: 5,
                                      zeroPad: true,
                                      listViewWidth: 50.0,
                                      itemExtent: 30.0,
                                      onChanged: (newValue) => setState(() => _currentSecondRecovery = newValue)
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blueGrey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: Text(
                        "Repeat: ",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                    child: Text(
                      repeatsLeft.toString(),
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: FittedBox(
                      child: Image.asset(
                        'images/add-48dp.png',
                        fit: BoxFit.fill,
                        width: 50.0,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (repeats < 99) {
                          repeats = repeats + 1;
                        }
                        repeatsLeft = repeats - cycles;
                      });
                    }
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: FittedBox(
                      child: Image.asset(
                        'images/remove-48dp.png',
                        fit: BoxFit.fill,
                        width: 50.0,
                      ),
                    ),
                    onPressed: (){
                      setState(() {
                        if(repeats>1){
                          repeats = repeats - 1;
                        }
                        repeatsLeft = repeats - cycles;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.teal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          "Bottom section - random sounds and colours"
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Timer app",
        ),
      ),
      body: timer(),
    );
  }
}
