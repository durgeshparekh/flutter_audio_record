import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_record/audio_recorder.dart';
import 'package:flutter_audio_record/components/colors.dart';
import 'package:flutter_audio_record/views/record_list.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Directory? appDir;
  late List<String>? records;
  bool isMicPressed = false;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  late FlutterAudioRecorder? audioRecorder;
  Recording? _current;

  @override
  void initState() {
    super.initState();
    checkPermission();

    records = [];
    getExternalStorageDirectory().then((value) {
      appDir = value!;
      Directory appDirec = Directory("${appDir!.path}/Audiorecords/");
      appDir = appDirec;
      appDir!.list().listen((onData) {
        records!.add(onData.path);
      }).onDone(() {
        records = records!.reversed.toList();
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    appDir = null;
    records = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recorder',
          style: TextStyle(color: Colors.black),
        ),
        leading: Container(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: RecordList(
              records: records!,
            ),
          ),
          GestureDetector(
            onLongPress: () async {
              await _onRecordButtonPressed();
              setState(() {});
            },
            onLongPressEnd: (event) {
              _stop();
            },
            child: Listener(
              onPointerDown: (event) {
                setState(() => isMicPressed = true);
              },
              onPointerUp: (event) {
                setState(() => isMicPressed = false);
              },
              child: AvatarGlow(
                endRadius: 70.0,
                startDelay: Duration(milliseconds: 1000),
                glowColor: primaryColor,
                duration: Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                shape: BoxShape.circle,
                animate: isMicPressed,
                curve: Curves.fastOutSlowIn,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRecordButtonPressed() async {
    HapticFeedback.mediumImpact();
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          _record();
          break;
        }

      case RecordingStatus.Stopped:
        {
          _record();
          break;
        }
      default:
        break;
    }
  }

  _stop() async {
    var result = await audioRecorder!.stop();
    Fluttertoast.showToast(msg: "Stop Recording , File Saved");
    _onFinish();

    setState(() {
      _current = result!;
      _currentStatus = _current!.status!;
      _current!.duration = null;
    });
  }

  _onFinish() {
    records!.clear();
    print(records!.length.toString());
    appDir!.list().listen((onData) {
      records!.add(onData.path);
    }).onDone(() {
      setState(() {
        records!.sort();
        records = records!.reversed.toList();
      });
    });
  }

  Future<void> _record() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    print(statuses[Permission.microphone]);
    print(statuses[Permission.storage]);
    if (statuses[Permission.microphone] == PermissionStatus.granted) {
      await _initial();
      await _start();
      Fluttertoast.showToast(msg: "Start Recording");
      setState(() {
        _currentStatus = RecordingStatus.Recording;
      });
    } else {
      Fluttertoast.showToast(msg: "Allow App To Use Mic");
    }
  }

  checkPermission() async {
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    print(statuses[Permission.microphone]);
    print(statuses[Permission.storage]);
    if (statuses[Permission.microphone] == PermissionStatus.granted) {
      _currentStatus = RecordingStatus.Initialized;
    }
  }

  _initial() async {
    Directory? appDir = await getExternalStorageDirectory();
    String jRecord = 'Audiorecords';
    String dateTime = "${DateTime.now().millisecondsSinceEpoch.toString()}.wav";
    Directory appDirec = Directory("${appDir!.path}/$jRecord/");
    if (await appDirec.exists()) {
      String path = "${appDirec.path}$dateTime";
      print("path for file11 $path");
      audioRecorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);
      await audioRecorder!.initialized;
    } else {
      appDirec.create(recursive: true);
      Fluttertoast.showToast(msg: "Start Recording , Press Start");
      String path = "${appDirec.path}$dateTime";
      print("path for file22 $path");
      audioRecorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);
      await audioRecorder!.initialized;
    }
  }

  _start() async {
    await audioRecorder!.start();
    var recording = await audioRecorder!.current(channel: 0);
    setState(() {
      _current = recording!;
    });

    const tick = const Duration(milliseconds: 50);
    new Timer.periodic(tick, (Timer t) async {
      if (_currentStatus == RecordingStatus.Stopped) {
        t.cancel();
      }

      var current = await audioRecorder!.current(channel: 0);
      setState(() {
        _current = current!;
        _currentStatus = _current!.status!;
      });
    });
  }
}
