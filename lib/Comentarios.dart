
// Text('${ImporteTotal.toStringAsFixed(2)}'),

/*  Future<Null> LoadArticulos_from_DB() async {
    isLoading=true;
    dbHelper.getArticulos().then((response) {
      setState(() {
        isLoading=false;
        lista_articulos=response;
        if (lista_articulos != null && lista_articulos.length > 0)
        {
          print('LONGITUD: ${lista_articulos.length}');
          print('[lista_articulos] _authenticateUser: Success');
        }else {
          print('[lista_articulos] _authenticateUser: Invalid credentials');
        }
      });
      return null;
    });
  }
  Future<Null> LoadArticulos_from_WebService() async {
    isLoading=true;
    API.getArticulos().then((response) {
      setState(() {
        isLoading=false;
        var lista = response.body.toString();
        Iterable list = json.decode(lista);
        if (list.length == 0) {
        } else {
          lista_articulos = list.map((model) => Articulos.fromJson(model)).toList();
          lista_articulos= lista_articulos.where((i) => i.idArticulo<30).toList();
          print('LONGITUD: ${lista_articulos.length}');
        }
      });
      return null;
    });
  }

  void SaveArticulos_to_BD() {
    for (var x = 0; x < lista_articulos_WebS.length; x++) {
      dbHelper.saveArticulos(
          lista_articulos_WebS[x].idArticulo,
          lista_articulos_WebS[x].articulo,
          lista_articulos_WebS[x].precio,
          lista_articulos_WebS[x].idFamilia);
    }
  }

  floatingActionButton: FloatingActionButton(
        onPressed: () {
          var _lista = List<Articulos>();
          _lista = _ListaArticulos.where((i) => i.cantidad > 0.0).toList();
          print('ARTICULOS A PASAR: ${_lista.length}');
          WidgetPedido();
        },
        tooltip: 'Añadir Linea',
        child: Icon(Icons.done),
      ),
  */


/*

child: ListTile(
                                title: _wrapScrollTag(
                                    index: index,
                                    child: Container(
                                      padding: EdgeInsets.all(0),
                                      alignment: Alignment.topCenter,
                                      height: 120,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.lightBlue,
                                              width: (index == clase.getIndex())
                                                  ? 4
                                                  : 0),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundColor: (_currentfamilia ==
                                                    _ListaFamilias[index]
                                                        .idfamilia
                                                        .toString())
                                                ? Colors.blueGrey
                                                : Colors.white,
                                            backgroundImage: AssetImage(
                                                'assets/familia.png'),
                                            //(_currentfamilia==_ListaFamilias[index].idfamilia.toString())?AssetImage('assets/articulo.png'):AssetImage('assets/familia.png') ,
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              (_familia.length >= 1)
                                                  ? _familia[0]
                                                  : '',
                                              style: TextStyle(
                                                color: (_currentfamilia ==
                                                        _ListaFamilias[index]
                                                            .idfamilia
                                                            .toString())
                                                    ? Colors.blue[700]
                                                    : Colors.blueGrey,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              (_familia.length >= 2)
                                                  ? _familia[1]
                                                  : '',
                                              style: TextStyle(
                                                color: (_currentfamilia ==
                                                        _ListaFamilias[index]
                                                            .idfamilia
                                                            .toString())
                                                    ? Colors.blue[700]
                                                    : Colors.blueGrey,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              (_familia.length >= 3)
                                                  ? _familia[2]
                                                  : '',
                                              style: TextStyle(
                                                color: (_currentfamilia ==
                                                        _ListaFamilias[index]
                                                            .idfamilia
                                                            .toString())
                                                    ? Colors.blue[700]
                                                    : Colors.blueGrey,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),


*/

/*


    Row(
                              children:[
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        children: [
                                        IconButton(
                                          //tooltip: 'Pedido',
                                            color: iPantalla == 'Pedido'
                                                ? Colors.white
                                                : Colors.white70,
                                                icon: Icon(Icons.shopping_cart),
                                                onPressed: () {
                                                  iPantalla = 'Pedido';
                                                  opcion = 'icon';
                                                  setState(() {});
                                                }),
                                        ],
                                      ),
                                    ]),
                                ),
                                Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                      IconButton(

                                          onPressed: () {
                                            iPantalla = 'Historico';
                                            opcion = 'icon';
                                            setState(() {});
                                    }),
                                     ],
                                  ),
                               ]),
                            ),
                              ],
                          ),



 */

/*  ObtenerImagen(int Pos) async {
    API.getImagenArticulo(lista_articulos_WebS[Pos].idArticulo).then((response) async {
      String jsonStr = response.body;
      if (jsonStr.length > 0) {
        String imagenBase64 = jsonStr.substring(17, jsonStr.length - 2);
        lista_articulos_WebS[Pos].imagenbytes = base64Decode(imagenBase64);
      }
      if (Pos == lista_articulos_WebS.length - 1) {
        isLoading=false;
        descargandoImagenes = false;
        setState(() {
        });
        // });
      }
    });
  }
  LoadImagenes_from_WebS_1_1() async {
    int total = lista_articulos_WebS.length;
    try {
      for (int x = 0; x < total; x++) {
        ObtenerImagen(x);
      }
    } catch (e) {}
  }*/