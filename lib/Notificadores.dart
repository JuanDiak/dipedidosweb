import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class NotificarCantidad with ChangeNotifier {
  double cantidad = 0;
  NotificarCantidad({this.cantidad});

  getcantidad() => cantidad;
  void addCantidad(double value) {
    cantidad+=value;
    notifyListeners();
  }
}

class ChangePage with ChangeNotifier {
  String page;
  ChangePage({this.page});
  getPage() => page;
  void setPage(String value) {
    page=value;
    notifyListeners();
  }
}

class CambioModelo with ChangeNotifier {
  int IDModelo = 0;
  CambioModelo({this.IDModelo});

  getIDModelo() => IDModelo;
  void setIDModelo(int value) {
    IDModelo=value;
    notifyListeners();
  }
}
