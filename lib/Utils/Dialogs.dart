import 'package:flutter/material.dart';

import '../Variables.dart';

//enum DialogoAction { Si, No }
final ctrl_TextField = TextEditingController();

class Dialogs {

  static botones_SiNo(context, botonDefecto) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (botonDefecto==1)?
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('Si'),
                child: Text('SI'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('No'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'NO',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
              :
          Row(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop('Si'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'SI',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('No'),
                child: Text('NO'),
              ),
            ],
          )
        ],
      ),
    );
  }

  static botones_OK(context) {
    return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(begin: Alignment.centerRight, colors: [
                colorBoton, colorBoton,
                //Colors.blue[600],
                //Colors.blue[700]
              ])), //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            onPressed: () {
              String value =ctrl_TextField.text;
              ctrl_TextField.text='';
              Navigator.of(context).pop(value);
            },
            child: Text("OK",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: colorletraBoton, //Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ));
  }

  static Future<String> Dialogo(
      BuildContext context, String title, String body, String opcion, String tipo) async {
      final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title), //,textAlign: TextAlign.center,
          content: (tipo == 'TextField')
              ? Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Text(body),
                    SizedBox(height: 15,)  ,
                    TextField(
                        controller: ctrl_TextField,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color:colorApp1 , width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: colorApp1, width: 1.0),
                          ),
                          hintText: 'Escribe aquí...',
                        )),
                  ],
                ),
              )
              : Text(body),
          //backgroundColor: Colors.orange[300],
          actions: [
            (opcion == 'OK')
                ? botones_OK(context)
                : botones_SiNo(context, 1),
          ],
        );
      },
    );
    return (action != null) ? action : 'No';
  }
}
