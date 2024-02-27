import 'dart:convert';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'Principal.dart';
import 'rutas/Scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'Carrusel_pro.dart';
import 'DatabaseHelper.dart';
import 'Datos/Articulos.dart';
import 'package:social_share/social_share.dart';
import 'package:screenshot/screenshot.dart';
import 'Notificadores.dart';
import 'CamaraFotos.dart';
import 'Principal.dart';
import 'PedidoActual.dart';
import 'package:provider/provider.dart';
import 'Variables.dart';

DBHelper dbHelper = DBHelper();
bool isLoading = true;
bool isLoadingImages = true;
bool peticionVerImagen = false;
String licencia;
var itemImagen;

List<ArticulosImagenes> ListaImagenesArticulo = [];
List<ArticulosImagenes> ListaImagenesCalidad = [];
List<Articulo_Colores_Tallas> ListaColores = [];

ScreenshotController screenshotController = ScreenshotController();
ScreenshotController screenshotControllerFoto = ScreenshotController();
var selectedColor = '';
var selectedColorIndex = 0;
var selectedTalla = '';
var selectedTallaIndex = 0;
double PrecioFinal = 0;
double precioPromocion =0;
double precioCliente=0;
double precio;
double dto=0;
String articulo;
int idArticulo=0;
bool EnPromocion=false;
String textoCambioFoto='';
var myImage;

void CalculoPrecio(){
  idArticulo= ListaColores[selectedColorIndex].tallas[selectedTallaIndex].idArticulo;
  articulo= ListaColores[selectedColorIndex].tallas[selectedTallaIndex].articulo;
  precio=ListaColores[selectedColorIndex].tallas[selectedTallaIndex].precio;
  precioPromocion=ListaColores[selectedColorIndex].tallas[selectedTallaIndex].precioPromocion;
  precioCliente=ListaColores[selectedColorIndex].tallas[selectedTallaIndex].precioCliente;
  EnPromocion = (precioPromocion != 0 && precioPromocion < precioCliente);
  PrecioFinal = (EnPromocion) ? precioPromocion : precioCliente;
}

Widget WidgetPrecio_PrecioPromocion_dto() {
  CalculoPrecio();
  return Column(
    children: [
      (precio >
          precioCliente) //PRECIO ORIGINAL SI TIENE PRECIO PERSONALIZADO
          ? Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
              'Precio: ${NumberFormat.simpleCurrency().format(precio)}',
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
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(NumberFormat.simpleCurrency().format(precioCliente),
                  style: TextStyle(
                    fontSize: (EnPromocion) ? 18.0 : 20.0,
                    fontFamily: 'Montserrat',
                    decoration:
                    (EnPromocion) ? TextDecoration.lineThrough : null,
                    color: (EnPromocion) ? Colors.black45 : Colors.grey,
                  )),
              (EnPromocion)
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                      '  ' +
                          NumberFormat.simpleCurrency()
                              .format(PrecioFinal),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20.0,
                      )),
                ],
              )
                  : SizedBox.shrink(),
            ],
          ),
          (dto != 0)
              ? Text('Dto: ${NumberFormat().format(dto)} %',
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

class FichaArticuloTallas extends StatefulWidget {
  final heroTag;
  final idsubFamilia;
  final subFamilia;
  double dto;
  var item;
  List<Articulo_Colores_Tallas> listaColores = [];

  FichaArticuloTallas({
    this.heroTag,
    this.idsubFamilia,
    this.subFamilia,
    this.dto,
    this.item,
    this.listaColores,
  });

  @override
  _FichaArticuloState createState() => _FichaArticuloState();
}

class _FichaArticuloState extends State<FichaArticuloTallas> {

  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    licencia = (prefs.getString('licencia') ?? "");
  }

  initState() {
    isLoading = true;
    isLoadingImages = true;
    peticionVerImagen = false;
    super.initState();
    ListaImagenesArticulo=[];
    //itemImagen = widget.item;
    articulo = widget.subFamilia;
    dto = widget.dto;
    precio = 0;
    precioPromocion = 0;
    precioCliente= 0;
    PrecioFinal=0;
    ListaColores = widget.listaColores;
    _LeerPreferencias();
    isLoading = false;
    myImage= Image.asset(rutaArticulo);
    //---------------------------------------------------------------
    if (ListaColores.length>0) {
      selectedColor = ListaColores[0].color;
      selectedColorIndex = 0;
      BuscarTallas();
    }else{
    //  idArticulo=
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage.image, context);
  }

  void BuscarTallas(){
    selectedTallaIndex =(ListaColores[selectedColorIndex].tallas.length / 2 ).toInt();
    if (selectedTallaIndex < 0) selectedTallaIndex = 0;
    if (ListaColores[selectedColorIndex].tallas[selectedTallaIndex].stockTalla==0) {
      for (var x = 0; x <ListaColores[selectedColorIndex].tallas.length; x++) {
        if (ListaColores[selectedColorIndex].tallas[x].stockTalla > 0){
          selectedTallaIndex=x;
          selectedTalla = ListaColores[selectedColorIndex].tallas[selectedTallaIndex].talla;
          break;
        }
      }
    }else {
      selectedTalla = ListaColores[selectedColorIndex].tallas[selectedTallaIndex].talla;
    }
    //---------------------------------------------------------------
    CalculoPrecio();
    //---------------------------------------------------------------
    ListaImagenesArticulo=lista_imagenesArticulos_WebS;     //Items sin calidad de imagenes artículos
    var itemImagenArticulo = ListaImagenesArticulo.firstWhere(
            (obj) => obj.idArticulo ==idArticulo,
        orElse: () => null);

    if (itemImagenArticulo==null){
      itemImagen = widget.item;   //coge la imagen de la Subfamilia;
      setState(() {});
    }else if (itemImagen==null || itemImagen.imagenbase64 != itemImagenArticulo.imagenbase64) {
      itemImagen = itemImagenArticulo;
      setState(() {});
    }
    ObtenerImagenCalidadArticulo();

  }

  ObtenerImagenCalidadArticulo() async {
    isLoadingImages = true;
    ListaImagenesCalidad=[];
    await API.getImagenes_1_Articulo(idArticulo).then((
          response) async {
        var lista = response.body.toString();
        if (lista != '') {
          Iterable list = json.decode(lista);
          if (list.length > 0) {
            ListaImagenesCalidad =
                list.map((model) => ArticulosImagenes.fromJson(model)).toList();
          }
        }
      });
    //Future.delayed(const Duration(seconds: 5), () {
    isLoadingImages = false;
    if (peticionVerImagen) AbrirFoto();
  }

  Future<void> AbrirFoto() async {
    final result = await  Navigator.push(context,
        ScaleRoute(page: Carrusel_pro(itemImagen:itemImagen, listaImagenes:ListaImagenesCalidad,articulo: articulo, licencia: licencia,),ms: 600)
    );
    if (result == 'OK'){
      setState(() {
        isLoading = false;
        peticionVerImagen = false;
      });
    }
  }

  Widget ImagenModelo(){
    return
    (isLoading)
        ? Positioned(
        top: (MediaQuery.of(context).size.height / 8),
        left: (MediaQuery.of(context).size.width / 2) - 20,
        child: CircularProgressIndicator())
        : Positioned(
        top: 0.0,
        left: (MediaQuery.of(context).size.width / 2) - 125.0,
        child: Hero(tag: widget.heroTag, child: widgetImagen()));
  }
  Widget widgetImagen() {
   // myImage= MemoryImage(
    //       base64Decode(itemImagen.imagenbase64),
    //       scale: 1.0,
    //     );
   //didChangeDependencies();
   // precacheImage(myImage, context);
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
            (isLoadingImages)
                ? setState(() {})
                : AbrirFoto();
          },
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: colorApp3,      //Colors.blueAccent,
                      width: 4), //Color(0xFF7A9BEE)
                  image: DecorationImage(
                      image:  MemoryImage(
                        base64Decode(itemImagen.imagenbase64),
                        scale: 1.0,
                      ),
                      fit: BoxFit.cover)),
              height: 250.0,
              width: 250.0),
        ));
  }

  Widget widgetColores(index) {
    String color = ListaColores[index].color;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
          onTap: () {
            setState(() {
              selectedColor = color;
              selectedColorIndex = index;
              BuscarTallas();
            });
          },
          child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                //color: color == selectedColor ? Color(0xFF7A9BEE) :Colors.white,
                border: Border.all(
                    color: color == selectedColor
                        ? colorBoton   //Colors.blue
                        : Colors.grey.withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 1.75),
              ),
              //height: 100.0,
              width: 120.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6,0,6,0),
                child: FittedBox(
                  child: Center(
                    child: Text(color,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: color == selectedColor ? 15.0 : 14.0,
                          color: color == selectedColor
                              ? Colors.black
                              : Colors.grey.withOpacity(0.7),
                        )),
                  ),
                ),
              ))),
    );
  }
  Widget widgetTallas(){
  return
    (ListaColores!=null && ListaColores.length > 0)?
    ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (ListaColores[selectedColorIndex].tallas == null) ? 0
            : ListaColores[selectedColorIndex].tallas.length,
        itemBuilder: (context, index) {
          String talla = ListaColores[selectedColorIndex].tallas[index].talla;
          double stock = ListaColores[selectedColorIndex].tallas[index].stockTalla;
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: InkWell(
                onTap: () {
                  talla = ListaColores[selectedColorIndex].tallas[index].talla;
                  stock = ListaColores[selectedColorIndex].tallas[index].stockTalla;
                  setState(() {
                    selectedTalla = talla;
                    selectedTallaIndex = index;
                    CalculoPrecio();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,8,0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      //color: color == selectedColor ? Color(0xFF7A9BEE) :Colors.white,
                      border: Border.all(
                          color: talla == selectedTalla
                              ? colorBoton
                              : Colors.grey.withOpacity(0.3),
                          style: BorderStyle.solid,
                          width:  1.75),
                    ),
                    // height: 100.0,
                    // width: 50.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6,0,6,0),
                      child: Center(
                        child: Text(talla,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: talla == selectedTalla ? 18.0 : 16.0,
                              color: talla == selectedTalla && stock > 0
                                  ? Colors.black
                                  : Colors.grey.withOpacity(0.7),
                              decoration: stock==0?TextDecoration.lineThrough:TextDecoration.none,
                            )),
                      ),
                    ),
                  ),
                )
            ),
          );
        }): SizedBox.shrink();
}

  Widget widgetBotonAdd(){
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width/2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
      ), //[Color(0xFFF2
      child: MaterialButton(
        onPressed: () async {
          await dbHelper.Insertar_en_Pedido(idArticulo, articulo, PrecioFinal);
          await LoadlistLineasPedido();
          await LoadPedido();
          await GrabarCabeceraPedido();
          context.read<ChangePage>().setPage('Articulo');
          Navigator.pop(context, 'OK');
        },
        color: colorBoton,  //Colors.green[300],
        child: Padding(
          padding: EdgeInsets.fromLTRB(5,5,5,5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Añadir',
                style: TextStyle(
                  fontSize: 18,
                  color: colorletraBoton, //Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget widgetDatosArticuloSeleccionado(){
    return Column(
      children: [
        Text(idArticulo.toString(),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
            )),
        Text(articulo ,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
            )),
        Text('${NumberFormat.simpleCurrency().format(precio)}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
            )),
      ],
    );
  }


  Widget widgetInfoColoresTallas(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              height: 40.0,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (ListaColores == null) ? 0 : ListaColores.length,
                  itemBuilder: (context, index) {
                    return widgetColores(index);
                  })),
          SizedBox(height: 20,),
          Container(
              height: 40.0,
              child:
              widgetTallas(),
            /*
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (ListaColores[selectedColorIndex].tallas == null)
                      ? 0
                      : ListaColores[selectedColorIndex].tallas.length,
                  itemBuilder: (context, index) {
                    return widgetTallas(index);
                  })
               */
          ),
          SizedBox(height: 30),
          widgetBotonAdd(),
          SizedBox(height: 20,),
          //widgetDatosArticuloSeleccionado(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final counter = context.watch<CambioModelo>();
    return Scaffold(
        backgroundColor: colorApp3,//Color(0xFF7A9BEE),
        appBar: AppBar(
          //gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(textoCambioFoto);
            },
            icon: Icon(Icons.arrow_back_ios),
            color: colorletraApp, //Colors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                String msg1 =
                    '¡Mira lo que estoy pensando comprar en ${licencia} gracias a la app de diakros dkPedidos, ${widget.subFamilia}!';
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
              color: colorletraApp, // Colors.white,
            )
          ],
        ),
        body: ListView(children: [
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
              ImagenModelo(),
              /*Consumer<CambioModelo>(
                   builder: (_, context, __) =>ImagenModelo(),
               ),*/
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
                      Text(widget.subFamilia,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16.0,
                          )),
                      //fontWeight: FontWeight.bold
                      SizedBox(height: 15.0),
                      WidgetPrecio_PrecioPromocion_dto(),
                      SizedBox(height: 20.0),
                      widgetInfoColoresTallas(),
                     // (ListaColores!=null && ListaColores.length > 0)? widgetInfoColoresTallas(): SizedBox.shrink(),
                      SizedBox(height: 20.0),
                    ],
                  ))
            ])
          ]),
        floatingActionButton: (administrador)?Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
              label: Text('Cámara'),
              backgroundColor: colorBoton,
              foregroundColor: colorletraBoton,
              onPressed: ()  async {
                var result = await Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) {return CamaraFotos(idArticulo: idArticulo,Articulo: articulo,);}));
                if (result=='OK') {
                  ObtenerImagenCalidadArticulo();
                  setState(() {});
                  textoCambioFoto = 'REFRESH';
                }
              },
              heroTag: null, //UniqueKey(),
              icon: Icon(Icons.camera)),
        ],
      ):SizedBox.shrink(),
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


