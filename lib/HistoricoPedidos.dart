import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Datos/PedidoCab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'HistoricoLineasPedido.dart';
import 'Utils/Dialogs.dart';
import 'rutas/SlideFromRightPageRoute.dart';
import 'Variables.dart';

List<PedidoCab> lista_Cab_Historico = [];
List<PedidoCab> lista_Enviados= [];
List<PedidoCab> lista_Guardados= [];
List<PedidoCab> lista= [];
List<PedidoCab> lista_Cab_Historico_ORIGINAL = [];
DBHelper dbHelper = DBHelper();
bool isLoading = true;
Color PrimaryColor = Color(0xff109618);

class WidgetHistorico extends StatefulWidget {
  int Enviados;
  WidgetHistorico({
    this.Enviados,
  });
  @override
  _WidgetHistoricoState createState() => _WidgetHistoricoState();
}

class _WidgetHistoricoState extends State<WidgetHistorico>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int Enviados;

  @override
  void initState() {
    super.initState();
    Enviados = widget.Enviados;
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.animateTo((Enviados == 1) ? 0 : 1);
    LoadCabeceraPedido();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Null> LoadCabeceraPedido() async {
    await dbHelper.getPedidosHistorico('PedidoCab_Hist', 2).then((response) {
      lista_Cab_Historico = response;
      setState(() {
        lista_Cab_Historico_ORIGINAL = lista_Cab_Historico;
        isLoading = false;
      });
    });
    //---------------------------------------------------------------
    lista_Cab_Historico_ORIGINAL=lista_Cab_Historico;
    lista_Enviados = lista_Cab_Historico.where((i) => i.fechaenvio != null).toList();     //ENVIADOS
    //---------------------------------------------------------------
    lista_Cab_Historico=lista_Cab_Historico_ORIGINAL;
    lista_Guardados = lista_Cab_Historico.where((i) => i.fechaenvio == null).toList();    //GUARDADOS
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            bottomNavigationBar: Material(
              color: colorBoton,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.orange,
                indicatorWeight: 6.0,
                onTap: (index) async {},
                tabs: [
                  Tab(
                    child: Container(
                      child: Text(
                        'PEDIDOS',
                        style: TextStyle(color: colorletraBoton, fontSize: 18.0),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      // SIN ENVIAR
                      child: Text(
                        'GUARDADOS',
                        style: TextStyle(color: colorletraBoton, fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                Listado(
                  tab: 0,
                ), //ff5722
                Listado(
                  tab: 1,
                ), //ff5722
              ],
            ));
  }
}

class Listado extends StatefulWidget {
  int tab;
  Listado({
    this.tab,
  });

  @override
  _ListadoState createState() => _ListadoState();
}

class _ListadoState extends State<Listado> {
  //(widget.tab == 0) //ENVIADOS
  //(widget.tab == 1) //GUARDADOS
  @override
  Widget build(BuildContext context) {
      return Column(children: [
      Expanded(
        child: ListView.builder(
            itemCount:
                  (widget.tab == 0)?
                  (lista_Enviados == null) ? 0 : lista_Enviados.length:
                  (lista_Guardados == null) ? 0 : lista_Guardados.length,
            itemBuilder: (context, index) {
              return
                  Card(
                      child: (widget.tab == 1 && lista_Guardados.length > 0)
                          ? Dismissible(
                              key: UniqueKey(),
                              onDismissed: (direction) async {
                                int idpedido = lista_Guardados[index].id;
                                var result = await Dialogs.Dialogo(
                                    context,
                                    'BORRANDO...',
                                    '¿ Quieres borrar el pedido Nº $idpedido ?',
                                    'SiNo',
                                    '');
                                if (result == 'Si') {
                                  await dbHelper
                                      .deletePedidoCabHistorico(idpedido);
                                  await dbHelper
                                      .getPedidosHistorico('PedidoCab_Hist', 2)
                                      .then((response) {
                                    lista_Cab_Historico = response;
                                    lista_Guardados = lista_Cab_Historico.where((i) => i.fechaenvio == null).toList();    //GUARDADOS
                                  });
                                  setState(() {});
                                }else{
                                  setState(() {});
                                }
                              },
                              background: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('eliminar pedido...',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  color: Colors.red[700]),
                              child: WidgetItem(index,lista_Guardados),
                            )
                          : WidgetItem(index, lista_Enviados),
                    );
            }),
      ),
    ]);
  }
}

class WidgetItem extends StatelessWidget {
  int index;
  var lista;
  WidgetItem(int index, var lista) {
    this.index = index;
    this.lista = lista;
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        child: (lista.length > 0)
            ? Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Text(
                    (lista[index].licencia ?? "") ,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Text(
                        'Nº ' + (lista[index].id.toString() ?? ""),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: (lista[index].fechaenvio == null)
                          ? Text(
                        lista[index].nombrepedido ?? '',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            )
                          : Icon(
                              Icons.cloud_upload,
                              color: Colors.blueAccent,
                            ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Text(
                        '${NumberFormat.simpleCurrency().format(lista[index].importetotal)}',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: <Widget>[
                        Text(
                          lista[index].fecha ?? "",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Roboto',
                            //fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    (lista[index].fechaservicio!=null) ? Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ENTREGA ',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontFamily: 'Roboto',
                              color: Colors.black45,
                              //fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Text(
                          lista[index].fechaservicio ?? "",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Roboto',
                            //fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ): SizedBox.shrink(),
                  ],
                ),
              ])
            : null,
      ),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String licencia = (prefs.getString('licencia') ?? "");
        bool permitir_add=true;
        if (licencia!= lista[index].licencia) permitir_add=false;
        await Navigator.push(
            context,
            SlideFromRightPageRoute(
                widget: WidgetHistoricoDetalle(lista[index].id,permitir_add)));
      },
    );
  }
}
