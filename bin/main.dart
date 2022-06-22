import 'package:http/http.dart' as http;
import 'package:ical_serializer/ical_serializer.dart';
import 'package:html/parser.dart';
import 'dart:io';

void main() async {
  var cal = ICalendar(
    product: 'gdq',
    company: 'gdq',
  );

  final res = await http.get(Uri.parse('https://gamesdonequick.com/schedule'));

  final doc = parse(res.body);

  final table = doc.getElementById('runTable');

  final rows = table
      .querySelectorAll('tr')
      .where((element) => element.className != 'day-split')
      .toList();

  while (rows.isNotEmpty) {
    final row1 = rows.removeAt(0);
    final row2 = rows.removeAt(0);

    final cols = row1.querySelectorAll('td');

    final startTime =
        DateTime.parse(row1.querySelector('.start-time').text).toUtc();
    final title = cols[1].text.trim();
    final runner = cols[2].text.trim();

    final cols2 = row2.querySelectorAll('td');

    final duration = parseDuration(cols2[0].text);
    final subtitle = cols2[1].text.trim();
    final host = cols2[2].text.trim();

    cal.addElement(
      IEvent(
        uid: 'sgdq-2022-${startTime.millisecondsSinceEpoch}',
        start: startTime,
        end: startTime.add(duration),
        status: IEventStatus.CONFIRMED,
        // location: 'SGDQ 2022',
        summary: '$title • $subtitle',
        description: 'Runner: $runner, Host: $host',
      ),
    );
  }

  File('sgdq-2022.ics').writeAsStringSync(cal.serialize());
}

Duration parseDuration(String d) {
  final parts = d.split(':');

  return Duration(
    seconds: int.parse(parts[2]),
    minutes: int.parse(parts[1]),
    hours: int.parse(parts[0]),
  );
}
