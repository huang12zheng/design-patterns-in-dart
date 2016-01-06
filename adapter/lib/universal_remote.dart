library universal_remote;

import 'dart:async';

import 'robot.dart';
import 'async_robot.dart';

/*** Delegate / Target ***/

// class RunningCommand extends Timer {
//   RunningCommand(Duration d, Function cb) { new super(d, cb); }
//   RunningCommand.periodic(Duration d, Function cb): super.periodic(d, cb);
//   bool get isActive => super.isActive;
//   void cancel() { super.cancel(); }
// }

const oneSecond = const Duration(seconds: 1);

class UniversalRemoteRobot {
  Ubot _ubot;
  List<Timer> _activeControls = [];

  UniversalRemoteRobot(robot) { _delegateRobot(robot); }

  void _delegateRobot(robot) {
    if (robot is Robot) _ubot = new RobotAdapterToUbot(robot);
    else if (robot is Bot) _ubot = new BotAdapterToUbot(robot);
    else _ubot = new NullAdapterToUbot();
  }

  String get xyLocation => _ubot.xyLocation;

  Timer moveForward()  => _executeControlledCommand(_ubot.moveForward);
  Timer moveBackward() => _executeControlledCommand(_ubot.moveBackward);
  Timer moveLeft()     => _executeControlledCommand(_ubot.moveLeft);
  Timer moveRight()    => _executeControlledCommand(_ubot.moveRight);

  Timer _executeControlledCommand(command) {
    var t = new Timer.periodic(oneSecond, (_){ command(); });
    _activeControls.add(t);
    return t;
  }

  void stop() {
    while (_activeControls.isNotEmpty) {
      _activeControls.removeLast().cancel();
    }
  }
}


/*** Target ***/
abstract class Ubot {
  String get xyLocation;
  void moveForward();
  void moveBackward();
  void moveLeft();
  void moveRight();
}

/*** Adapters ***/
class RobotAdapterToUbot implements Ubot {
  Robot _robot;
  RobotAdapterToUbot(this._robot);

  String get xyLocation => _robot.location;

  void moveForward()  { _robot.move(Direction.NORTH); }
  void moveBackward() { _robot.move(Direction.SOUTH); }
  void moveLeft()     { _robot.move(Direction.WEST); }
  void moveRight()    { _robot.move(Direction.EAST); }
}

class BotAdapterToUbot implements Ubot {
  Bot _bot;
  BotAdapterToUbot(this._bot);

  String get xyLocation => "${_bot.x}, ${_bot.y}";

  void moveForward()  { _bot.goForward(); }
  void moveBackward() { _bot.goBackward(); }
  void moveLeft()     { _bot.goLeft(); }
  void moveRight()    { _bot.goRight(); }
}

class NullAdapterToUbot implements Ubot {
  String get xyLocation => "0, 0";

  void moveForward()  {}
  void moveBackward() {}
  void moveLeft()     {}
  void moveRight()    {}
}
