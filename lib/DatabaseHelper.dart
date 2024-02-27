import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'Datos/Articulos.dart';
import 'Datos/PedidoLin.dart';
import 'Datos/PedidoCab.dart';
import 'Principal.dart';

num iNumLineas=0;
List<Map> queryList_LinHistorico;

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();
  DBHelper.internal();
  factory DBHelper() => _instance;
  static Database _db;
  String path = 'Pedidos1.db';

  num get NumReg => iNumLineas;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDB();
    return _db;
  }
  Future<Database> initDB() async {
    // io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDirectory.path, 'fworkout.db');
    Database db = await openDatabase(
      path,
      //version: 1,
      //version: 2,
      version: 3,
      onCreate: _createTables,
      onUpgrade:_UpgradeTables,
    );
    print('[DPedidos] initDB: Success');
    return db;
  }

  void borrarDB() async {
    await deleteDatabase(path);
    print('[DBHelper] deleteDatabase: Success ');
  }
  void cerrarDB() async {
    var dbClient = await db;
    await dbClient.close();
    print('[DBHelper] closeDatabase: Success ');
  }

  void _createTables(Database db, int version) async {
    //PEDIDO ACTUAL.
    await db.execute(
      'CREATE TABLE PedidoLin(idpedido INTEGER, numlin INTEGER, idarticulo INTEGER, articulo TEXT, precio REAL, cantidad REAL, importe REAL, comentario TEXT)',
    );
    await db.execute(
      'CREATE TABLE PedidoCab(idpedido INTEGER, fecha TEXT, fechaservicio TEXT, importetotal REAL, observaciones TEXT, fechaenvio TEXT, nombrepedido TEXT, licencia TEXT)',
    );
    //PEDIDO HISTORICOS.
    await db.execute(
      'CREATE TABLE PedidoCab_Hist(idpedido INTEGER PRIMARY KEY AUTOINCREMENT, fecha TEXT, fechaservicio TEXT, importetotal REAL, observaciones TEXT, fechaenvio TEXT, nombrepedido TEXT, licencia TEXT)',
    );
    await db.execute(
      'CREATE TABLE PedidoLin_Hist(idpedido INTEGER, numlin INTEGER, idarticulo INTEGER, articulo TEXT, precio REAL, cantidad REAL, importe REAL, comentario TEXT)',
    );
    //ARTICULOS.
    await db.execute(
      'CREATE TABLE Articulos(idArticulo INTEGER, articulo TEXT, precio REAL, idFamilia INTEGER)',
    );
    print('[DBHelper] _createTables: Success');
  }
  void _UpgradeTables(Database db, int oldVersion, int newVersion) {
    if (oldVersion < 2) {
      //SE AÑADEN EN LA version: 2,
      db.execute("ALTER TABLE PedidoCab ADD COLUMN nombrepedido TEXT;");
      db.execute("ALTER TABLE PedidoCab_Hist ADD COLUMN nombrepedido TEXT;");
    }
    if (oldVersion < 3) {
      //SE AÑADEN EN LA version: 3,
      db.execute("ALTER TABLE PedidoCab ADD COLUMN licencia TEXT;");
      db.execute("ALTER TABLE PedidoCab_Hist ADD COLUMN licencia TEXT;");
    }
  }

  Future<void> ModificarLineaPedido(idpedido, numlin, cantidad, importe, comentario) async {
    var dbClient = await db;
    dbClient.transaction((trans)  {
      return trans.rawUpdate(
          'UPDATE PedidoLin SET cantidad = ?, importe = ?, comentario = ?'
          'WHERE numlin = ? ',
          [cantidad, importe, comentario, numlin]
      );
    });
    print('[DBHelper] update pedidolin: | $numlin, $cantidad, $importe');
  }
  Future<void> ModificarCabeceraPedido(idpedido, importetotal, fechaservicio, fechaenvio) async {
    var dbClient = await db;
    dbClient.transaction((trans)  {
      return trans.rawUpdate(
          'UPDATE PedidoCab SET importetotal = ?, fechaservicio = ?, fechaenvio = ?'
              'WHERE idpedido = ? ',
          [importetotal, fechaservicio, fechaenvio, idpedido]
      );
    });
    print('[DBHelper] update pedidoCab: | $idpedido, $importetotal');
  }
  Future<void> ModificarCampoCabeceraPedido(idpedido, Campo, Valor) async {
    var dbClient = await db;
    String sql='UPDATE PedidoCab SET ${Campo} = ? WHERE idpedido = ? ';
    dbClient.transaction((trans)  {
      return trans.rawUpdate(
          sql,
          [Valor,  idpedido]
      );
    });
    print('[DBHelper] update pedidoCab: | $idpedido, $Campo, $Valor ');
  }
  void savePedidoLin(String tabla, int idpedido, int numlin, int idarticulo, String articulo,double precio, double cantidad, double importe, String comentario) async {
    var dbClient = await db;
    dbClient.transaction((trans)  {
      return trans.rawInsert(
          'INSERT INTO ${tabla}'
          '(idpedido, numlin, idarticulo, articulo, precio, cantidad, importe, comentario)'
          'VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
          [idpedido, numlin, idarticulo, articulo, precio, cantidad, importe, comentario]
          );
    });
    iNumLineas++;
  }
  Future<void> TransferHistorico_A_Pedido() async {
    List<PedidoCab> _listaCab = [];
    List<PedidoLin> _listaLin = [];
    int numlineas=0;
    double importetotal;
    double precio=0;
    double importe=0;
    bool EnPromocion=false;
    String fechaservicio;
    List<Map> queryList;
    queryList=queryList_LinHistorico;
    await getCabeceraPedido('PedidoCab').then((response) async {
      _listaCab = response;
      if (_listaCab != null && _listaCab.length > 0) {
        importetotal=_listaCab[0].importetotal;
        fechaservicio=_listaCab[0].fechaservicio;
      }
    });
    await getLineasPedido('PedidoLin', 0 ).then((response) {
      _listaLin = response;
      if (_listaLin != null) numlineas=_listaLin.length;
    });

    if (queryList != null && queryList.length > 0) {
      List<Articulos> _listaArticulos = [];
      for (int i = 0; i < queryList.length; i++) {
        var idArticulo = queryList[i]['idarticulo'];
        _listaArticulos = lista_articulos_WebS.where((i) => i.idArticulo == idArticulo).toList();
        if (_listaArticulos.length > 0){
          //COMPRUEBO EL PRECIO ACCTUAL, NO EL GUARDADO EN LOS PEDIDOS-------
          EnPromocion= (_listaArticulos[0].precioPromocion != 0 && _listaArticulos[0].precioPromocion < _listaArticulos[0].precioCliente);
          precio = (EnPromocion) ? _listaArticulos[0].precioPromocion : _listaArticulos[0].precioCliente;
          importe = queryList[i]['cantidad'] * precio;
          importetotal+=importe;
          numlineas++;
          savePedidoLin(
              'PedidoLin',
              1,
              numlineas,
              queryList[i]['idarticulo'],
              queryList[i]['articulo'],
              precio,
              queryList[i]['cantidad'],
              importe,
              queryList[i]['comentario']
          );
        }
      }
    }
    await ModificarCabeceraPedido(1, importetotal, fechaservicio, null);
  }

  bool articuloPermitido(int idArticulo){

  }

  void deletePedidoLin(String tabla) async {
    var dbClient = await db;
    dbClient.transaction((trans) {
      return trans.delete('${tabla}');
    });
    iNumLineas=0;
  }
  void deletePedidoCab(String tabla, int idpedido) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      return await trans.delete('${tabla}');
      //return await trans.delete('${tabla}', where: '$idpedido = ?', whereArgs: [idpedido]);
    });
    //count = await database
    //    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    print('[DBHelper] deletePedidoCab: Success ');
  }
  void deletePedidoCabHistorico(int idpedido) async {
    String tabla = 'PedidoCab_Hist';
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      return await trans.rawDelete('DELETE FROM ${tabla} WHERE idpedido = ?', [idpedido]);
    });
    print('[DBHelper] deletePedidoCabHistorico: Success ');
  }
  Future<void> TransferPedido_A_Historico() async {
    List<PedidoCab> _listaCab = [];
    List<PedidoLin> lista_Lin = [];
    await getCabeceraPedido('PedidoCab').then((response) async {
      _listaCab = response;
      if (_listaCab != null) {
        final IDPedido =await savePedidoCab('PedidoCab_Hist',0, _listaCab[0].fecha, _listaCab[0].fechaservicio, _listaCab[0].observaciones, _listaCab[0].importetotal,_listaCab[0].fechaenvio, _listaCab[0].nombrepedido);
        await getLineasPedido('PedidoLin', 0 ).then((response) {
          lista_Lin = response;
          if (lista_Lin != null) {
            for (var x = 0; x < lista_Lin.length; x++) {
              savePedidoLin(
                  'PedidoLin_Hist',
                  IDPedido,
                  lista_Lin[x].numLin,
                  lista_Lin[x].idArticulo,
                  lista_Lin[x].articulo,
                  lista_Lin[x].precio,
                  lista_Lin[x].cantidad,
                  lista_Lin[x].importe,
                  lista_Lin[x].comentario);
            }
          }
        });
      }
    });
    await ModificarCabeceraPedido(1, 0, null, null);
    await ModificarCampoCabeceraPedido(1, 'fechaservicio', null);
    await deletePedidoLin('PedidoLin');
  }
  Future<void> Insertar_en_Pedido(int idarticulo, String articulo, double precio,) async {
    List<PedidoCab> _listaCab = [];
    List<PedidoLin> _listaLin = [];
    int numlineas=0;
    double importetotal;
    String fechaservicio;
    await getCabeceraPedido('PedidoCab').then((response) async {
      _listaCab = response;
      if (_listaCab != null && _listaCab.length > 0) {
        importetotal=_listaCab[0].importetotal;
        fechaservicio=_listaCab[0].fechaservicio;
      }
    });
    await getLineasPedido('PedidoLin', 0 ).then((response) {
      _listaLin = response;
      if (_listaLin != null) numlineas=_listaLin.length;
    });
        importetotal+=precio;
        numlineas++;
        savePedidoLin(
            'PedidoLin',
            1,
            numlineas,
            idarticulo,
            articulo,
            precio,
            1, //cantidad,
            precio,   //importe,
            ""  //comentario
        );
    await ModificarCabeceraPedido(1, importetotal, fechaservicio, null);
  }
  savePedidoCab(String tabla, int idpedido, String fecha, String fechaservicio, String Observaciones, double importetotal, String fechaenvio, String nombrepedido) async {
    var dbClient = await db;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String licencia = (prefs.getString('licencia') ?? "");
    int ID;
    await dbClient.transaction((trans) async {
      if (tabla == 'PedidoCab') {
        ID =await trans.rawInsert(
            'INSERT INTO ${tabla}'
            '(idpedido, fecha, fechaservicio, importetotal, Observaciones, fechaenvio, nombrepedido, licencia)'
            'VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
            [idpedido, fecha, fechaservicio, importetotal, Observaciones, fechaenvio, nombrepedido, licencia]);
      } else
        ID= await trans.rawInsert(
            'INSERT INTO ${tabla}'
            '(fecha, fechaservicio, importetotal, Observaciones, fechaenvio, nombrepedido, licencia)'
            'VALUES(?, ?, ?, ?, ?, ?, ?)',
            [fecha, fechaservicio, importetotal, Observaciones, fechaenvio, nombrepedido, licencia]);
    });
    print('[DBHelper] save ${tabla}: Success | ((${idpedido}==0)$ID:$idpedido), $fechaservicio, $importetotal, $licencia');
    return ID;
  }

  Future<int> getCount(String tabla) async {
    var dbClient = await db;
    var x = await dbClient.rawQuery('SELECT COUNT (*) from $tabla');
    int count = Sqflite.firstIntValue(x);
    return count;
  }

  CountNumLineasPedidoActual() async {
    int ID = await getCount('PedidoLin');
    //SI HAY LINEAS DE OTRA LICENCIA A LICENCIA ACTUAL.
    bool borrar=false;
    if (ID>0) {
      var dbClient = await db;
      String licencia_BD='';
      List<Map> queryList = await dbClient.rawQuery('SELECT * FROM PedidoCab');
      if (queryList != null && queryList.length > 0) {
        licencia_BD=queryList[0]['licencia'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String licencia = (prefs.getString('licencia') ?? "");
        if (licencia_BD==null) {
          borrar=true;
        }else {
          if (licencia.toUpperCase() != licencia_BD.toUpperCase())
            borrar = true;
        }
        if (borrar){
          await deletePedidoCab('PedidoCab', 1);
          await deletePedidoLin('PedidoLin');
          ID = 0;
        }
      }else{
       // await deletePedidoLin('PedidoLin');
       // ID = 0;
      }
    }
    iNumLineas=ID;
    return ID;
  }

  Future<List<PedidoLin>> getLineasPedido(String tabla, int ID) async {
    var dbClient = await db;
    List<PedidoLin> usersList = [];
    if (ID==0) {
      queryList_LinHistorico = await dbClient.rawQuery('SELECT * FROM ${tabla}',);
    }else{
      queryList_LinHistorico = await dbClient.rawQuery('SELECT * FROM ${tabla} WHERE idpedido= $ID');
    }
    if (queryList_LinHistorico != null && queryList_LinHistorico.length > 0) {
      for (int i = 0; i < queryList_LinHistorico.length; i++) {
        usersList.add(PedidoLin(
            numLin: queryList_LinHistorico[i]['numlin'],
            idArticulo: queryList_LinHistorico[i]['idarticulo'],
            articulo: queryList_LinHistorico[i]['articulo'],
            precio: queryList_LinHistorico[i]['precio'],
            cantidad: queryList_LinHistorico[i]['cantidad'],
            importe: queryList_LinHistorico[i]['importe'],
            comentario: queryList_LinHistorico[i]['comentario']));
      }
      iNumLineas=queryList_LinHistorico.length;
      return usersList;
    } else
      return null;
  }
  ObtenerFechaActual() {
    String FechaActual;
    var formatter = DateFormat('dd-MM-yyyy');
    FechaActual = formatter.format(DateTime.now());
    return FechaActual;
  }

  Future<List<PedidoCab>> getPedidosHistorico(String tabla, int Enviados) async {
    var dbClient = await db;
    List<PedidoCab> usersList = [];
    List<Map> queryList;
    if (Enviados==null) Enviados=2;
    if (Enviados==2)  //TODOS
      queryList = await dbClient.rawQuery('SELECT * FROM ${tabla} ORDER BY idpedido DESC',);  //// WHERE comentario=\'$comentario\'',
    else if (Enviados==0) //SOLO LOS SIN ENVIAR
      queryList = await dbClient.rawQuery('SELECT * FROM ${tabla} WHERE fechaenvio IS NULL ORDER BY idpedido DESC',);
    else                  //SOLOS LOS ENVIADOS
      queryList = await dbClient.rawQuery('SELECT * FROM ${tabla} WHERE fechaenvio IS NOT NULL ORDER BY idpedido DESC',);

    if (queryList != null && queryList.length > 0) {
      for (int i = 0; i < queryList.length; i++) {
        usersList.add(PedidoCab(
            id: queryList[i]['idpedido'],
            fecha: queryList[i]['fecha'],
            fechaservicio: queryList[i]['fechaservicio'],
            importetotal: queryList[i]['importetotal'],
            observaciones: queryList[i]['observaciones'],
            fechaenvio: queryList[i]['fechaenvio'],
            nombrepedido: queryList[i]['nombrepedido'],
            licencia: queryList[i]['licencia']
        ));
      }
    }
    return usersList;
  }

  Future<List<PedidoCab>> getCabeceraPedido(String tabla) async {
    var dbClient = await db;
    List<PedidoCab> usersList = [];
    List<Map> queryList = await dbClient.rawQuery(
      'SELECT * FROM ${tabla} ORDER BY idpedido DESC', // WHERE comentario=\'$comentario\'',
    );
    if (queryList != null && queryList.length > 0) {
      for (int i = 0; i < queryList.length; i++) {
        usersList.add(PedidoCab(
            id: queryList[i]['idpedido'],
            fecha: queryList[i]['fecha'],
            fechaservicio: queryList[i]['fechaservicio'],
            importetotal: queryList[i]['importetotal'],
            observaciones: queryList[i]['observaciones'],
            fechaenvio: queryList[i]['fechaenvio'],
            nombrepedido: queryList[i]['nombrepedido'],
            licencia: queryList[i]['licencia']
        ));
      }
    } else{
      if (tabla=='PedidoCab') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String licencia = (prefs.getString('licencia') ?? "");
        usersList.add(PedidoCab(
            id: 1,
            fecha: ObtenerFechaActual(),
            fechaservicio: ObtenerFechaActual(),
            importetotal: 0,
            observaciones: '',
            licencia: licencia,
        ));
      }
    }
    //print('[DBHelper] getCabeceraPedido: ${queryList.length} lineas Nº Pedido: ${usersList[0].id}');
    return usersList;
  }

  void saveArticulos(int idarticulo, String articulo, double precio, int idfamilia) async {
    var dbClient = await db;
    await dbClient.transaction((trans) async {
      return await trans.rawInsert(
        'INSERT INTO Articulos(idArticulo, articulo, precio, idFamilia) VALUES(\'$idarticulo\',\'$articulo\', \'$precio\', \'$idfamilia\')',
      );
    });
  }
  Future<List<Articulos>> getArticulos() async {
    var dbClient = await db;
    List<Articulos> usersList = [];
    List<Map> queryList = await dbClient.rawQuery(
      'SELECT * FROM Articulos', // WHERE articulo=\'$articulo\' AND comentario=\'$comentario\'',
    );
    print('[DBHelper] getArticulos: ${queryList.length} lineas');
    if (queryList != null && queryList.length > 0) {
      for (int i = 0; i < queryList.length; i++) {
        usersList.add(Articulos(
          idArticulo: queryList[i]['idArticulo'],
          articulo: queryList[i]['articulo'],
          precio: queryList[i]['precio'],
        ));
      }
      print('[DBHelper] getArticulos: ${usersList.length}');
      return usersList;
    } else {
      print('[DBHelper] getArticulos: Articulos is null');
      return null;
    }
  }
}
