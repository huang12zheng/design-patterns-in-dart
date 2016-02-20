import 'dart:async' show StreamController;
import 'dart:html' show query, Event, InputElement;

abstract class CellFormatter {
  CellFormatter nextHandler;

  void processRequest(Event e) {
    if (!isCell(e)) return;
    if (handleRequest(e)) return;
    if (nextHandler == null) return;

    nextHandler.processRequest(e);
  }

  bool handleRequest(Event e) => false;

  bool isCell(Event e) {
    var input = e.target;
    if (input is! InputElement) return false;
    if (input.type != 'text') return false;
    return true;
  }
}

class NumberFormatter extends CellFormatter {
  bool handleRequest(Event e) {
    var input = e.target;
    RegExp exp = new RegExp(r"^\s*[\d\.]+\s*$");
    if (!exp.hasMatch(input.value)) return false;

    var val = double.parse(input.value);
    input.value = val.toStringAsFixed(2);
    input.style.textAlign = 'right';
    return true;
  }
}

class DateFormatter extends CellFormatter {
  bool handleRequest(Event e) {
    var input = e.target;
    RegExp exp = new RegExp(r"^\s*[\d/-]+\s*$");
    if (!exp.hasMatch(input.value)) return false;

    var val = DateTime.parse(input.value);
    input.value = val.toString().replaceFirst(' 00:00:00.000', '');
    return true;
  }
}

class TextFormatter extends CellFormatter {
  bool handleRequest(Event e) {
    var input = e.target;
    input.style.textAlign = 'left';
    return true;
  }
}

main() {
  var container = query('.container');

  var number = new NumberFormatter();
  var date = new DateFormatter();
  var text = new TextFormatter();

  number.nextHandler = date;
  date.nextHandler = text;

  var subscription =
    container.
    onChange.
    listen(number.processRequest);

  var c = new StreamController();
  container.onChange.listen(c.add);
  container.onClick.listen(c.add);

  c.stream.listen(number.processRequest);



  query('#no-numbers').onChange.listen((e){
    var el = e.target;
    if (el.checked) {
      subscription.cancel();
      subscription = container.
        onChange.
        listen(date.processRequest);
    }
    else {
      subscription.cancel();
      subscription = container.
        onChange.
        listen(number.processRequest);
    }
  });

  query('#no-text').onChange.listen((e){
    var el = e.target;
    if (el.checked) {
      date.nextHandler = null;
    }
    else {
      date.nextHandler = text;
    }
  });

}
