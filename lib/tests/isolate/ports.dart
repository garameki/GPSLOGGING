import 'dart:isolate';

class Human {
  final ReceivePort _receivePort = ReceivePort();
  late final SendPort _sendPort;
  void init() {
    _sendPort = _receivePort.sendPort;
    _receivePort.listen((message) {
      if (message['goodNight']) {
        _receivePort.close();
      } else {
        print(message['words']);
      }
    });
  }

  SendPort get sendPort => _sendPort;

  Map<dynamic, dynamic> say(String words) {
    Map<dynamic, dynamic> message = {
      'sendPort': _receivePort.sendPort,
      'message': words,
      'goodNight': false,
    };

    return message;
  }

  Map<dynamic, dynamic> sayGoodbye() {
    Map<dynamic, dynamic> message = {
      'sendPort': _receivePort.sendPort,
      'message': null,
      'goodNight': true,
    };
    return message;
  }
}

class Parent extends Human {
  Parent() : super();
}

class Child extends Human {
  Child(this.sendPort) : super();
  @override
  SendPort sendPort;
}

void main2() async {
  Human parent = Human();
  parent.init();
  Human child = Human();
  child.init();

  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;

  receivePort.listen((message) {
//    SendPort portChild = message as SendPort;
    SendPort portChild = message['sendPort'];
    print(message['message']);
    Map<dynamic, dynamic> messageToChild = {
      'sendPort': sendPort,
      'message': 'Hello Son!',
      'goodNight': false,
    };
    portChild.send(messageToChild);
    if (message['goodNight']) receivePort.close();
  });

  await Isolate.spawn(child, sendPort);
}

void child(portMain) async {
  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;
  receivePort.listen((message) {
    SendPort sendPortToParent = message['sendPort'];
    print(message['message']);
    sendPortToParent.send('Good night!');
    if (message['goodNight']) receivePort.close();
  });

  Map<dynamic, dynamic> message = {
    'sendPort': sendPort,
    'message': 'Hello Main!',
    'goodNight': false,
  };
  portMain.send(message);
}
