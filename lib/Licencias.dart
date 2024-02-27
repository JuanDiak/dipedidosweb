import 'dart:convert';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utils/Dialogs.dart';
import 'Variables.dart';

class WidgetLicencias extends StatefulWidget {
  @override
  _WidgetLicenciasState createState() => _WidgetLicenciasState();
}

class _WidgetLicenciasState extends State<WidgetLicencias> {
  String licencia1,
      licencia2,
      licencia3,
      licencia4,
      licencia5,
      licencia6,
      licencia7,
      licencia8,
      licencia9,
      licencia10;
  String nombreTienda1,
      nombreTienda2,
      nombreTienda3,
      nombreTienda4,
      nombreTienda5,
      nombreTienda6,
      nombreTienda7,
      nombreTienda8,
      nombreTienda9,
      nombreTienda10;
  String logo1, logo2, logo3, logo4, logo5, logo6, logo7, logo8, logo9, logo10;
  bool isLoading = true;
  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    licencia1 = (prefs.getString('licencia1') ?? "");
    licencia2 = (prefs.getString('licencia2') ?? "");
    licencia3 = (prefs.getString('licencia3') ?? "");
    licencia4 = (prefs.getString('licencia4') ?? "");
    licencia5 = (prefs.getString('licencia5') ?? "");
    licencia6 = (prefs.getString('licencia6') ?? "");
    licencia7 = (prefs.getString('licencia7') ?? "");
    licencia8 = (prefs.getString('licencia8') ?? "");
    licencia9 = (prefs.getString('licencia9') ?? "");
    licencia10 = (prefs.getString('licencia10') ?? "");
    nombreTienda1 = (prefs.getString('nombreTienda1') ?? licencia1);
    nombreTienda2 = (prefs.getString('nombreTienda2') ?? licencia2);
    nombreTienda3 = (prefs.getString('nombreTienda3') ?? licencia3);
    nombreTienda4 = (prefs.getString('nombreTienda4') ?? licencia4);
    nombreTienda5 = (prefs.getString('nombreTienda5') ?? licencia5);
    nombreTienda6 = (prefs.getString('nombreTienda6') ?? licencia6);
    nombreTienda7 = (prefs.getString('nombreTienda7') ?? licencia7);
    nombreTienda8 = (prefs.getString('nombreTienda8') ?? licencia8);
    nombreTienda9 = (prefs.getString('nombreTienda9') ?? licencia9);
    nombreTienda10 = (prefs.getString('nombreTienda10') ?? licencia10);
    logo1 = (prefs.getString('logo1') ?? "");
    logo2 = (prefs.getString('logo2') ?? "");
    logo3 = (prefs.getString('logo3') ?? "");
    logo4 = (prefs.getString('logo4') ?? "");
    logo5 = (prefs.getString('logo5') ?? "");
    logo6 = (prefs.getString('logo6') ?? "");
    logo7 = (prefs.getString('logo7') ?? "");
    logo8 = (prefs.getString('logo8') ?? "");
    logo9 = (prefs.getString('logo9') ?? "");
    logo10 = (prefs.getString('logo10') ?? "");

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isLoading = true;
    _LeerPreferencias();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NewGradientAppBar(
          title: Text('LICENCIAS',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              )),
          gradient: LinearGradient(
              colors: [colorApp1, colorApp2, colorApp3]),
        ),
        body: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.all(8.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    (licencia1 != '')
                        ? MyMenu(
                            titulo: nombreTienda1,
                            textoLicencia: licencia1,
                            imagen: logo1,
                            icono: Icons.store,
                            warna: Colors.deepPurple,
                            licencia: 1)
                        : SizedBox.shrink(),
                    (licencia2 != '')
                        ? MyMenu(
                            titulo: nombreTienda2,
                            textoLicencia: licencia2,
                            imagen: logo2,
                            icono: Icons.store,
                            warna: Colors.blue,
                            licencia: 2)
                        : SizedBox.shrink(),
                    (licencia3 != '')
                        ? MyMenu(
                            titulo: nombreTienda3,
                            textoLicencia: licencia3,
                            imagen: logo3,
                            icono: Icons.store,
                            warna: Colors.orange,
                            licencia: 3)
                        : SizedBox.shrink(),
                    (licencia4 != '')
                        ? MyMenu(
                            titulo: nombreTienda4,
                            textoLicencia: licencia4,
                            imagen: logo4,
                            icono: Icons.store,
                            warna: Colors.blueGrey,
                            licencia: 4)
                        : SizedBox.shrink(),
                    (licencia5 != '')
                        ? MyMenu(
                            titulo: nombreTienda5,
                            textoLicencia: licencia5,
                            imagen: logo5,
                            icono: Icons.store,
                            warna: Colors.red,
                            licencia: 5)
                        : SizedBox.shrink(),
                    (licencia6 != '')
                        ? MyMenu(
                            titulo: nombreTienda6,
                            textoLicencia: licencia6,
                            imagen: logo6,
                            icono: Icons.store,
                            warna: Colors.indigo,
                            licencia: 6)
                        : SizedBox.shrink(),
                    (licencia7 != '')
                        ? MyMenu(
                            titulo: nombreTienda7,
                            textoLicencia: licencia7,
                            imagen: logo7,
                            icono: Icons.store,
                            warna: Colors.lightGreen,
                            licencia: 7)
                        : SizedBox.shrink(),
                    (licencia8 != '')
                        ? MyMenu(
                            titulo: nombreTienda8,
                            textoLicencia: licencia8,
                            imagen: logo8,
                            icono: Icons.store,
                            warna: Colors.blue,
                            licencia: 8)
                        : SizedBox.shrink(),
                    (licencia9 != '')
                        ? MyMenu(
                            titulo: nombreTienda9,
                            textoLicencia: licencia9,
                            imagen: logo9,
                            icono: Icons.store,
                            warna: Colors.pink,
                            licencia: 9)
                        : SizedBox.shrink(),
                    (licencia10 != '')
                        ? MyMenu(
                            titulo: nombreTienda10,
                            textoLicencia: licencia10,
                            imagen: logo10,
                            icono: Icons.store,
                            warna: Colors.lightGreen,
                            licencia: 10)
                        : SizedBox.shrink(),
                  ],
                ),
              ));
  }
}

class MyMenu extends StatelessWidget {
  MyMenu(
      {this.titulo,
      this.textoLicencia,
      this.imagen,
      this.icono,
      this.warna,
      this.licencia});
  final String titulo;
  final String textoLicencia;
  final String imagen;
  final IconData icono;
  final MaterialColor warna;
  final int licencia;

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onLongPress: () async {
            var result = await Dialogs.Dialogo(context, 'BORRAR LICENCIA',
                'Va a borrar esta Licencia, ¿ estás seguro ?', 'SiNo', '');
            Navigator.of(context).pop();
            if (result == 'Si') {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('licencia$licencia', '');
              await prefs.setString('nombreTienda$licencia', '');
            }
          },
          onTap: () {
            Navigator.pop(context, textoLicencia);
          },
          splashColor: Colors.green,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (imagen == '')
                    ? Icon(icono, size: 100.0, color: warna)
                    : SizedBox(
                      height: 100,
                      child: Image.memory(
                          base64Decode(imagen),
                          scale: 1.0,
                        ),
                    ),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
