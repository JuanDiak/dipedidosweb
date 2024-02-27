import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'Datos/PedidoLin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'Notificadores.dart';
import 'Principal.dart';
import 'Variables.dart';

List<PedidoLin> lista_Lin_Historico = [];
DBHelper dbHelper = DBHelper();
bool isLoading = true;

class WidgetHistoricoDetalle extends StatefulWidget {
  final int IDPedido;
  final bool permitir_add;
  WidgetHistoricoDetalle(this.IDPedido, this.permitir_add);
  @override
  _WidgetHistoricoDetalleState createState() => _WidgetHistoricoDetalleState();
}

class _WidgetHistoricoDetalleState extends State<WidgetHistoricoDetalle> {
  _WidgetHistoricoDetalleState() {}
  @override
  void initState() {
    super.initState();
    LoadLineasPedido();
  }

  Future<Null> LoadLineasPedido() async {
    await dbHelper.getLineasPedido('PedidoLin_Hist', widget.IDPedido).then((response) {
      lista_Lin_Historico = response;
      if (lista_Lin_Historico != null) {
        print(
            '[lista_Lin_Historico LONGITUD] ${lista_Lin_Historico.length}: Success');
      } else {
        print('[lista_Lin_Historico NULL]');
      }
    });
    setState(() {});
    isLoading = false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NewGradientAppBar(
          gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
          title: Text('DETALLES DEL PEDIDO',style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          )),
        ),
        body:  Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount:
                  (lista_Lin_Historico == null) ? 0 : lista_Lin_Historico.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: ListTile(
                          title: WidgetItem(index, widget.permitir_add),
                        ));
                  }),
            ),
          ],
        ),
      floatingActionButton:
      (widget.permitir_add)? FloatingActionButton.extended(
        elevation: 10.0,
        onPressed: () async {
          await dbHelper.TransferHistorico_A_Pedido();
          context.read<ChangePage>().setPage('Pedido');
          Navigator.pop(context, 'OK');
        },
        backgroundColor: colorBoton, //Colors.blue[700],
        label: Text('Añadir al Pedido Actual...', style: TextStyle(color: colorletraBoton )),
        icon: Icon(
          Icons.add,
          color: colorletraBoton, //Colors.white,
          size: 30.0,
        ),
      ):SizedBox.shrink(),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class WidgetItem extends StatelessWidget {
  int index;
  bool permitirAdd;
  WidgetItem(int index, bool permitirAdd) {
    this.index = index;
    this.permitirAdd = permitirAdd;
  }
  @override
  Widget build(BuildContext context) {
    var item;
    var itemImagenArticulo = lista_imagenesArticulos_WebS.firstWhere(
            (obj) => obj.idArticulo == lista_Lin_Historico[index].idArticulo,
        orElse: () => null);
    if (itemImagenArticulo == null) {
      var itemArticulo =  lista_articulos_WebS.firstWhere(
              (obj) => obj.idArticulo == lista_Lin_Historico[index].idArticulo,
          orElse: () => null);
      if (itemArticulo!=null) {
        item = lista_imagenesSubFamilias_WebS.firstWhere(
                (obj) =>
            obj.idsubFamilia == itemArticulo.idSubFamilia,
            orElse: () => null);
      }
    }else item=itemImagenArticulo;
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (permitirAdd)?Container(
                    width: 50,
                    height: 50,
                    child: (item == null)
                        ? Image.asset(
                      rutaArticulo,
                      fit: BoxFit.contain,
                    )
                        : Image.memory(
                      base64Decode(item.imagenbase64),
                      scale: 1.0,
                      width: 80.0,
                      height: 80.0,
                    )):SizedBox.shrink(),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          '${lista_Lin_Historico[index].articulo}', //${lista_pedidoLin[index].idArticulo} -
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 8,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            child: Text('      '+
                                NumberFormat()
                                    .format(lista_Lin_Historico[index].cantidad), // 123.456,00 €
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              NumberFormat.simpleCurrency()
                                  .format(lista_Lin_Historico[index].precio),
                              // 123.456,00 €
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              NumberFormat.simpleCurrency()
                                  .format(lista_Lin_Historico[index].importe),
                              // 123.456,00 €
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      (lista_Lin_Historico[index].comentario!=null && lista_Lin_Historico[index].comentario!='' )?
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8,),
                          Container(
                            child: Text(
                              lista_Lin_Historico[index].comentario ?? '',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'Roboto',
                                color: Colors.grey[800],
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ):SizedBox.shrink(),
                    ],
                  ),
                ),

              ],
            ),

          ]),
    );
  }
}

