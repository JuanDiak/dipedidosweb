import 'package:flutter/foundation.dart';
class MyProvider with ChangeNotifier {

  int value = 0;
  void Contador(int val) {
      value = val;
      notifyListeners();
  }
}

