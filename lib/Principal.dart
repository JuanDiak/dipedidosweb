import 'dart:convert';
import 'dart:io';
import 'ColorConfiguracion.dart';
import 'DataSearch.dart';
import 'Datos/Remotos.dart';
import 'DireccionEnvio.dart';
import 'HistoricoPedidos.dart';
import 'ListaArticulos.dart';
import 'Login.dart';
import 'Registro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'Datos/Articulos.dart';
import 'DatabaseHelper.dart';
import 'Notificadores.dart';
import 'PedidoActual.dart';
//import 'Utils/Dialogo.dart';
import 'Utils/Dialogs.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'Variables.dart';

DBHelper dbHelper = DBHelper();
List<Articulos> lista_articulos_WebS = [];
List<Familias> lista_familias_WebS = [];
List<SubFamilias> lista_subfamilias_WebS = [];
List<ArticulosImagenes> lista_imagenesArticulos_WebS = [];
List<FamiliasImagenes> lista_imagenesFamilias_WebS = [];
List<SubFamiliasImagenes> lista_imagenesSubFamilias_WebS = [];
List<INI> lista_ini_WebS = [];
List<Remotos> lista_Remotos_WebS = [];

Variables clase = Variables();
String rutaArticulo = 'assets/articulo.png';
String rutaFamilia = 'assets/familia.png';

String opcion = 'add';
bool isLoading;
bool isSending = false;
int numlineas = 0;
int lineasadd = 0;
String progressString;
bool Articulos_OK = false;
bool Familias_OK = false;
bool SubFamilias_OK = false;
bool SubFamiliasImagenes_OK = false;
bool ArticulosImagenes_OK = false;
String PaisMoneda;
String VarSistemaPais;

String licencia;
var nombreTienda = '';
String Logoimagenbase64 = '';
bool administrador = false;
String ResolucionImagenesSecundarias;
String ResolucionImagenes;

Future<String> findSystemLocale() {
  try {
    Intl.systemLocale =
        Intl.canonicalizedLocale(PaisMoneda); //Platform.localeName
  } catch (e) {
    return new Future.value();
  }
  return new Future.value(Intl.systemLocale);
}

LeerPreferencias() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  licencia = (prefs.getString('licencia') ?? "");
  colorApp1 = Colors.blue[900];
  colorApp2 = Colors.blue[800];
  colorApp3 = Colors.blue[600];
  colorBoton = Colors.blue[600];
  colorletraBoton = Colors.white;
  colorletraApp = Colors.white;
  if (prefs.getString('colorApp1') != null)
    colorApp1 = Color(int.parse(prefs.getString('colorApp1')));
  if (prefs.getString('colorApp2') != null)
    colorApp2 = Color(int.parse(prefs.getString('colorApp2')));
  if (prefs.getString('colorApp3') != null)
    colorApp3 = Color(int.parse(prefs.getString('colorApp3')));
  if (prefs.getString('colorBoton') != null)
    colorBoton = Color(int.parse(prefs.getString('colorBoton')));
  if (prefs.getString('colorletraBoton') != null)
    colorletraBoton = Color(int.parse(prefs.getString('colorletraBoton')));
  if (prefs.getString('colorletraApp') != null)
    colorletraApp = Color(int.parse(prefs.getString('colorletraApp')));

  //nombreTienda = (prefs.getString('nombreTienda') ?? "");*/
}
GrabarPreferencias() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('colorApp1', colorApp1.value.toString());
  await prefs.setString('colorApp2', colorApp2.value.toString());
  await prefs.setString('colorApp3', colorApp3.value.toString());
  await prefs.setString('colorBoton',colorBoton.value.toString());
  await prefs.setString('colorletraBoton', colorletraBoton.value.toString());
  await prefs.setString('colorletraApp',colorletraApp.value.toString());
}
Future<void> getINI() async {
  await API.getINI().then((response) async {
    var lista = response.body.toString();
    Iterable list = json.decode(lista);
    if (list.length > 0) {
      lista_ini_WebS = list.map((model) => INI.fromJson(model)).toList();
      //---------------------------------------------------
      var item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPPermitirVenderSinStock",
          orElse: () => null);
      if (item != null)
        API.SetPermitirVenderSinStock((item.valor == 'No') ? 'No' : 'Si');
      else
        API.SetPermitirVenderSinStock('Si');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPTextoNoDisponible",
          orElse: () => null);
      if (item != null) API.SetTextoNoDisponible(item.valor??'');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPNoPermitirEnvioDomicilio",
          orElse: () => null);
      if (item != null) API.SetPermitirEnvioDomicilio((item.valor == 'Si') ? false : true);
      //---------------------------------------------------
      /*item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPHoraMaxPedidos",
          orElse: () => null);*/
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPGastosEnvio",
          orElse: () => null);
      if (item != null)
        API.SetGastosEnvio(item.valor);
      else
        API.SetGastosEnvio('0');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPIDArticuloGastosEnvio",
          orElse: () => null);
      if (item != null)
        API.SetIDGastosEnvio(int.parse(item.valor));
      else
        API.SetIDGastosEnvio(0);
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPImporteMinimoEnvio",
          orElse: () => null);
      if (item != null)
        API.SetImporteMinimoParaEnvio(double.parse(item.valor));
      else
        API.SetImporteMinimoParaEnvio(0);
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPPctImporteMinimoPagar",
          orElse: () => null);
      if (item != null)
        API.SetPctImporteMinimoPagar(double.parse(item.valor));
      else
        API.SetPctImporteMinimoPagar(0);
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPRecogidaHoraInicio",
          orElse: () => null);
      if (item != null)
        API.SetRecogidaHoraInicio(item.valor);
      else
        API.SetRecogidaHoraInicio('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPRecogidaHoraFin",
          orElse: () => null);
      if (item != null)
        API.SetRecogidaHoraFin(item.valor);
      else
        API.SetRecogidaHoraFin('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPRecogidaHoraIntervalo",
          orElse: () => null);
      if (item != null)
        API.SetRecogidaIntervalo(int.parse(item.valor));
      else
        API.SetRecogidaIntervalo(0);
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "PreparacionHoraInicial",   //LAS BRASAS. COMPROBACION DE DISPONIBILIDAD PE PAELLAS.
          orElse: () => null);
      if (item != null)
        API.SetPreparacionHoraInicial(item.valor);
      else
        API.SetPreparacionHoraInicial('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPGastosEnvioGratis",
          orElse: () => null);
      if (item != null)
        API.SetGastosEnvioGratis(item.valor);
      else
        API.SetGastosEnvioGratis('0');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPCodPostalesEnvio",
          orElse: () => null);
      if (item != null)
        API.SetAPPCodPostalesEnvio(item.valor);
      else
        API.SetAPPCodPostalesEnvio('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "APPTextoPrivacidad",
          orElse: () => null);
      if (item != null)
        API.SetPoliticaPrivacidad(item.valor);
      else
        API.SetPoliticaPrivacidad('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "StripeKeyPublic",
          orElse: () => null);
      if (item != null)
        API.SetStripeKeyPublic(item.valor);
      else
        API.SetStripeKeyPublic('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "StripeKeySecret",
          orElse: () => null);
      if (item != null)
        API.SetStripeKeySecret(item.valor);
      else
        API.SetStripeKeySecret('');
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPLogo",
          orElse: () => null);
      Logoimagenbase64 = '';
      if (item != null) Logoimagenbase64 = item.valor;
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "ResolucionImagenes",
          orElse: () => null);
      ResolucionImagenes = '300x300';
      if (item != null) ResolucionImagenes = item.valor;
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "ResolucionImagenesSecundarias",
          orElse: () => null);
      ResolucionImagenesSecundarias = '900x900';
      if (item != null) ResolucionImagenesSecundarias = item.valor;
      //---------------------------------------------------
      nombreTienda = '';
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "APPNombre",
          orElse: () => null);
      if (item != null) nombreTienda = item.valor;
      if (nombreTienda == '' || nombreTienda==null) {
        nombreTienda = licencia;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombreTienda', nombreTienda);
      for (var i = 1; i <= 10; i++) {
        String lic = (prefs.getString('licencia$i') ?? "");
        if (lic == licencia) {
          await prefs.setString('nombreTienda$i', nombreTienda);
          await prefs.setString('logo$i', Logoimagenbase64);
          break;
        }
      }
      //---------------------------------------------------
      colorApp1 = Colors.blue[900];
      colorApp2 = Colors.blue[800];
      colorApp3 = Colors.blue[600];
      colorBoton = Colors.blue[600];
      colorletraBoton = Colors.white;
      colorletraApp = Colors.white;
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "ColorApp1",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorApp1 = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "ColorApp2",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorApp2 = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "ColorApp3",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorApp3 = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "ColorBoton",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorBoton = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere((obj) => obj.clave == "ColorLetraAPP",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorletraApp = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      item = lista_ini_WebS.firstWhere(
              (obj) => obj.clave == "ColorLetraBoton",
          orElse: () => null);
      if (item != null && item.valor != '0') {
        colorletraBoton = Color(int.parse(item.valor));
      }
      //---------------------------------------------------
      GrabarPreferencias();
      //---------------------------------------------------
      rutaArticulo = API.GetRutaArticulo();
      rutaFamilia = API.GetRutaFamilia();
    }
  });
}
Future<void> getGastosEnvio() async {
  API.GetPrecioGastosEnvio();
}
Future<void> getFamilias() async {
  await API.getFamilias().then((response) async {
    var lista = response.body.toString();
    Iterable list = json.decode(lista);
    if (list.length > 0) {
      lista_familias_WebS =
          list.map((model) => Familias.fromJson(model)).toList();
    }
  });
}
Future<void> getSubFamilias() async {
  await API.getSubFamilias().then((response) async {
    var lista = response.body.toString();
    if (lista != '') {
      Iterable list = json.decode(lista);
      if (list.length > 0) {
        lista_subfamilias_WebS =
            list.map((model) => SubFamilias.fromJson(model)).toList();
      }
    }
  });
}
Future<void> getArticulos() async {
  await API.getArticulos().then((response) async {
    var lista = response.body.toString();
    Iterable list = json.decode(lista);
    if (list.length > 0) {
      lista_articulos_WebS = list.map((model) => Articulos.fromJson(model)).toList();
    }
  });
}

Future<void> getRemotos() async {
  API.getRemotos().then((response) async {
    var lista = response.body.toString();
    Iterable list = json.decode(lista);
    if (list.length != 0){
      lista_Remotos_WebS = list.map((model) => Remotos.fromJson(model)).toList();
    }
  });
}
Future<void> getImagenesArticulos() async {
  await API.getImagenesArticulos().then((response) async {
    var lista = response.body.toString();
    if (lista != '') {
      Iterable list = json.decode(lista);
      if (list.length > 0) {
        lista_imagenesArticulos_WebS =
            list.map((model) => ArticulosImagenes.fromJson(model)).toList();
      }
    }
  });
}

Future<void> getImagenesFamilias() async {
  await API.getImagenesFamilias().then((response) async {
    var lista = response.body.toString();
    if (lista != '') {
      Iterable list = json.decode(lista);
      if (list.length > 0) {
        lista_imagenesFamilias_WebS =
            list.map((model) => FamiliasImagenes.fromJson(model)).toList();
      }
    }
  });
}
Future<void> getImagenesSubFamilias() async {
  await API.getImagenesSubFamilias().then((response) async {
    var lista = response.body.toString();
    if (lista != '') {
      Iterable list = json.decode(lista);
      if (list.length > 0) {
        lista_imagenesSubFamilias_WebS =
            list.map((model) => SubFamiliasImagenes.fromJson(model)).toList();
      }
    }
  });
}
Widget widgetLogo() {
  return SizedBox(
    height: 80,
    child: (Logoimagenbase64 == '')
        ? Image.asset(
      'assets/logo.png',
      fit: BoxFit.contain,
    )
        : Image.memory(
      base64Decode(Logoimagenbase64),
      scale: 1.0,
    ),
  );
}

class Principal extends StatefulWidget {
  String usuario;
  bool administrador;
  Principal({
    this.usuario,
    this.administrador,
  });
  @override
  createState() => _Principal();
}

class _Principal extends State<Principal> {
  @override
  initState() {
    LeerPreferencias();
    super.initState();
    isLoading = true;
    VarSistemaPais = Platform.localeName;
    switch (VarSistemaPais) {
      case "es_ES":
        PaisMoneda = 'es_ES';
        break;
      case "en_ES":
        PaisMoneda = 'es_ES';
        break;
      case "es_MX":
        PaisMoneda = 'es_MX';
        break;
      case "en_MX":
        PaisMoneda = 'es_MX';
        break;
      case "en_GI":
        PaisMoneda = 'en_GB';
        break;
      default:
        PaisMoneda = Platform.localeName;
    }
    findSystemLocale().then((_Moneda) {
      PaisMoneda = _Moneda;
    });
    //dbHelper.borrarDB();
    clase.setIndex(0);
    clase.setIndexsubfamilia(0);
    clase.setIDsubfamilia('0');
    clase.setID('0');
    //--------------------------------
    administrador = widget.administrador;
    //--------------------------------
    lista_articulos_WebS = [];
    lista_familias_WebS = [];
    lista_subfamilias_WebS = [];
    lista_imagenesArticulos_WebS = [];
    lista_imagenesFamilias_WebS=[];
    lista_imagenesSubFamilias_WebS = [];
    lista_ini_WebS = [];
    lista_Remotos_WebS=[];
    Load();
  }
  @override
  dispose() {
    super.dispose();
  }

  Widget Menu(usuario){
    return Drawer(
      child: ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: <Color>[
              colorApp1,
              colorApp2,
              colorApp3,
            ]),
          ),
          child: Container(
            child: Column(
              children: [
                widgetLogo(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    usuario,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ItemMenu(Icons.person, 'Datos Personales', () {
          //Navigator.of(context).pop();
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return Registro();
          }));
        }),
        ItemMenu(Icons.home, 'Dirección de Envío', () {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return DireccionEnvio();
          }));
        }),
        (administrador)
            ? ItemMenu(Icons.home, 'Configuración de Color', () async {
          await Navigator.of(context)
              .push(CupertinoPageRoute(builder: (BuildContext context) {
            return ColorConfiguracion();
          }));
        })
            : SizedBox.shrink(),
        ItemMenu(Icons.refresh, 'Actualizar', () {
          Load();
          Navigator.of(context).pop();
        }),
        ItemMenu(Icons.exit_to_app, 'Cerrar Sesión', () async {
          var result = await Dialogs.Dialogo(context, 'CERRAR SESIÓN',
              'Se cerrará la sesión actual, ¿ estás seguro ?', 'SiNo', '');
          Navigator.of(context).pop();
          if (result == 'Si') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
          }
        }),
        ListTile(
          subtitle: Text("version: 1.0.1+36"),
          //trailing: Icon<(Icons.arrow_forward),
        ),
      ]),
    );
  }

  void Load() async {
    setState(() {isLoading = true;});
    await getINI();
    setState(() {isLoading = true;});
    await getFamilias();
    await getSubFamilias();
    await getArticulos();
    if (Sector == 'ROPA') {
      await getImagenesSubFamilias();
    }else{
      await getImagenesArticulos();
    };
    await getImagenesFamilias();
    setState(() {
      isLoading = false;
    });
    if (Sector == 'ROPA') getImagenesArticulos();
    //------------------------------------------------
    getRemotos();
    getGastosEnvio();
    //------------------------------------------------
  }

  Caption(iPage) {
    String texto = '';
    (iPage == 'Articulos')
        ? texto = (nombreTienda != null) ? '${nombreTienda}' : ''
        : (iPage == 'Pedido')
            ? texto = (nombreTienda != null) ? '${nombreTienda}' : ''
            : (iPage == 'Historico') ? texto = 'MIS PEDIDOS' : '';
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<ChangePage>();
    dbHelper.CountNumLineasPedidoActual(); //PARA EL PUNTO NARANJA
    return WillPopScope(
      onWillPop: () async {
        counter.page = 'Articulos';
        opcion = 'icon';
        setState(() {});
      },
      child: Scaffold(
        appBar: NewGradientAppBar(
          title: Text(Caption(counter.page),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              )),
          gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
          actions: [
            (counter.page == 'Articulos')
                ? IconButton(
                    icon: Icon(
                      Icons.search,
                      //Option ? Icons.format_list_numbered : Chart.chart_bar_1,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: DataSearch(
                              ListaArticulos: lista_articulos_WebS,
                              desde: 'principal'));
                    })
                : (counter.page == 'Pedido')
                    ? Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              final result = await pGuardarPedido(context);
                              if (result == 'OK') {
                                opcion = 'guardados';
                                counter.page = 'Historico';
                                setState(() {});
                              }
                            },
                          ),
                          /*IconButton(
                              icon: Icon(
                                Icons.cloud_upload,
                                color: Colors.white,
                              ),
                            onPressed:() async {
                              var result =await pEnviarPedido(context);
                              setState(() {});
                            },
                              ),*/
                        ],
                      )
                    : SizedBox.shrink(), // do something
          ],
        ),
        drawer: Menu(widget.usuario),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: colorApp2,
          notchMargin: 4.0,
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  tooltip: 'Articulos',
                                  color: counter.page == 'Articulos'
                                      ? Colors.white
                                      : Colors.white70,
                                  icon: new Icon(
                                    Icons.home,
                                    size: 35.0,
                                  ),
                                  onPressed: () {
                                    counter.page = 'Articulos';
                                    opcion = 'icon';
                                    setState(() {});
                                  })
                            ]),
                      ),
                      Expanded(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                            Stack(
                              children: [
                                IconButton(
                                    tooltip: 'Pedido',
                                    color: counter.page == 'Pedido'
                                        ? Colors.white
                                        : Colors.white70,
                                    icon: Icon(
                                      Icons.shopping_cart,
                                      size: 35.0,
                                    ),
                                    onPressed: () {
                                      counter.page = 'Pedido';
                                      opcion = 'icon';
                                      setState(() {});
                                    }),
                                PuntoNaranja(),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            IconButton(
                                tooltip: 'Histórico Pedidos',
                                color: (counter.page == 'Historico')
                                    ? Colors.white
                                    : Colors.white70,
                                icon: new Icon(
                                  Icons.calendar_today,
                                  size: 35.0,
                                ),
                                onPressed: () {
                                  counter.page = 'Historico';
                                  opcion = 'icon';
                                  setState(() {});
                                }),
                          ])),
                    ]),
              ]),
            ),
          ),
        ),
        body: (isLoading)
            ? CircularProgress()
            //widgetGestorPantallas(),
            :Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: (counter.page == 'Articulos')
                    ? WidgetArticulos(
                        lista_articulos_WebS,
                        lista_familias_WebS,
                        lista_subfamilias_WebS,
                        lista_imagenesArticulos_WebS,
                        lista_imagenesSubFamilias_WebS,
                        lista_imagenesFamilias_WebS)
                    : (counter.page == 'Pedido')
                        ? WidgetPedido((opcion == 'add')
                            ? ListaArticulos.ArticulosConCantidad()
                            : null)
                        : (counter.page == 'Historico')
                            ? WidgetHistorico(
                                Enviados: (opcion == 'guardados') ? 0 : 1)
                            : WidgetArticulos(
                                lista_articulos_WebS,
                                lista_familias_WebS,
                                lista_subfamilias_WebS,
                                lista_imagenesArticulos_WebS,
                                lista_imagenesSubFamilias_WebS,
                                lista_imagenesFamilias_WebS)),
        floatingActionButton: FloatingActionButton(
          elevation: 10.0,
          backgroundColor: colorApp2,
          onPressed: () async {
            if (counter.page == 'Articulos') {
              await pAddArticulosAlPedido(context);
              //SI QUEREMOS QUE VAYA A LA PESTAÑA DE PEDIDOS.
              //   counter.page = 'Pedido';
              //   opcion = 'add';
            } else if (counter.page == 'Pedido') {
              counter.page = 'Articulos';
              opcion = 'add';
            } else if (counter.page == 'Historico') {
              counter.page = 'Pedido';
              opcion = '';
            }
            setState(() {});
          },
          //tooltip: 'Añadir Artículos....',
          child: Icon(Icons.add, color: Colors.white, size: 30.0),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Stack(
        children: [
          Container(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              backgroundColor: colorBoton,
              strokeWidth: 8,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue[900] ),
            ),
          ),
          Container(
              alignment: Alignment.center,
              width: 150,
              height: 150,
              child: Text(
                'Cargando...',
                style: TextStyle(
                  fontSize: 15,
                  color: colorApp1,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
      ));
  }
}

class PuntoNaranja extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (dbHelper.NumReg > 0)
        ? Positioned(
            bottom: 6.0,
            right: 25.0,
            child: Container(
              height: 12.0,
              width: 12.0,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  '', //${dbHelper.NumReg}
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

class ItemMenu extends StatelessWidget {
  IconData icono;
  String texto;
  Function funcion;
  ItemMenu(this.icono, this.texto, this.funcion);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: InkWell(
          splashColor: colorApp1,
          onTap: funcion,
          child: Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icono, color: colorApp2, size: 32),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        texto,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_right,
                  size: 32,
                  color: colorApp2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

pComprobacionesGuardarPedido(context) {
  var result;
  if (isSending == false) {
    if (listaPedidoLin() != null && listaPedidoLin().length > 0) {
      result = 'OK';
    } else
      API.AvisoToast(context, 'NO HAY NINGUN ARTICULO A PEDIR.');
  }
  return result;
}

pComprobacionesEnviarPedido(context) {
  var result='OK';
  if (listaPedidoCab()[0].fechaservicio == null) {
    API.AvisoToast(context, 'SE NECESITA UNA FECHA DE SERVICIO.');
    result='NULL';
  } else {
    //NO HACE FALTA YA SE COMPRUEBA JUSTO ANTES DE ESTO...
/*   int dia1 = int.parse(listaPedidoCab()[0].fechaservicio.substring(0, 2));
    int mes1 = int.parse(listaPedidoCab()[0].fechaservicio.substring(3, 5));
    int anno1 = int.parse(listaPedidoCab()[0].fechaservicio.substring(6, 10));
    result = API.HoraPermitida_sin_uso(DateTime(anno1, mes1, dia1));
    if (result != 'OK') Dialogs.Dialogo(context, 'AVISO', result, 'OK', '');*/
  }
  return result;
}

pGuardarPedido(context) async {
  var resultado;
  if (pComprobacionesGuardarPedido(context) == 'OK') {
    //---------------------------------------
    var nombrePedido = await Dialogs.Dialogo(context, 'GUARDANDO PEDIDO',
        '¿Le quieres poner un nombre?', 'OK', "TextField");
    //---------------------------------------
    await dbHelper.ModificarCampoCabeceraPedido(
        1, 'nombrepedido', nombrePedido);
    isSending = true;
    await dbHelper.TransferPedido_A_Historico();
    isSending = false;
    resultado = 'OK';
  }
  //HOLA
  return resultado;
}

pEnviarPedido(context, _GastosEnvioCargados, _IDRemoto, _ImportePagado, Hora) async {
  var resultado;
  if ((pComprobacionesGuardarPedido(context) == 'OK') &&
      (pComprobacionesEnviarPedido(context) == 'OK')) {
    isSending = true;
    isLoading = true;
    final result = await EnviarAlbaran(_GastosEnvioCargados, _IDRemoto, _ImportePagado, Hora);
    if (result == 'OK') {
      resultado = 'OK';
    }
    isSending = false;
    isLoading = false;
  }
  return resultado;
}

pAddArticulosAlPedido(context) async {
  await LoadlistLineasPedido();
  AddLineas(ListaArticulos.ArticulosConCantidad());
  await LoadPedido();
  await GrabarCabeceraPedido();
  ListaArticulos.ArticulosCantidadInicializar();
}
