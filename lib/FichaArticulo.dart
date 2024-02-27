import 'dart:convert';
import 'dart:io' as io;
import 'Principal.dart';
import 'rutas/Scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'CamaraFotos.dart';
import 'Carrusel_pro.dart';
import 'DatabaseHelper.dart';
import 'Datos/Articulos.dart';
import 'package:social_share/social_share.dart';
import 'package:screenshot/screenshot.dart';
import 'Foto.dart';
import 'Principal.dart';
import 'Variables.dart';

DBHelper dbHelper = DBHelper();
bool isLoading = true;
bool isLoadingImages = true;
bool peticionVerImagen = false;
bool mostrarAlergenos = false;
String licencia;
var itemImagen;
String articulo;
List<ArticulosImagenes> ListaImagenesArticulo =[];
List<SubFamiliasImagenes> ListaImagenesSubFamilia =[];
List<Articulo_Alergenos> ListaAlergenosArticulo  =[];

bool tieneObservaciones;
bool tieneAlergenos;

ScreenshotController screenshotController = ScreenshotController();

var selectedColor = '';
var selectedColorIndex = 0;
var selectedTalla = '';
var selectedTallaIndex = 0;
double PrecioFinal = 0;
String textoCambioFoto = '';

class FichaArticulo extends StatefulWidget {
  final heroTag;
  final idarticulo;
  final articulo;
  double precio;
  double precioCliente;
  double precioPromocion;
  double dto;
  String ObservacionesArticulo;
  var item;

  FichaArticulo({
    this.heroTag,
    this.idarticulo,
    this.articulo,
    this.precio,
    this.precioCliente,
    this.precioPromocion,
    this.dto,
    this.ObservacionesArticulo,
    this.item,
  });

  @override
  _FichaArticuloState createState() => _FichaArticuloState();
}

class _FichaArticuloState extends State<FichaArticulo> {
  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    licencia = (prefs.getString('licencia') ?? "");
  }

  @override
  initState() {
    isLoading = true;
    isLoadingImages = true;
    peticionVerImagen = false;
    mostrarAlergenos = false;
    tieneAlergenos = false;
    tieneObservaciones = false;
    super.initState();
    ListaImagenesArticulo = [];
    ListaImagenesSubFamilia = [];
    ListaAlergenosArticulo = [];
    itemImagen = widget.item;
    articulo = widget.articulo;
    _LeerPreferencias();
    tieneObservaciones = (widget.ObservacionesArticulo != '' &&
        widget.ObservacionesArticulo != null);
    ObtenerAlergenosArticulo();
    //isLoading = false;
    ObtenerImagenCalidadArticulo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ObtenerImagenCalidadArticulo() async {
    await API.getImagenes_1_Articulo(widget.idarticulo).then((response) async {
      var lista = response.body.toString();
      if (lista != '') {
        Iterable list = json.decode(lista);
        if (list.length > 0) {
          ListaImagenesArticulo =
              list.map((model) => ArticulosImagenes.fromJson(model)).toList();
        }
      }
    });
    //Future.delayed(const Duration(seconds: 5), () {
    isLoadingImages = false;
    if (peticionVerImagen) AbrirFoto();
  }

  ObtenerAlergenosArticulo() async {
    await API.getAlergenos_1_Articulo(widget.idarticulo).then((response) async {
      var lista = response.body.toString();
      if (lista != '') {
        Iterable list = json.decode(lista);
        if (list.length > 0) {
          tieneAlergenos = true;
          ListaAlergenosArticulo =
              list.map((model) => Articulo_Alergenos.fromJson(model)).toList();
        }
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<void> AbrirFoto() async {
    var result;
    if (ListaImagenesArticulo.length > 0) {   //CARRUSEL
      result = await Navigator.push(
          context,
          ScaleRoute(
              page: Carrusel_pro(
                itemImagen: itemImagen,
                listaImagenes: ListaImagenesArticulo,
                articulo: articulo,
                licencia: licencia,
              ),
              ms: 100));
    } else {
      result = await Navigator.push(
          context,
          ScaleRoute(
              page: Foto(
                  base64Decode(itemImagen.imagenbase64)),
              ms: 600));
    }
    if (result == 'OK') {
      setState(() {
        peticionVerImagen = false;
        isLoading = false;
      });
    }
  }

  Widget widgetImagen() {
    return Screenshot(
        controller: screenshotController,
        child: (itemImagen == null)
            ? Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(rutaArticulo), fit: BoxFit.cover)),
                height: 250.0,
                width: 250.0)
            : GestureDetector(
                onTap: () {
                  peticionVerImagen = true;
                  (isLoadingImages) ? setState(() {}) : AbrirFoto();
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: colorApp3, //Colors.blueAccent,
                            width: 4), //Color(0xFF7A9BEE)
                        image: DecorationImage(
                            image: MemoryImage(
                              base64Decode(itemImagen.imagenbase64),
                              scale: 1.0,
                            ),
                            fit: BoxFit.cover)),
                    height: 250.0,
                    width: 250.0),
              ));
  }

  Widget WidgetPrecio_PrecioPromocion_dto() {
    bool EnPromocion = (widget.precioPromocion != 0 &&
        widget.precioPromocion < widget.precioCliente);
    PrecioFinal = (EnPromocion) ? widget.precioPromocion : widget.precioCliente;
    return Column(
      children: [
        (widget.precio >
                widget
                    .precioCliente) //PRECIO ORIGINAL SI TIENE PRECIO PERSONALIZADO
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      'Precio: ${NumberFormat.simpleCurrency().format(widget.precio)}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18.0,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black45,
                      )),
                ],
              )
            : SizedBox.shrink(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(NumberFormat.simpleCurrency().format(widget.precioCliente),
                    style: TextStyle(
                      fontSize: (EnPromocion) ? 18.0 : 25.0,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      //fontWeight: FontWeight.w600,
                      decoration:
                          (EnPromocion) ? TextDecoration.lineThrough : null,
                      color: (EnPromocion) ? Colors.black45 : Colors.grey,
                    )),
                (EnPromocion)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '  ' +
                                  NumberFormat.simpleCurrency()
                                      .format(PrecioFinal),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                //fontWeight: FontWeight.w600,
                              )),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
            (widget.dto != 0)
                ? Text('Dto: ${NumberFormat().format(widget.dto)} %',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18.0,
                        color: Colors.grey))
                : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorApp3, //Color(0xFF7A9BEE),
      appBar: AppBar(
        //gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(textoCambioFoto);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: colorletraApp, // Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          (administrador)
              ? IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () async {
                    var result = await Navigator.of(context).push(
                        CupertinoPageRoute(builder: (BuildContext context) {
                      return CamaraFotos(
                        idArticulo: widget.idarticulo,
                        Articulo: widget.articulo,
                      );
                    }));
                    if (result == 'OK') {
                      ObtenerImagenCalidadArticulo();
                      setState(() {});
                      textoCambioFoto = 'REFRESH';
                    }
                  },
                  color: colorletraApp, //Colors.white,
                )
              : SizedBox.shrink(),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              String msg1 =
                  '¡Mira lo que estoy pensando comprar en ${licencia} gracias a la app de diakros dkPedidos, ${widget.articulo}!';
              String msg2 = 'descárgatela gratis para Android en ';
              msg2 = msg2 +
                  'http://play.google.com/store/apps/details?id=com.diakros.dipedidosweb y para iOS en https://apps.apple.com/es/app/dkpedidos/id1501837627';
              await screenshotController.capture().then((imagen) async {
                //devuelve imagen como Uint8List hay que pasarlo a File.
                //-------------------------------------------------------------
                io.Directory appDocDirectory;
                if (io.Platform.isIOS) {
                  appDocDirectory = await getApplicationDocumentsDirectory();
                } else {
                  appDocDirectory = await getExternalStorageDirectory();
                }
                String _mPath = '${appDocDirectory.path}/imagen.png';
                await deleteFile(_mPath);
                io.File imgFile = io.File(_mPath);
                await imgFile.writeAsBytes(imagen).then((onValue) {});
                //-------------------------------------------------------------
                SocialShare.shareOptions('$msg1\n$msg2',
                    imagePath: imgFile.path
                ).then((data) {
                  print(data);
                });
              });
              /*   await SocialShare.shareWhatsapp(
                    '${msg2}')
                    .then((data) {
                  print(data);
                });*/
              //SocialShare.shareWhatsapp(msg).then((data) {print(data);});
            },
            color: colorletraApp, //Colors.white,
          )
        ],
      ),
      body: ListView(shrinkWrap: true, children: [
        Stack(children: [
          Container(
              height: MediaQuery.of(context).size.height - 82.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent),
          Positioned(
              top: 75.0,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45.0),
                        topRight: Radius.circular(45.0),
                      ),
                      color: Colors.white),
                  height: MediaQuery.of(context).size.height - 100.0,
                  width: MediaQuery.of(context).size.width)),
          (isLoading)
              ? Positioned(
                  top: (MediaQuery.of(context).size.height / 8),
                  left: (MediaQuery.of(context).size.width / 2) - 20,
                  child: CircularProgressIndicator())
              : Positioned(
                  top: 0.0,
                  left: (MediaQuery.of(context).size.width / 2) - 125.0,
                  child: Hero(tag: widget.heroTag, child: widgetImagen())),
          (isLoadingImages && peticionVerImagen)
              ? Positioned(
                  top: (MediaQuery.of(context).size.height / 10),
                  left: (MediaQuery.of(context).size.width / 2) - 20,
                  child: CircularProgressIndicator())
              : Positioned(
                  top: 30.0,
                  left: (MediaQuery.of(context).size.width / 2) - 100.0,
                  child: SizedBox.shrink()),
          Positioned(
              top: 250.0,
              left: 25.0,
              right: 25.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(widget.articulo,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.0,
                      )),
                  //fontWeight: FontWeight.bold
                  SizedBox(height: 15.0),
                  WidgetPrecio_PrecioPromocion_dto(),
                  Observaciones_Alergenos(widget: widget),
                  //WidgetTotal(),
                ],
              ))
        ]),
      ]),
      /* floatingActionButton: (administrador)
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35.0, 0, 0, 0),
            child: FloatingActionButton.extended(
                label: Text('Cámara'),
                backgroundColor: colorBoton,
                foregroundColor: colorletraBoton,
                onPressed: () async {
                  var result = await Navigator.of(context).push(
                      CupertinoPageRoute(builder: (BuildContext context) {
                        return CamaraFotos(
                          idArticulo: widget.idarticulo,
                          Articulo: widget.articulo,
                        );
                      }));
                  if (result == 'OK') {
                    ObtenerImagenCalidadArticulo();
                    setState(() {});
                    textoCambioFoto = 'REFRESH';
                  }
                },
                heroTag: null, //UniqueKey(),
                icon: Icon(Icons.camera)),
          ),
        ],
      )
          : SizedBox.shrink(),*/
    );
  }

  Future<void> deleteFile(String path) async {
    try {
      var file = io.File(path);
      if (await file.exists()) {
        // file exits, it is safe to call delete on it
        await file.delete();
      }
    } catch (e) {
      // error in getting access to the file
    }
  }
}

class WidgetTotal extends StatelessWidget {
  const WidgetTotal({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.0),
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0)),
                color: colorApp3), //Color(0xFF7A9BEE)),
            height: 50.0,
            child: Center(
              child:
                  Text('${NumberFormat.simpleCurrency().format(PrecioFinal)}',
                      style: TextStyle(
                        color: colorletraApp, //Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                      )),
            ),
          ),
        ),
      ],
    );
  }
}

class Observaciones_Alergenos extends StatefulWidget {
  const Observaciones_Alergenos({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final FichaArticulo widget;

  @override
  _Observaciones_AlergenosState createState() =>
      _Observaciones_AlergenosState();
}

class _Observaciones_AlergenosState extends State<Observaciones_Alergenos> {
  GlobalKey key = GlobalKey();
  var position;
  double altura;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  _getPositions() {
    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    position = renderBoxRed.localToGlobal(Offset.zero);
    print(
        "POSITION of Red: $position.dy $position.dx MediaQuery.of(context).size.height ");
  }
/*  _getSizes() {
    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    print("SIZE of Red: $sizeRed");
  }*/

  Widget _botonAlergenos() {
    return MaterialButton(
      child: Text(mostrarAlergenos ? 'Observaciones' : 'Alérgenos'),
      color: colorBoton,
      textColor: colorletraBoton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      onPressed: () async {
        setState(() {
          mostrarAlergenos = !mostrarAlergenos;
        });
      },
      //icon: Icon(mostrarAlergenos ? Icons.menu : Icons.local_hospital),
    );
  }

  Widget _buildAlergenos() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: ListaAlergenosArticulo.length,
        itemBuilder: (context, index) {
          /*return Card(
              child: ListTile(
                leading: SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                      'assets/Alergeno${ListaAlergenosArticulo[index].idAlergeno}.png'),
                ),
                title: Text(ListaAlergenosArticulo[index].alergeno,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                    )),
              ));*/
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
            child: Row(children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Image.asset(
                    'assets/Alergeno${ListaAlergenosArticulo[index].idAlergeno}.png'),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(ListaAlergenosArticulo[index].alergeno,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                    )),
              ),
            ]),
          );
        });
  }

  Widget _buildObservaciones() {
    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          (widget.widget.ObservacionesArticulo) ?? '',
          style: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  _afterLayout(_) {
    _getPositions();
  }

  @override
  Widget build(BuildContext context) {
    if (tieneAlergenos == true && tieneObservaciones == false)
      mostrarAlergenos = true;
    if (position != null) {
      altura = MediaQuery.of(context).size.height -
          position.dy -
          50; // RESTA EL TAMAÑO DEL MARGEN INFERIOR
    } else {
      altura = 300;
    }
    //----------------------------------------------------------------
    //PONERLO EN STACK Y EL BOTON DE ALERGENOS ABAJO A LA DERECHA..
    //----------------------------------------------------------------
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      child: Column(
        children: [
          SizedBox(
            key: key,
            height: altura,
            child:
                (mostrarAlergenos) ? _buildAlergenos() : _buildObservaciones(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (tieneAlergenos && tieneObservaciones)
                  ? _botonAlergenos()
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}
