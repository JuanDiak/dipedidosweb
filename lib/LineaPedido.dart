import 'Variables.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Api.dart';
import 'HistoricoLineasPedido.dart';
import 'Notificadores.dart';

final ctrl_comentario = TextEditingController();

class LineaPedido extends StatelessWidget {
  int idpedido;
  int numlin;
  int idarticulo;
  String articulo;
  double precio;
  double cantidad;
  String comentario;

  LineaPedido(this.idpedido, this.numlin, this.idarticulo, this.articulo,
      this.precio, this.cantidad, this.comentario) {
    idpedido = this.idpedido;
    numlin = this.numlin;
    idarticulo = this.idarticulo;
    articulo = this.articulo;
    precio = this.precio;
    cantidad = this.cantidad;
    comentario = this.comentario;
    ctrl_comentario.text = (comentario ?? "");
  }

  Elementos oBoton = Elementos();
  @override
  void dispose() {
    ctrl_comentario.dispose();
  }

  @override
  void initState() {
    //  ctrl_comentario.text = (comentario ?? "");
  }

  ModificarLinea(
      BuildContext context, double cantidad, String comentario) async {
    await dbHelper.ModificarLineaPedido(
        idpedido, numlin, cantidad, (precio * cantidad), comentario);
    Navigator.pop(context, 'OK');
  }

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<NotificarCantidad>();
    return Scaffold(
        backgroundColor: colorApp3, //Color(0xFF7A9BEE),
        appBar: AppBar(
          //gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios),
            color: colorletraApp, //Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          /*title: Text('Detalle',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.0,
                  color: Colors.white)),*/
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(children: [
            Stack(children: [
              Container(
                  height: MediaQuery.of(context).size.height - 82.0,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent),
              Positioned(
                  top: 40.0,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45.0),
                            topRight: Radius.circular(45.0),
                          ),
                          color: Colors.white),
                      height: MediaQuery.of(context).size.height - 100.0,
                      width: MediaQuery.of(context).size.width)),
              Positioned(
                  top: 100.0,
                  left: 25.0,
                  right: 25.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(articulo,
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(NumberFormat.simpleCurrency().format(precio),
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20.0,
                                  color: Colors.black)),
                          //Container(height: 25.0, color: Colors.grey, width: 1.0),
                          Container(
                            width: 125.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17.0),
                                color: colorApp3), //Color(0xFF7A9BEE)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    (counter.cantidad > 0 || API.varClienteDePrepago()==false)
                                        ? counter.addCantidad(-1)
                                        : null;
                                  },
                                  child: Container(
                                    height: 25.0,
                                    width: 25.0,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        color: colorApp3), //Color(0xFF7A9BEE)),
                                    child: Center(
                                      child: Icon(
                                        Icons.remove,
                                        color: colorletraApp, //Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Consumer<NotificarCantidad>(
                                    builder: (_, context, __) => Text(
                                        '${counter.cantidad}',
                                        style: TextStyle(
                                            color: colorletraApp, //Colors.white,
                                            fontFamily: 'Montserrat',
                                            fontSize: 18.0))),
                                InkWell(
                                  onTap: () {
                                    counter.addCantidad(1);
                                  },
                                  child: Container(
                                    height: 25.0,
                                    width: 25.0,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        color: colorletraApp),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: colorApp1, // Color(0xFF7A9BEE),
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 50.0),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                          child: TextField(
                            controller: ctrl_comentario,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: "comentario ...",
                              labelStyle: TextStyle(
                                color: colorApp1, //Color(0xFF7A9BEE),
                                fontStyle: FontStyle.italic,
                              ),
                              //hintText: "Inserte un comentario ...",
                              //hintStyle: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: colorApp1, // Color(0xFF7A9BEE),
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: colorApp1, //Color(0xFF7A9BEE),
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                     // SizedBox(height: 10.0),
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              oBoton.wBoton("Modificar",
                                  pAccion: () => {
                                        ModificarLinea(
                                            context,
                                            counter.cantidad,
                                            ctrl_comentario.text)
                                      }),
                            ],
                          )
                        ],
                      ))
                    ],
                  ))
            ])
          ]),
        ));
  }
}

class Elementos {
  MaterialButton wBoton(String pTexto, {Function pAccion}) {
    var oBoton = MaterialButton(
      onPressed: () {
        pAccion();
      },
      child: Text(pTexto, style: TextStyle(fontSize: 20)),
      textColor: colorletraApp, //Colors.white,
      color: colorApp3, //Color(0xFF7A9BEE),
      elevation: 5.0,
      shape: StadiumBorder(),
      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      highlightColor: colorApp3, //Colors.blueAccent,
    );
    return oBoton;
  }
}
