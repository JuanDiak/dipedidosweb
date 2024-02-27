import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'Api.dart';
import 'FichaArticulo.dart';
import 'Notificadores.dart';
import 'rutas/Scale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Datos/Articulos.dart';
import 'DatabaseHelper.dart';
import 'FichaArticuloTallas.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'Variables.dart';
import 'Principal.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


List<Articulos> _ListaArticulos = [];
List<Familias> _ListaFamilias = [];
List<SubFamiliasImagenes> _ListaSubFamiliasImagenes = [];
List<SubFamilias> _ListaSubFamilias = [];
List<ArticulosImagenes> _ListaImagenes = [];
List<Articulos> _ListaCompletaArticulos = [];
List<SubFamilias> _ListaCompletaSubFamilias = [];
List<FamiliasImagenes> _ListaFamiliasImagenes=[];

bool isLoading;
String _currentfamilia;
String _currentsubfamilia;
DBHelper dbHelper = DBHelper();
AutoScrollController autocontrollerFamilia;
AutoScrollController autocontrollerSubFamilia;
double _widthImagen = 100;
double _heightImagen = 100;
var itemImagenSubFamilia;

InicializarCantidades(List<Articulos> _lista) {
  for (var x = 0; x < _lista.length; x++) {
    _lista[x].cantidad = 0;
  }
}

class ListaArticulos {
  static ArticulosConCantidad() {
    List<Articulos> _lista = [];
    if (_ListaArticulos != null) {
      _lista = _ListaArticulos.where((i) => i.cantidad != 0.0).toList();
    }
    return _lista;
  }

  static ArticulosCantidadInicializar() {
    for (var x = 0; x < _ListaArticulos.length; x++) {
      _ListaArticulos[x].cantidad = 0;
    }
  }

  static ArticulosLista() {
    return _ListaArticulos;
  }
}

class WidgetArticulos extends StatefulWidget {
  List<Articulos> lista_articulos;
  List<Familias> lista_familias;
  List<SubFamilias> lista_subfamilias;
  List<ArticulosImagenes> lista_imagenes;
  List<SubFamiliasImagenes> lista_imagenessubfamilias;
  List<FamiliasImagenes> lista_imagenesfamilias;

  WidgetArticulos(
    this.lista_articulos,
    this.lista_familias,
    this.lista_subfamilias,
    this.lista_imagenes,
    this.lista_imagenessubfamilias,
    this.lista_imagenesfamilias,
  );
  @override
  createState() => _WidgetArticulos(lista_articulos, lista_familias,
      lista_subfamilias, lista_imagenes, lista_imagenessubfamilias, lista_imagenesfamilias);
}

class _WidgetArticulos extends State<WidgetArticulos> {
  List<Articulos> ListaArticulos;
  List<Familias> ListaFamilias;
  List<SubFamilias> ListaSubFamilias;
  List<ArticulosImagenes> ListaImagenes;
  List<SubFamiliasImagenes> listaImagenesSubFamilias;
  List<FamiliasImagenes> listaImagenesFamilias;

  _WidgetArticulos(
      this.ListaArticulos,
      this.ListaFamilias,
      this.ListaSubFamilias,
      this.ListaImagenes,
      this.listaImagenesSubFamilias,
      this.listaImagenesFamilias,
     ) {
    isLoading = true;
    _ListaArticulos = ListaArticulos;
    _ListaFamilias = ListaFamilias;
    _ListaSubFamiliasImagenes = listaImagenesSubFamilias;
    _ListaSubFamilias = ListaSubFamilias;
    _ListaImagenes = ListaImagenes;
    _ListaFamiliasImagenes=listaImagenesFamilias;
    _ListaCompletaArticulos = ListaArticulos;
    _ListaCompletaSubFamilias = ListaSubFamilias;
  }

  Widget _wrapScrollTag({int index, Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: autocontrollerFamilia,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );
  Widget _wrapScrollSubFamiliaTag({int index, Widget child}) => AutoScrollTag(
        key: ValueKey(index),
        controller: autocontrollerSubFamilia,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    autocontrollerFamilia = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
      //suggestedRowHeight: 130
    );
    autocontrollerSubFamilia = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
      //suggestedRowHeight: 130
    );
    isLoading = false;
    (clase.getID() == '0')
        ? _grabarFamiliasIniciales()
        : _currentfamilia = clase.getID();
    _scrollFamiliasToIndex();
    //-----------------------------------------------------------------------------
    _filtrarSubFamilias();
  }

  _filtrarSubFamilias() {
    _ListaSubFamilias =
        _ListaSubFamilias.where((i) => i.idFamilia == int.parse(clase.getID()))
            .toList();
    if (_ListaSubFamilias.length > 0) {
      if (clase.getIDsubfamilia() == '0') {
        _currentsubfamilia = _ListaSubFamilias[0].idsubFamilia.toString();
        clase.setIDsubfamilia(_currentsubfamilia);
        clase.setIndexsubfamilia(0);
      }
    } else {
      _currentsubfamilia = '0';
      clase.setIDsubfamilia(_currentsubfamilia);
      clase.setIndexsubfamilia(0);
    }
    if (_ListaSubFamiliasImagenes != null) {
      itemImagenSubFamilia = _ListaSubFamiliasImagenes.firstWhere(
          (obj) => obj.idsubFamilia == int.parse(_currentsubfamilia),
          orElse: () => null);
    }
    _scrollSubFamiliasToIndex();
  }

  _grabarFamiliasIniciales() {
    _currentfamilia = _ListaFamilias[0].idfamilia.toString();
    clase.setID(_currentfamilia);
    clase.setIndex(0);
  }

  Future _scrollFamiliasToIndex() async {
    await autocontrollerFamilia.scrollToIndex(clase.getIndex(),
        preferPosition: AutoScrollPosition.middle);
  }

  Future _scrollSubFamiliasToIndex() async {
    await autocontrollerSubFamilia.scrollToIndex(clase.getIndexsubfamilia(),
        preferPosition: AutoScrollPosition.middle);
  }

  void changefamilia(String selectedfamilia, int index) {
    for (var x = 0; x < _ListaCompletaArticulos.length; x++) {
      _ListaCompletaArticulos[x].cantidad = 0;
    }
    _ListaArticulos = _ListaCompletaArticulos;
    _ListaSubFamilias = _ListaCompletaSubFamilias;
    //---------------------------------------------------
    //POR SI SE ESTABA AUN CARGANDO EN EL LOAD...
    _ListaImagenes = lista_imagenesArticulos_WebS;
    _ListaSubFamiliasImagenes = lista_imagenesSubFamilias_WebS;
    //---------------------------------------------------
    InicializarCantidades(_ListaArticulos);
    //---------------------------------------------------
    _currentfamilia = selectedfamilia;
    setState(() {
      clase.setID(_currentfamilia);
      clase.setIndex(index);
      clase.setIDsubfamilia('0');
      _filtrarSubFamilias();
    });
  }

  void changeSubfamilia(String selectedsubfamilia, int index) {
    for (var x = 0; x < _ListaCompletaArticulos.length; x++) {
      _ListaCompletaArticulos[x].cantidad = 0;
    }
    _ListaArticulos = _ListaCompletaArticulos;
    //---------------------------------------------------
    InicializarCantidades(_ListaArticulos);
    //---------------------------------------------------
    _currentsubfamilia = selectedsubfamilia;
    setState(() {
      clase.setIDsubfamilia(_currentsubfamilia);
      clase.setIndexsubfamilia(index);
    });
    if (_ListaSubFamiliasImagenes != null) {
      itemImagenSubFamilia = _ListaSubFamiliasImagenes.firstWhere(
          (obj) => obj.idsubFamilia == int.parse(_currentsubfamilia),
          orElse: () => null);
    }
  }

  Widget WidgetFamilias() {
    return Container(
        height: 140,
        child: ListView.builder(
            controller: autocontrollerFamilia,
            scrollDirection: Axis.horizontal,
            itemCount: _ListaFamilias.length,
            itemExtent: 100,
            itemBuilder: (context, index) {
              var _familia = _ListaFamilias[index].familia.split(" ");
              var item;
              if (_ListaFamiliasImagenes != null) {
                item = _ListaFamiliasImagenes.firstWhere(
                    (obj) => obj.idfamilia == _ListaFamilias[index].idfamilia,
                    orElse: () => null);
              }
              return GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: _wrapScrollTag(
                        index: index,
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                          alignment: Alignment.topCenter,
                          height: 120,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorApp3, //Colors.lightBlue,
                                  width: (index == clase.getIndex()) ? 3 : 0),
                              borderRadius: BorderRadius.circular(12)),
                          child:
                          (item!=null)?
                          Image.memory(
                            base64Decode(item.imagenbase64),
                            scale: 1.0,
                            width: _widthImagen,
                            height:_heightImagen,
                          ):
                          Column(
                            children: [
                              CircleAvatar(
                                child:
                                Container(
                                  width: _widthImagen,
                                  height: _heightImagen,
                                ),
                                radius: 30,
                                backgroundColor: (_currentfamilia ==
                                        _ListaFamilias[index]
                                            .idfamilia
                                            .toString())
                                    ? colorApp3 //Colors.blueGrey
                                    : Colors.white,
                                  backgroundImage: AssetImage(rutaFamilia),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    (_familia.length >= 1)
                                        ? Text(
                                            _familia[0],
                                            style: TextStyle(
                                              color: (_currentfamilia ==
                                                      _ListaFamilias[index]
                                                          .idfamilia
                                                          .toString())
                                                  ? colorApp2
                                                  : colorApp3, //Colors.blueGrey,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    (_familia.length >= 2)
                                        ? Text(
                                            _familia[1],
                                            style: TextStyle(
                                              color: (_currentfamilia ==
                                                      _ListaFamilias[index]
                                                          .idfamilia
                                                          .toString())
                                                  ? colorApp2
                                                  : colorApp3, //Colors.blueGrey,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    (_familia.length >= 3)
                                        ? Text(
                                            _familia[2],
                                            style: TextStyle(
                                              color: (_currentfamilia ==
                                                      _ListaFamilias[index]
                                                          .idfamilia
                                                          .toString())
                                                  ? colorApp2
                                                  : colorApp3, //Colors.blueGrey,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                  onTap: () {
                    if (_currentfamilia !=
                        _ListaFamilias[index].idfamilia.toString())
                      changefamilia(
                          _ListaFamilias[index].idfamilia.toString(), index);
                  });
            }));
  }

  Widget WidgetSubFamilias() {
    bool MostrarSubfamilias =
        (Sector != 'ROPA' && _ListaSubFamilias.length > 0);
    return (MostrarSubfamilias)
        ? Container(
            height: 80.0,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              controller: autocontrollerSubFamilia,
              scrollDirection: Axis.horizontal,
              itemCount: _ListaSubFamilias.length,
              itemBuilder: (BuildContext context, int index) {
                var _subfamilia =
                    _ListaSubFamilias[index].subFamilia.split(" ");
                return GestureDetector(
                    child: _wrapScrollSubFamiliaTag(
                      index: index,
                      child: Container(
                        margin: EdgeInsets.all(4.0),
                        width: 160.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: colorApp3, //Colors.lightBlue,
                            width:
                                (index == clase.getIndexsubfamilia()) ? 3 : 0,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Colors.white,
                            ],
                          ),
                        ),
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                (_subfamilia.length >= 1)
                                    ? Text(
                                        _subfamilia[0],
                                        style: TextStyle(
                                          color: colorApp2, // Colors.blueGrey,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.8,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                (_subfamilia.length >= 2)
                                    ? Text(
                                        _subfamilia[1],
                                        style: TextStyle(
                                          color: colorApp2, // Colors.blueGrey,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.8,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                (_subfamilia.length >= 3)
                                    ? Text(
                                        _subfamilia[2],
                                        style: TextStyle(
                                          color: colorApp2, // Colors.blueGrey,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.8,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    //onLongPress: () {
                    //  setState(() {});
                    //},
                    onTap: () {
                      if (_currentsubfamilia !=
                          _ListaSubFamilias[index].idsubFamilia.toString())
                        changeSubfamilia(
                            _ListaSubFamilias[index].idsubFamilia.toString(),
                            index);
                    });
              },
            ),
          )
        : SizedBox.shrink();
  }

  Widget WidgetNumeroArticulos() {
    var numero =
        (Sector == 'ROPA') ? _ListaSubFamilias.length : _ListaArticulos.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {},
          child: Text('Nº ARTICULOS ${numero}',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.0,
                color: Color(0xFF0F538F),
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _ListaArticulos = _ListaArticulos.where((i) =>
        i.idFamilia == int.parse(clase.getID()) &&
        i.idSubFamilia == int.parse(clase.getIDsubfamilia())).toList();
    return Scaffold(
      body: (isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(children: [
                WidgetFamilias(),
                WidgetSubFamilias(),
                WidgetListaArticulos(),
                WidgetNumeroArticulos(),
              ]),
            ),
    );
    //return null;
  }
}

class WidgetListaArticulos extends StatefulWidget {
  WidgetListaArticulos() {}
  @override
  _WidgetListaArticulosState createState() => _WidgetListaArticulosState();
}

class _WidgetListaArticulosState extends State<WidgetListaArticulos> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _lista;
    (Sector == 'ROPA') ? _lista = _ListaSubFamilias : _lista = _ListaArticulos;
    return Expanded(
      child: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        color: colorApp3,
        backgroundColor: colorletraApp,
        height: 80.0,
        onRefresh: () async {
          //ESTA LA OPCION DE MENU ACCTUALIZAR
           // await getINI();
          // setState(() {isLoading = true;});
           // await getFamilias();
           // await getSubFamilias();
           // await getArticulos();
           // if (Sector == 'ROPA') {
           //   getImagenesSubFamilias();
           // }
           // getImagenesArticulos();
          /*  _ListaFamilias = lista_familias_WebS;
            _ListaSubFamilias = lista_subfamilias_WebS;
            _ListaArticulos = lista_articulos_WebS;
            _ListaCompletaArticulos = _ListaArticulos;
            _ListaCompletaSubFamilias = _ListaSubFamilias;*/
            _ListaSubFamiliasImagenes = lista_imagenesSubFamilias_WebS;
            _ListaImagenes = lista_imagenesArticulos_WebS;
           // setState(() {isLoading = false;});
        },
        child: ListView.builder(
            itemCount: _lista.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: (Sector == 'ROPA')
                      ? WidgetItemRopa(index)
                      : WidgetItem(index),
                ),
              );
            }),
      ),
    );
  }
}

class WidgetItem extends StatefulWidget {
  int index;
  WidgetItem(this.index);
  @override
  createState() => _WidgetItem(index);
}
class _WidgetItem extends State<WidgetItem> {
  int index;
  TextEditingController _eCtrlCantidad;
  TextEditingController _CtrlComentario;
  _WidgetItem(this.index) {}
  final _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _eCtrlCantidad.selection = TextSelection(
            baseOffset: 0, extentOffset: _eCtrlCantidad.text.length);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _eCtrlCantidad.dispose();
    if (_CtrlComentario != null) _CtrlComentario.dispose();
  }

  Widget WidgetPrecioPromocionado() {
    bool EnPromocion = (_ListaArticulos[index].precioPromocion != 0 &&
        _ListaArticulos[index].precioPromocion <
            _ListaArticulos[index].precioCliente);
    return Row(
      children: [
        Text(
          NumberFormat.simpleCurrency()
              .format(_ListaArticulos[index].precioCliente), // 123.456,00 €
          style: TextStyle(
            fontSize: (EnPromocion) ? 14.0 : 16.0,
            fontFamily: 'Roboto',
            decoration: (EnPromocion) ? TextDecoration.lineThrough : null,
            color: (EnPromocion) ? Colors.black45 : null,
          ),
          textAlign: TextAlign.end,
        ),
        (EnPromocion)
            ? Text(
                '  ' +
                    NumberFormat.simpleCurrency().format(
                        _ListaArticulos[index].precioPromocion), // 123.456,00 €
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.end,
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget WidgetCantidad() {
    return (API.GetPermitirVenderSinStock() == 'No' &&
            _ListaArticulos[index].stock <= 0)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                  child: Expanded(
                    child: Text(
                      API.GetTextoNoDisponible()??'AGOTADO',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ])
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: colorApp2,
                          size: 25.0,
                        ),
                        onPressed: () {
                          if (_ListaArticulos[index].cantidad > 0 || API.varClienteDePrepago()==false) {
                            _ListaArticulos[index].cantidad -= 1;
                            _eCtrlCantidad.text = _ListaArticulos[index].cantidad.toString();
                          }
                        },
                      ),
                      Container(
                        width: 50,
                        child: TextFormField(
                          controller: _eCtrlCantidad,
                          focusNode: _focusNode,
                          onChanged: (text) {
                            _ListaArticulos[index].cantidad =
                                double.parse(text);
                          },
                          onFieldSubmitted: (term) {
                            setState(() {}); // process
                          },
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: colorApp2, //Colors.blueGrey,
                            fontSize: 18.0,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          // autofocus: true,
                          //initialValue:_ListaArticulos[index].idFamilia.toString()
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            color: colorApp2,
                            size: 25.0,
                          ),
                          onPressed: () {
                            _ListaArticulos[index].cantidad += 1;
                            _eCtrlCantidad.text =
                                _ListaArticulos[index].cantidad.toString();
                          }),
                      //                 SizedBox(width: 15,),
                    ],
                  ),
                ],
              ),
            ],
          );
  }

  Widget WidgetComentario() {
    return (_ListaArticulos[index].comentarioAPP != '' && _ListaArticulos[index].comentarioAPP != null)
        ? Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Expanded(
                child: Text(
                  _ListaArticulos[index].comentarioAPP,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ]),
        )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    _eCtrlCantidad = TextEditingController(
        text: (_ListaArticulos[index].cantidad == 0.0)
            ? ''
            : _ListaArticulos[index].cantidad.toString());
    _CtrlComentario = TextEditingController(
        text: (_ListaArticulos[index].observacion == null)
            ? ''
            : _ListaArticulos[index].observacion.toString());
    var item;
    var itemImagenArticulo = _ListaImagenes.firstWhere(
        (obj) => obj.idArticulo == _ListaArticulos[index].idArticulo,
        orElse: () => null);
    if (itemImagenArticulo == null)
      item = itemImagenSubFamilia;
    else
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
                InkWell(
                  child: Container(
                      width: _widthImagen,
                      height: _heightImagen,
                      child: (item == null)
                          ? Image.asset(
                              rutaArticulo,
                              fit: BoxFit.contain,
                            )
                          : Image.memory(
                              base64Decode(item.imagenbase64),
                              scale: 1.0,
                              width: 100.0,
                              height: 100.0,
                            )),
                  onTap: () async {
                    final result = await Navigator.push(
                        context,
                        ScaleRoute(
                            page: FichaArticulo(
                          heroTag: _ListaArticulos[index].articulo,
                          idarticulo: _ListaArticulos[index].idArticulo,
                          articulo: _ListaArticulos[index].articulo,
                          precio: _ListaArticulos[index].precio,
                          precioCliente: _ListaArticulos[index].precioCliente,
                          precioPromocion: _ListaArticulos[index].precioPromocion,
                          dto: _ListaArticulos[index].dto,
                          ObservacionesArticulo: _ListaArticulos[index].ObservacionesArticulo,
                          item: item,
                        ), ms: 500));
                    if (result=='REFRESH'){
                      setState(() {});
                    }
                  },
                ),
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
                          '${_ListaArticulos[index].articulo}', //${_ListaArticulos[index].idArticulo} -
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WidgetPrecioPromocionado(),
                          IconButton(
                            icon: Icon(Icons.comment,
                                color: Colors.black38, size: 30.0),
                            onPressed: () {
                              if (_ListaArticulos[index].cantidad > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  backgroundColor: Colors.white,
                                  duration: Duration(minutes: 1),
                                  content: TextFormField(
                                    controller: _CtrlComentario,
                                    textCapitalization:
                                    TextCapitalization.sentences,
                                    onChanged: (text) {
                                      _ListaArticulos[index].observacion = text;
                                    },
                                    onFieldSubmitted: (term) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.comment,
                                          color: Colors.black45,
                                        ),
                                        labelStyle:
                                        TextStyle(color: Colors.black26),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black26)),
                                        hintStyle: new TextStyle(
                                          inherit: true,
                                          fontSize: 18.0,
                                          fontFamily: "WorkSansLight",
                                          color: Colors.black26,
                                        ),
                                        hintText: 'Comentario'),
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18.0,
                                      fontFamily: 'Roboto',
                                      //fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                    autofocus: true,
                                    //initialValue:_ListaArticulos[index].idFamilia.toString()
                                  ),
                                  action: SnackBarAction(
                                    textColor: Colors.black54,
                                    label: 'Cerrar',
                                    onPressed: () {
                                      setState(() {});
                                    },
                                  ),
                                ));
                            }
                            },
                          )
                        ],
                      ),
                      WidgetCantidad(),
                    ],
                  ),
                ),
              ],
            ),
            (_ListaArticulos[index].observacion == '' ||
                    _ListaArticulos[index].observacion == null)
                ? SizedBox(
                    height: 5,
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Text(
                    (_ListaArticulos[index].observacion) ?? '',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ]),
            WidgetComentario(),
          ]),
    );
  }
}

class WidgetItemRopa extends StatefulWidget {
  int index;
  WidgetItemRopa(this.index);
  @override
  createState() => _WidgetItemRopa(index);
}
class _WidgetItemRopa extends State<WidgetItemRopa> {
  int index;
  double precio = 0, precioCliente = 0, precioPromocion = 0, dto = 0;
  AutoScrollController autocontrollerColores;
  List<Articulo_Colores_Tallas> _ListaColores = [];

  _WidgetItemRopa(this.index) {}

  @override
  void initState() {
    super.initState();
    autocontrollerColores = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
      //suggestedRowHeight: 130
    );
  }

  @override
  void dispose() {
    super.dispose();
    autocontrollerColores.dispose();
  }

  Widget widgetNombreSubFamilia(index) {
    return Container(
      child: Text(
        '${_ListaSubFamilias[index].subFamilia}', //${_ListaArticulos[index].idArticulo} -
        style: TextStyle(
          fontSize: 14.0,
          fontFamily: 'Roboto',
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget widgetBotonVerMas(item) {
    return InkWell(
        onTap: () {
          VerFichaArticulo(item);
        },
        child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 1.75),
            ),
            height: 50.0,
            width: 50.0,
            child: Center(
              child: Text('Ver',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    color: Colors.grey.withOpacity(0.7),
                  )),
            )));
  }

  Widget WidgetCargarStocksArticulos(index, item) {
    bool EnPromocion = false;
    bool _MirarStock = false;
    double _stockColor = 0;
    double _stockSubfamilia = 0;
    //------------------------------------------------------------
    if (API.GetPermitirVenderSinStock() == 'No') _MirarStock = true;

    //------------------------------------------------------------
    _ListaArticulos = _ListaCompletaArticulos;
    _ListaArticulos = _ListaArticulos.where((i) => i.idSubFamilia == _ListaSubFamilias[index].idsubFamilia).toList();
    if (_ListaArticulos.length > 0) {
      EnPromocion = (_ListaArticulos[0].precioPromocion != 0 &&
          _ListaArticulos[0].precioPromocion <
              _ListaArticulos[0].precioCliente);
      precio = _ListaArticulos[0].precio;
      precioCliente = _ListaArticulos[0].precioCliente;
      precioPromocion = _ListaArticulos[0].precioPromocion;
      dto = _ListaArticulos[0].dto;

      List<Articulos> _ListaArticulosFiltradoColor = [];
      List<Articulo_Tallas> ListTallas = [];
      _ListaColores = [];
      _stockSubfamilia = 0;
      for (var x = 0; x < _ListaArticulos.length; x++) {
        String _color = _ListaArticulos[x].color;
        _stockColor = 0;
        //_color AÑADIR SI NO ESTA.. _color !='' &&.
        if (_ListaColores.indexWhere((user) => user.color == _color) == -1) {
          _ListaArticulosFiltradoColor = _ListaArticulos;
          _ListaArticulosFiltradoColor =
              _ListaArticulosFiltradoColor.where((i) => i.color == _color)
                  .toList();
          ListTallas = [];
          for (var y = 0; y < _ListaArticulosFiltradoColor.length; y++) {
            _stockColor = _stockColor + _ListaArticulosFiltradoColor[y].stock;
            if ((_MirarStock && _ListaArticulosFiltradoColor[y].stock > 0) ||
                _MirarStock == false) {
              ListTallas.add(Articulo_Tallas(
                talla: _ListaArticulosFiltradoColor[y].talla,
                stockTalla: _ListaArticulosFiltradoColor[y].stock,
                precio: _ListaArticulosFiltradoColor[y].precio,
                precioPromocion:
                    _ListaArticulosFiltradoColor[y].precioPromocion,
                precioCliente: _ListaArticulosFiltradoColor[y].precioCliente,
                idArticulo: _ListaArticulosFiltradoColor[y].idArticulo,
                articulo: _ListaArticulosFiltradoColor[y].articulo,
              ));
            }
          }
          if ((_MirarStock && _stockColor > 0) || _MirarStock == false) {
            _ListaColores.add(Articulo_Colores_Tallas(
                color: _color, stockColor: _stockColor, tallas: ListTallas));
          }
          _stockSubfamilia = _stockSubfamilia + _stockColor;
        }
      }
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    NumberFormat.simpleCurrency()
                        .format(_ListaArticulos[0].precioCliente),
                    style: TextStyle(
                      fontSize: (EnPromocion) ? 14.0 : 16.0,
                      fontFamily: 'Roboto',
                      decoration:
                          (EnPromocion) ? TextDecoration.lineThrough : null,
                      color: (EnPromocion) ? Colors.black45 : null,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  (EnPromocion)
                      ? Text(
                          '  ' +
                              NumberFormat.simpleCurrency()
                                  .format(_ListaArticulos[0].precioPromocion),
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.end,
                        )
                      : SizedBox.shrink(),
                ],
              ),
              (_ListaColores.length>0)?widgetBotonVerMas(item):SizedBox.shrink(),
            ],
          ),
          (_MirarStock && _stockSubfamilia == 0)
              ? Column(
                children: [
                  SizedBox(height: 10,),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Container(
                        child: Expanded(
                          child: Text(
                            API.GetTextoNoDisponible()??'AGOTADO',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Roboto',
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ]),
                ],
              )
              : SizedBox.shrink(),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget WidgetColores(index) {
    return Container(
      height: 40.0,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        controller: autocontrollerColores,
        scrollDirection: Axis.horizontal,
        itemCount: _ListaColores.length,
        itemBuilder: (BuildContext context, int index) {
          var _color = _ListaColores[index].color.split(" ");
          return Container(
            margin: EdgeInsets.all(5.0),
            width: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: colorApp3, //Colors.lightBlue,
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                ],
              ),
            ),
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    (_color.length >= 1)
                        ? Text(
                            _color[0],
                            style: TextStyle(
                              color: colorApp2, //Colors.blueGrey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                            ),
                          )
                        : SizedBox.shrink(),
                    (_color.length >= 2)
                        ? Text(
                            _color[1],
                            style: TextStyle(
                              color: colorApp2, //Colors.blueGrey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                            ),
                          )
                        : SizedBox.shrink(),
                    (_color.length >= 3)
                        ? Text(
                            _color[2],
                            style: TextStyle(
                              color: colorApp2, //Colors.blueGrey,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> VerFichaArticulo(item) async {
    if (_ListaColores.length>0) {
      final result = await Navigator.push(
          context,
          ScaleRoute(
              page: ChangeNotifierProvider(
                  create: (_) =>
                      CambioModelo(IDModelo: _ListaSubFamilias[index].idsubFamilia),
                    child: FichaArticuloTallas(
                    heroTag: _ListaSubFamilias[index].subFamilia,
                    idsubFamilia: _ListaSubFamilias[index].idsubFamilia,
                    subFamilia: _ListaSubFamilias[index].subFamilia,
                    dto: dto,
                    item: item,
                    listaColores: _ListaColores,
                  )), ms: 500));
      if (result=='REFRESH'){
        setState(() {});
      }
      //if (result == 'OK') {
        //  context.read<ChangePage>().setPage('Articulo');
        //  Navigator.pop(context, 'OK');
      //}
    }
  }

  @override
  Widget build(BuildContext context) {
    var item;
    var itemImagen = _ListaSubFamiliasImagenes.firstWhere(
        (obj) => obj.idsubFamilia == _ListaSubFamilias[index].idsubFamilia,
        orElse: () => null);
    item = itemImagen;

    return InkWell(
      onTap: () {
        VerFichaArticulo(item);
      },
      child: Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: Container(
                        width: _widthImagen,
                        height: _heightImagen,
                        child: (item == null)
                            ? Image.asset(
                                rutaArticulo,
                                fit: BoxFit.contain,
                              )
                            : Image.memory(
                                base64Decode(item.imagenbase64),
                                scale: 1.0,
                                width: 100.0,
                                height: 100.0,
                              )),
                    onTap: () {
                      VerFichaArticulo(item);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widgetNombreSubFamilia(index),
                        WidgetCargarStocksArticulos(index, item),
                        // WidgetColores(index),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
