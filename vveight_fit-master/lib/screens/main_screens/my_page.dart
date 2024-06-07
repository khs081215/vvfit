import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/workout_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _response = ''; // 응답 결과를 저장할 변수

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // HTTP 요청을 보내는 함수
  Future<void> _sendRequest() async {
    var url = Uri.parse('http://52.79.236.191:3000/api/workout/compare');
    var headers = {'Content-Type': 'application/json'};
    var body = json.encode({
      'user_id': '00001',
      'test_regression_id': '00122',
      'exercise_id': '00001',
      'name': 'Bench Press',
      'data': [
        {'weight': 75, 'mean_velocity': 0.45},
        {'weight': 80, 'mean_velocity': 0.33},
        {'weight': 90, 'mean_velocity': 0.28}
      ]
    });

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          _response = response.body; // 응답 결과를 상태로 저장
        });
      } else {
        setState(() {
          _response = 'Failed to load data: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      setState(() {
        _response = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutManager = Provider.of<WorkoutManager>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/puang_done.jpeg'),
            ),
            SizedBox(height: 10),
            Text('푸앙이',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('근육 푸앙을 꿈꾸는 푸앙이입니다 :)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: '사진'),
                  Tab(text: '로그'),
                  Tab(text: '루틴'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Center(
                    child: workoutManager.imageFile != null
                        ? Image.file(File(workoutManager.imageFile!.path),
                        width: 300, height: 300)
                        : Text('사진을 기록해주세요', style: TextStyle(fontSize: 20)),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (workoutManager.workoutDuration != null)
                          Text(
                              '운동 시간: ${formatDuration(workoutManager.workoutDuration!)}',
                              style: TextStyle(fontSize: 20)),
                        Text(
                          workoutManager.review.isNotEmpty
                              ? '운동 후기: ${workoutManager.review}'
                              : '운동 후기를 기록해주세요',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  workoutManager.workoutData != null
                      ? ListView(
                    children: workoutManager
                        .workoutData!.exerciseDetails.entries
                        .map((entry) {
                      return ExpansionTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: List<Widget>.generate(
                            entry.value.sessionCounts.length, (index) {
                          return ListTile(
                            title: Text('${index + 1} 세트'),
                            subtitle: Text(
                                '${entry.value.weights[index].toStringAsFixed(0)} kg, ${entry.value.sessionCounts[index]} reps'),
                          );
                        }),
                      );
                    }).toList(),
                  )
                      : Center(
                      child: Text('운동 루틴을 기록해주세요',
                          style: TextStyle(fontSize: 20))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 리뷰 페이지에서 넘어온 시간값을 시, 분, 초로 보여주기 위한 함수입니다.
String formatDuration(int totalSeconds) {
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  String formattedDuration = '';
  if (hours > 0) {
    formattedDuration += '${hours}h ';
  }
  if (minutes > 0) {
    formattedDuration += '${minutes}m ';
  }
  if (seconds > 0) {
    formattedDuration += '${seconds}s';
  }
  return formattedDuration.trim();
}
