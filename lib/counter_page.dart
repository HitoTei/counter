import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counter.dart';

class CounterPage extends StatelessWidget {
  const CounterPage();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Counter.createCounter(),
      builder: (BuildContext context, AsyncSnapshot<Counter> snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (snapshot.hasError) return Text('エラーが発生しました: ${snapshot.error}');

        return CounterContentsPage(snapshot.data);
      },
    );
  }
}

class CounterContentsPage extends StatefulWidget {
  CounterContentsPage(this.counter);
  final Counter counter;
  @override
  State<StatefulWidget> createState() {
    return _CounterContentsPageState(counter);
  }
}

class _CounterContentsPageState extends State<CounterContentsPage> {
  _CounterContentsPageState(this.counter);
  Counter counter;
  final controller = TextEditingController();
  final pref = SharedPreferences.getInstance();
  @override
  void initState() {
    pref.then((val) {
      controller.text = val.getString('text');
    });
    super.initState();
  }

  @override
  void dispose() {
    pref.then((val) {
      val.setString('text', controller.text);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${counter.count}回',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '最後：${dateTimeToString(counter.lastDate)}',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        SizedBox(height: 10),
        LastDateWidget(counter),
        SizedBox(height: 10),
        FlatButton(
          child: const Text('増やす'),
          onPressed: () {
            Share.share(
                '${controller.text}(${counter.count + 1}回目)\n${durationToString(DateTime.now().difference(counter.lastDate))}ぶり');
            setState(
              () => counter
                ..incrementCount()
                ..save(),
            );
          },
        ),
        SizedBox(height: 10),
        FlatButton(
          child: const Text('リセット'),
          onPressed: () => setState(() {
            counter
              ..count = 0
              ..lastDate = DateTime.now()
              ..save();
          }),
        ),
        TextField(
          controller: controller,
        ),
      ],
    );
  }
}

class LastDateWidget extends StatefulWidget {
  const LastDateWidget(this.counter);
  final Counter counter;

  @override
  State<StatefulWidget> createState() => _LastDateWidgetState(counter);
}

class _LastDateWidgetState extends State<LastDateWidget> {
  _LastDateWidgetState(this.counter);
  final Counter counter;
  DateTime now;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!timer.isActive) return;
        if (mounted)
          setState(() => now = DateTime.now());
        else
          timer.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dif = counter.lastDate.difference(now).abs();
    final formatted = '${durationToString(dif)}';
    return Text(
      'dif: $formatted',
    );
  }
}

String durationToString(Duration dif) {
  return '${dif.inDays}日${dif.inHours.remainder(24)}時${dif.inMinutes.remainder(60)}分${dif.inSeconds.remainder(60)}秒';
}

String dateTimeToString(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日${date.hour}時${date.minute}分${date.second}秒';
}
