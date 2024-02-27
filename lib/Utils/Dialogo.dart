import 'package:flutter/material.dart';
//DIALOGO BONITO**************************
class ExitConfirmationDialog extends StatelessWidget {
  String mensaje1;
  String mensaje2;
  String opcion;
  final ctrl_TextField = TextEditingController();

  ExitConfirmationDialog({this.mensaje1, this.mensaje2, this.opcion});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 370,
        decoration: BoxDecoration(
            color: Colors.green, //Colors.redAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              mensaje1,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Text(
                      mensaje2,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                (opcion == 'Aceptar') ? wAceptar(context) : wSino(context)
              ],
            )
          ],
        ),
      );
}

Widget wAceptar(context) {
  return TextButton(
    onPressed: () {
      return Navigator.of(context).pop(true);
    },
    style: TextButton.styleFrom(
        padding: EdgeInsets.fromLTRB(20, 0 ,20, 0),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    ),
    child: Text('Aceptar', style: TextStyle(
      color: Colors.green,
      fontSize: 15,
    ),),
  );
}

Widget wSino(context) {
  return Row(
    children: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.fromLTRB(20, 0 ,20, 0),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        child: Text('No',
        style: TextStyle(
           color: Colors.white,
           ),
        ),

      ),
      SizedBox(
        width: 8,
      ),
      ElevatedButton(
        onPressed: () {
          return Navigator.of(context).pop(true);
        },
        child: Text('Sí',
        style: TextStyle(
          //backgroundColor: Colors.white,
          color: Colors.white,
        ),
        ),
      ),
    ],
  );
}

class DialogHelper {
  static exit(context, mensaje1, mensaje2, opcion) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExitConfirmationDialog(
            mensaje1: mensaje1,
            mensaje2: mensaje2,
            opcion: opcion,
          ));
}
