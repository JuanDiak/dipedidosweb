import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Principal.dart';
import 'Variables.dart';

//bool isLoading = true;
Color PrimaryColor = Color(0xff109618);

class WidgetTiendasRecogida extends StatefulWidget {
  WidgetTiendasRecogida();
  @override
  _WidgeTiendasRecogidaState createState() => _WidgeTiendasRecogidaState();
}
class _WidgeTiendasRecogidaState extends State<WidgetTiendasRecogida>{
  int Enviados;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose(){
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        title: Text('TIENDAS DE RECOGIDA',style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        )),
        gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
      ),
      body: // (isLoading)? Center(child: CircularProgressIndicator()):
      Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount:
                (lista_Remotos_WebS == null) ? 0 : lista_Remotos_WebS.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                        leading: Icon(Icons.store, color: colorBoton, size: 54,),
                        title: WidgetItem(index),
                        subtitle: Text(lista_Remotos_WebS[index].textoTiendaWeb??'',),
                        onTap: (){
                          Navigator.pop(context, lista_Remotos_WebS[index]);
                        },
                      ));
                }),
          ),
        ],
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class WidgetItem extends StatelessWidget {
  int index;
  WidgetItem(int index) {
    this.index = index;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                lista_Remotos_WebS[index].nombreTienda ?? '',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Roboto',
                  color: colorBoton,//Color.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                lista_Remotos_WebS[index].domicilio ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                  //color: Colors.blue,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lista_Remotos_WebS[index].codPostal,
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Roboto',
                //color: Colors.white,
                //fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              lista_Remotos_WebS[index].poblacion,
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ]),
    );
  }
}