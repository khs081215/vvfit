import 'package:flutter/material.dart';
import 'package:flutter_project/screens/setting_screens/purpose_page.dart';
import 'package:provider/provider.dart';
import '../../provider/regression_provider.dart';
import '../workout_screens/guide_page.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  Widget build(BuildContext context) {
    final regressionProvider = Provider.of<RegressionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("메인운동을 선택해주세요"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: buildWorkoutCard("Bench Press", regressionProvider.regressionModel.regressionIdBench, "Chest", 'assets/images/p_training/bench_press.jpeg')),
                VerticalDivider(width: 1, color: Colors.black),
                Expanded(child: buildWorkoutCard("Back Squat", regressionProvider.regressionModel.regressionIdSquat, "lower body", 'assets/images/p_training/squat.jpeg')),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: buildWorkoutCard("Conventional Dead Lift", regressionProvider.regressionModel.regressionIdDL, "Back", 'assets/images/p_training/deadlift.jpeg')),
                VerticalDivider(width: 1, color: Colors.black),
                Expanded(child: buildWorkoutCard("Overhead Press", regressionProvider.regressionModel.regressionIdSP, "Shoulder", 'assets/images/p_training/overhead_press.jpeg')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutCard(String title, String? keyId, String key, String imagePath) {
    if (keyId == "00000") {
      keyId = "test required";
    }
    final bool unavailable = keyId == null || keyId == "test required";
    final String message = keyId == "test required" ? "LV 프로파일을 갱신해주세요" : "LV 프로파일이 없습니다.";
    String localizedTitle;

    // 이름을 로컬화하는 부분 추가
    switch (title) {
      case 'Bench Press':
        localizedTitle = '벤치 프레스';
        break;
      case 'Back Squat':
        localizedTitle = '스쿼트';
        break;
      case 'Conventional Dead Lift':
        localizedTitle = '데드 리프트';
        break;
      case 'Overhead Press':
        localizedTitle = '오버헤드 프레스';
        break;
      default:
        localizedTitle = title; // 기본적으로 원래 제목 사용
    }

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (unavailable) {
            navigateToGuidePage(title);
          } else {
            navigateToSamplePage(key);
          }
        },
        highlightColor: Colors.grey.withOpacity(0.3),
        splashColor: Colors.grey.withOpacity(0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Opacity(
                  opacity: unavailable ? 0.3 : 1.0,
                  child: Image.asset(
                    imagePath,
                    width: 150,
                    height: 150,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  localizedTitle, // 로컬화된 제목 사용
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: unavailable ? Colors.grey : Colors.black,
                  ),
                ),
                if (unavailable)
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToSamplePage(String key) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PurposePage(target: key),
      ),
    );
  }

  void navigateToGuidePage(String exerciseName) {
    String exerciseId;

    switch (exerciseName) {
      case 'Bench Press':
        exerciseId = '00001';
        break;
      case 'Conventional Dead Lift':
        exerciseId = '00004';
        break;
      case 'Overhead Press':
        exerciseId = '00009';
        break;
      case 'Squat':
        exerciseId = '00010';
        break;
      default:
        _showAlertDialog(context, '올바른 운동을 선택해주세요');
        return;
    }

    print('블락 > 가이드 페이지 전달 데이터: $exerciseId and exerciseName: $exerciseName');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GuidePage(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          weight: 0,
          reps: 0,
          realWeights: [],
          disableModelCreation: false,
          restPeriod: 0,
        ),
      ),
    );
  }
}

void _showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('확인'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
