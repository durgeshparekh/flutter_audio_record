import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_record/components/colors.dart';
import 'package:flutter_audio_record/components/custom_shape.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecordList extends StatefulWidget {
  final List<String> records;

  const RecordList({
    Key? key,
    required this.records,
  }) : super(key: key);

  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  late int _totalTime;
  late int _currentTime;
  double _percent = 0.0;
  int _selected = -1;
  bool isPlay = false;
  AudioPlayer advancedPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.records.length,
      shrinkWrap: true,
      reverse: true,
      padding: const EdgeInsets.all(10),
      itemBuilder: (BuildContext context, int i) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 30),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Record ${widget.records.length - i}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      _getTime(
                                          filePath:
                                              widget.records.elementAt(i)),
                                      style: TextStyle(color: Colors.black38),
                                    ),
                                  ],
                                ),
                                if (isPlay)
                                  playerBtnPress(
                                    icon: Icons.pause,
                                    onPressed: () {
                                      setState(() {
                                        isPlay = false;
                                      });
                                      advancedPlayer.pause();
                                    },
                                  )
                                else
                                  playerBtnPress(
                                    icon: Icons.play_arrow,
                                    onPressed: () {
                                      setState(() {
                                        isPlay = true;
                                      });
                                      advancedPlayer.play(
                                          widget.records.elementAt(i),
                                          isLocal: true);
                                      setState(() {});
                                      setState(() {
                                        _selected = i;
                                        _percent = 0.0;
                                      });
                                      advancedPlayer.onPlayerCompletion
                                          .listen((_) {
                                        setState(() {
                                          _percent = 0.0;
                                        });
                                      });
                                      advancedPlayer.onDurationChanged
                                          .listen((duration) {
                                        setState(() {
                                          _totalTime = duration.inMicroseconds;
                                        });
                                      });
                                      advancedPlayer.onAudioPositionChanged
                                          .listen((duration) {
                                        setState(() {
                                          _currentTime =
                                              duration.inMicroseconds;
                                          _percent = _currentTime.toDouble() /
                                              _totalTime.toDouble();
                                        });
                                      });
                                    },
                                  ),
                                playerBtnPress(
                                  icon: Icons.stop,
                                  onPressed: () {
                                    advancedPlayer.stop();
                                    setState(() {
                                      _percent = 0.0;
                                    });
                                  },
                                ),
                                playerBtnPress(
                                  icon: Icons.delete,
                                  onPressed: () {
                                    Directory appDirec =
                                        Directory(widget.records.elementAt(i));
                                    appDirec.delete(recursive: true);
                                    Fluttertoast.showToast(msg: "File Deleted");
                                    setState(() {
                                      widget.records
                                          .remove(widget.records.elementAt(i));
                                    });
                                  },
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: LinearProgressIndicator(
                                minHeight: 5,
                                backgroundColor: Colors.black,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                                value: _selected == i ? _percent : 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomPaint(painter: CustomShape(Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTime({required String filePath}) {
    String fromPath = filePath.substring(
        filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));
    if (fromPath.startsWith("1", 0)) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(fromPath));
      int year = dateTime.year;
      int month = dateTime.month;
      int day = dateTime.day;
      int hour = dateTime.hour;
      int min = dateTime.minute;
      String dato = '$year-$month-$day--$hour:$min';
      return dato;
    } else {
      return "No Date";
    }
  }

  Widget playerBtnPress(
      {required IconData icon, required Null Function() onPressed}) {
    return ButtonTheme(
      minWidth: 48.0,
      child: MaterialButton(
        child: Icon(
          icon,
          color: Colors.black,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
