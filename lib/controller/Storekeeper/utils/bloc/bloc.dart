import 'package:rxdart/subjects.dart';

abstract class Bloc {
  // VARIABLES
  final BehaviorSubject<String> _errMsg = BehaviorSubject();
  final BehaviorSubject<bool> _loadingState = BehaviorSubject();

  // DISPOSE
  void dispose() {
    _errMsg.close();
    _loadingState.close();
  }

  // GET
  Stream<String> get err$ => _errMsg.stream;
  Stream<bool> get loadingState$ => _loadingState.stream;

  // SET
  set errMsg(String value) => _errMsg.sink.add(value);
  void loading() => _loadingState.sink.add(true);
  void done() => _loadingState.sink.add(false);
  void close() => _loadingState.sink.add(null);

  // METHOD
  Future checker(Future value) {
    loading();

    return value.catchError((value) {
      errMsg = value.toString();
      throw value;
    }).whenComplete(() {
      done();
      close();
    });
  }
}
