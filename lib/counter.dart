import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
