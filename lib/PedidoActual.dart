import 'dart:convert';
import 'RealizarPedido.dart';
import 'rutas/Scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'Datos/Articulos.dart';
import 'Datos/PedidoCab.dart';
import 'Datos/PedidoLin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'Api.dart';
import 'LineaPedido.dart';
import 'Notificadores.dart';
import 'Principal.dart';
import 'Variables.dart';

List<PedidoLin> lista_pedidoLin = [];
List<PedidoCab> lista_pedidoCab = [];
DBHelper dbHelper = DBHelper();
bool isLoading;

class WidgetPedido extends StatefulWidget {
  final List<Articulos> lista_articulos_add;
  WidgetPedido(this.lista_articulos_add);
  @override
  _WidgetPedidoState createState() => _WidgetPedidoState();
}

class _WidgetPedidoState extends State<WidgetPedido> {
  @override
  void initState() {
    super.initState();
    isLoading = true;
    CargarPedido();
  }
  CargarPedido() async {
    await LoadPedido();
    if (widget.lista_articulos_add != null &&
        widget.lista_articulos_add.length != 0) {
      await AddLineas(widget.lista_articulos_add);
    }
    isLoading = false;
    setState(() {});
  }

  Widget BotonRealizarPedido() {
    return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(50.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  colors: [colorBoton, colorBoton])),
          //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            onPressed: () async {
              if (pComprobacionesGuardarPedido(context) == 'OK') {
                final result=await Navigator.push(context,ScaleRoute(page: Realizarpedido(total: lista_pedidoCab[0].importetotal,),ms: 500));
                if (result=='OK'){
                  opcion = '';
                  context.read<ChangePage>().setPage('Historico');
                }
              }
            },
            child: Text("REALIZAR PEDIDO",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: colorletraBoton,
                    fontWeight: FontWeight.bold)),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Center(child: CircularProgressIndicator())
        : Column(children: [
            Expanded(
              child: ListView.builder(
                  itemCount:
                      (lista_pedidoLin == null) ? 0 : lista_pedidoLin.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction)  async {
                          await DeleteLinea(context, index);
                          setState(() {});
                        },
                        background: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('eliminar linea...',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            color: Colors.red[700]),
                        child: ListTile(
                          title: WidgetItem(index),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider(
                                          create: (_) => NotificarCantidad(
                                              cantidad: lista_pedidoLin[index].cantidad),
                                          child: LineaPedido(
                                              1,
                                              lista_pedidoLin[index].numLin,
                                              lista_pedidoLin[index].idArticulo,
                                              lista_pedidoLin[index].articulo,
                                              lista_pedidoLin[index].precio,
                                              lista_pedidoLin[index].cantidad,
                                              lista_pedidoLin[index]
                                                  .comentario),
                                        )));
                            if (result != null) {
                              await LoadlistLineasPedido();
                              await GrabarCabeceraPedido();
                              await LoadlistCabeceraPedido();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    );
                  }),
            ),
            Container(
                child: Divider(
              height: 5,
            )),
            BotonRealizarPedido(),
            Container(
                child: Divider(
              height: 5,
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      '${NumberFormat.simpleCurrency().format(lista_pedidoCab[0].importetotal)}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24.0,
                        color: Color(0xFF0F538F),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ]);
  }
}

class WidgetItem extends StatelessWidget {
  int index;
  WidgetItem(int index) {
    this.index = index;
  }
  @override
  Widget build(BuildContext context) {
    var item;
    var itemImagenArticulo = lista_imagenesArticulos_WebS.firstWhere(
        (obj) => obj.idArticulo == lista_pedidoLin[index].idArticulo,
        orElse: () => null);
    if (itemImagenArticulo == null) {
      var itemArticulo = lista_articulos_WebS.firstWhere(
          (obj) => obj.idArticulo == lista_pedidoLin[index].idArticulo,
          orElse: () => null);
      if (itemArticulo!=null) {
        item = lista_imagenesSubFamilias_WebS.firstWhere(
                (obj) => obj.idsubFamilia == itemArticulo.idSubFamilia,
            orElse: () => null);
      }
    } else
      item = itemImagenArticulo;
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
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
                          )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          '${lista_pedidoLin[index].articulo}', //${lista_pedidoLin[index].idArticulo} -
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            flex: 2,
                            child: Text(
                              '      ' +
                                  NumberFormat().format(lista_pedidoLin[index]
                                      .cantidad), // 123.456,00 €
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
                                  .format(lista_pedidoLin[index].precio),
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
                                  .format(lista_pedidoLin[index].importe),
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
                      (lista_pedidoLin[index].comentario != null &&
                              lista_pedidoLin[index].comentario != '')
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  child: Text(
                                    lista_pedidoLin[index].comentario ?? '',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Roboto',
                                      color: Colors.grey[800],
                                      //fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}

List<PedidoCab> listaPedidoCab() {
  return lista_pedidoCab;
}
List<PedidoLin> listaPedidoLin() {
  return lista_pedidoLin;
}

Future EnviarAlbaran(_GastosEnvioCargados, _IDRemoto, _ImportePagado, Hora) async {
  var result;
  try {
    await API.xSendAlbaran(lista_pedidoCab, lista_pedidoLin, _GastosEnvioCargados, _IDRemoto, _ImportePagado, Hora)
        .then((response) async {
      if (response.statusCode == 200) {
        int IDAlbaranServer = int.parse(response.body.toString());
        if (IDAlbaranServer > 0) {
          if (Hora!='') lista_pedidoCab[0].fechaservicio = lista_pedidoCab[0].fechaservicio + ' ' + Hora;
          await dbHelper.ModificarCabeceraPedido(
              1, lista_pedidoCab[0].importetotal, lista_pedidoCab[0].fechaservicio, DateTime.now().toString());
          await dbHelper.TransferPedido_A_Historico();
          print('IDSERVER: $IDAlbaranServer');
          result = 'OK';
        }
      }
    });
  } catch (e) {}
  return result;
}

Future ComprobarStockAlbaran(_IDRemoto) async {
  var result='OK';
  String n = String.fromCharCode(13) + String.fromCharCode(10);
  try {
    await API.StockAlbaran(lista_pedidoCab, lista_pedidoLin, _IDRemoto).then((response) async {
      List<ArticulosLin_Stock> lista_ArticulosLin_Stock_WebS = [];
      if (response.statusCode == 200) {
          var lista = response.body.toString();
          if (lista!='') {
            Iterable list = json.decode(lista);
            if (list.length > 0) {
              lista_ArticulosLin_Stock_WebS =list.map((model) => ArticulosLin_Stock.fromJson(model)).toList();
              if (lista_ArticulosLin_Stock_WebS.length>0){
                result='Producto agotado: ' + '$n';
                for (var x = 0; x < lista_ArticulosLin_Stock_WebS.length; x++) {
                  result=result + lista_ArticulosLin_Stock_WebS[x].articulo + ' quedan ${lista_ArticulosLin_Stock_WebS[x].stock} ' + '$n';
                }
              }
            }
          }
      }
    });
  } catch (e) {}
  return result;
}

Future ComprobarPreparacionHoraDisponible(_IDRemoto, Hora) async {
  var result='OK';
  //String n = String.fromCharCode(13) + String.fromCharCode(10);
  try {
    await API.PreparacionHoraDisponible(lista_pedidoCab, lista_pedidoLin, _IDRemoto, Hora).then((response) async {
      //var lista_ArticulosLin_Stock_WebS = List<ArticulosLin_Stock>();
      if (response.statusCode == 200) {
        if (response.body.toString()=='false'){
          result='false';
        }
      }
    });
  } catch (e) {}
  return result;
}

Future<Null> LoadPedido() async {
  await LoadlistCabeceraPedido();
  await LoadlistLineasPedido();
}
Future<Null> LoadlistLineasPedido() async {
  await dbHelper.getLineasPedido('PedidoLin', 0).then((response) {
    lista_pedidoLin = response;
    if (lista_pedidoLin != null) {
      print('[lista_pedidoLin] Nº LINEAS: ${lista_pedidoLin.length}');
    }
    return null;
  });
}
Future<Null> LoadlistCabeceraPedido() async {
  await dbHelper.getCabeceraPedido('PedidoCab').then((response) {
    lista_pedidoCab = response;
    if (response == null) {
      lista_pedidoCab.add(PedidoCab(
          id: 1,
          fecha: ObtenerFechaActual(),
          fechaservicio: ObtenerFechaActual(),
          importetotal: 0));
    }
    print('[lista_pedidoCab LONGITUD] ${lista_pedidoCab.length}: Success');
  });
  return null;
}
GrabarCabeceraPedido() async {
  lista_pedidoCab[0].importetotal = CalcularImporteTotal();
  await dbHelper.deletePedidoCab('PedidoCab', 1);
  await dbHelper.savePedidoCab(
      'PedidoCab',
      1,
      ObtenerFechaActual(),
      lista_pedidoCab[0].fechaservicio,
      '',
      lista_pedidoCab[0].importetotal,
      lista_pedidoCab[0].fechaenvio,
      lista_pedidoCab[0].nombrepedido,
  );
}

Future<void> AddLineas(List<Articulos> lista) async {
  await LoadlistLineasPedido();
  int numlin = (lista_pedidoLin == null) ? 0 : lista_pedidoLin.length;
  bool EnPromocion=false;
  for (var x = 0; x < lista.length; x++) {
    if (lista[x].cantidad != 0) {
      EnPromocion= (lista[x].precioPromocion != 0 && lista[x].precioPromocion < lista[x].precioCliente);
      double precio = (EnPromocion) ? lista[x].precioPromocion : lista[x].precioCliente;
      double cantidad = lista[x].cantidad;
      double importe = cantidad * precio;
      numlin += 1;
      dbHelper.savePedidoLin(
        'PedidoLin',
        1,
        numlin,
        lista[x].idArticulo,
        lista[x].articulo,
        precio,
        cantidad,
        importe,
        lista[x].observacion,
      );
    }
    //lista[x].cantidad = 0;
  }
  await LoadlistLineasPedido();
  await GrabarCabeceraPedido();
  LoadPedido();
}
Future<void> DeleteLinea(BuildContext context, int numLin) async {
  lista_pedidoLin.removeAt(numLin);
  for (var x = numLin; x < lista_pedidoLin.length; x++) {
    lista_pedidoLin[x].numLin = lista_pedidoLin[x].numLin - 1;
  }
  dbHelper.deletePedidoLin('PedidoLin');
  for (var x = 0; x < lista_pedidoLin.length; x++) {
    dbHelper.savePedidoLin(
        'PedidoLin',
        1,
        lista_pedidoLin[x].numLin,
        lista_pedidoLin[x].idArticulo,
        lista_pedidoLin[x].articulo,
        lista_pedidoLin[x].precio,
        lista_pedidoLin[x].cantidad,
        lista_pedidoLin[x].importe,
        lista_pedidoLin[x].comentario);
  }
  await GrabarCabeceraPedido();
  LoadPedido();
}

ObtenerFechaActual() {
  String FechaActual;
  var formatter = DateFormat('dd-MM-yyyy');
  FechaActual = formatter.format(DateTime.now());
  return FechaActual;
}
double CalcularImporteTotal() {
  double importetotal = 0;
  if (lista_pedidoLin != null) {
    for (var x = 0; x < lista_pedidoLin.length; x++) {
      importetotal += lista_pedidoLin[x].importe;
    }
    lista_pedidoCab[0].importetotal = importetotal;
  }
  return importetotal;
}
