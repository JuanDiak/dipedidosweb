import 'package:flutter/material.dart';

Color colorApp1=Colors.blue[900];
Color colorApp2=Colors.blue[800];
Color colorApp3=Colors.blue[600];
Color colorBoton=Colors.blue[600]; //Colors.teal;
Color colorletraBoton=Colors.white;
Color colorletraApp=Colors.white;

class Variables {
  String _id;
  String _idSubfamilia;
  int _index;
  int _indexSubfamilia;

  String getID() {
    String result;
    (_id == null) ? result = '0' : result = _id;
    return result;
  }
  void setID(String newID) {this._id = newID;}

  int getIndex() {
    int result;
    (_index == null) ? result = 0 : result = _index;
    return result;
  }
  void setIndex(int newIndex) {this._index = newIndex;}

  String getIDsubfamilia() {
    String result;
    (_idSubfamilia == null) ? result = '0' : result = _idSubfamilia;
    return result;
  }
  void setIDsubfamilia(String newID) {this._idSubfamilia = newID;}

  int getIndexsubfamilia() {
    int result;
    (_indexSubfamilia == null) ? result = 0 : result = _indexSubfamilia;
    return result;
  }

  void setIndexsubfamilia(int newIndex) {this._indexSubfamilia = newIndex;}

}

