import 'dart:math';

import 'package:json/json.dart';

import '../example/example.dart';
import 'stats.dart';

final _rnd = new Random(0);

Order _randomOrder(int width) => new Order()
  ..itemNumber = _rnd.nextInt(100)
  ..count = _rnd.nextInt(width)
  ..isRushed = _rnd.nextBool();

final _theDate = new DateTime(1979, 8, 16);

Person _randomPerson(int width, int depth) => new Person(
    'kevin', 'moore', _theDate,
    middleName: 'Robert',
    lastOrder: _theDate,
    orders: new List<Order>.generate(width, (i) => _randomOrder(100)))
  ..relatedPeople = (depth < 1)
      ? null
      : new Map<String, Person>.fromIterable(new Iterable.generate(width),
          key: (i) => i.toString(),
          value: (_) => _randomPerson(width, depth - 1));

final _data = _randomPerson(10, 2);

void main() {
  // print sample
  print(const JsonEncoder.withIndent(' ').convert(_data));
  print('');

  // dry run
  var stats = new Stats.fromData(new Iterable<int>.generate(500, (i) => run()));
  print(stats.count);

  stats = new Stats.fromData(new Iterable<int>.generate(5000, (i) => run()));

  print(const JsonEncoder.withIndent(' ').convert(stats));
  print(stats.standardDeviation / stats.mean);
}

int run() {
  try {
    var timer = new Stopwatch()..start();
    var json = JSON.encode(_data);
    timer.stop();
    assert(json.isNotEmpty);
    return timer.elapsedMicroseconds;
  } on JsonUnsupportedObjectError catch (e) {
    dynamic thing = e;
    while (thing is JsonUnsupportedObjectError) {
      print([thing.cause, thing.unsupportedObject]);
      thing = thing.cause;
    }

    print(thing);

    rethrow;
  }
}
