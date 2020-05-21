import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CounterPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30,
      runSpacing: 20,
      children: <Widget>[
        Text(
          '${counter.count}回',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        Text(
          '最後：${dateTimeToString(counter.lastDate)}',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        LastDateWidget(counter),
        FlatButton(
          child: const Text('増やす'),
          onPressed: () => setState(
            () => counter
              ..incrementCount()
              ..save(),
          ),
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
    now = DateTime.now();
    Timer.periodic(
      Duration(seconds: 1),
      (_) => setState(() => now = DateTime.now()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dif = counter.lastDate.difference(now).abs();
    final formatted =
        '${dif.inDays}日${dif.inHours.remainder(24)}時${dif.inMinutes.remainder(60)}分${dif.inSeconds.remainder(60)}秒間';
    return Text(
      'dif: $formatted',
    );
  }
}

class Counter {
  int count;
  DateTime lastDate;

  static Future<Counter> createCounter() async {
    final counter = Counter();
    await counter.load();
    return counter;
  }

  static Future<File> getFilePath() async {
    const _fileName = 'counter.txt';
    final directory = await getApplicationDocumentsDirectory();
    return File(directory.path + '/' + _fileName);
  }

  void incrementCount() {
    count++;
    lastDate = DateTime.now();
  }

  Future<void> load() async {
    final file = await getFilePath();
    try {
      final str = await file.readAsString();

      final a = str.split(',');
      this.count = int.parse(a[0]);
      this.lastDate = DateTime.parse(a[1]);
    } catch (e) {
      this.count = 0;
      this.lastDate = DateTime.now();
    }
  }

  Future<void> save() async {
    final file = await getFilePath();
    file.writeAsString('$count,$lastDate');
  }
}

String dateTimeToString(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日${date.hour}時${date.minute}分${date.second}秒';
}
