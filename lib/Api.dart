import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'Datos/PedidoCab.dart';
import 'Datos/PedidoLin.dart';
import 'Principal.dart';
import 'Utils/Dialogs.dart';
import 'package:time/time.dart';

String MANAGEMENT_TOKEN = "";
int difDias = 0;

const UrlConexionDiakrosManager =
    "https://diakrosmanager.com/diLicenciasWeb/api/";
const UrlTokemDiakrosManager =
    "https://diakrosmanager.com/diLicenciasWeb/api/Account/Login?Username=" +
        'DiaKros' +
        "&Password=" +
        'diaKros_4312';
var UrlConexionExterna =
    ''; // 'http://webapi.diakros.info:5007/api'; //IPEXTERNA;
var UrlTokemCliente =
    ''; // 'http://webapi.diakros.info:5007/api/Account/LoginCliente?Username=0&Password=0'; //(Devuelve TOKEN) POST 0,0 DIAKROS
var IDCliente =
    ''; //IDCLIENTE DE LA TIENDA QUE HACE LOS PEDIDOS, A NUESTRO CLIENTE DE DIAKROS QUE TIENE ERP DITPV.
//Licencia='DKLEAN-CLI-DIAKROS';
//Usuario='JC';
//var url ='https://diakrosmanager.com/diLicenciasWeb/api/Licencias/LicenciaAPPCliente/DKLEAN-CLI-DIAKROS/Rubio';
bool ClienteDePrepago = true;
String StripeKeySecret = '';
String StripeKeyPublic = '';
String APPCodPostalesEnvio = '';
String PreparacionHoraInicial = '';
String Sector = '';
String htmlPoliticaPrivacidad='';
String PermitirVenderSinStock = 'Si';
String TextoNoDisponible = '';
bool PermitirEnvioDomicilio=true;
double GastosEnvio = 0.0;
double GastosEnvioCliente = 999.0;
double GastosEnvioGratis = 0.0;
int IDGastosEnvio = 0;
double ImporteMinimoParaEnvio = 0.0;
bool AceptacionPoliticaAPP=true;
String RecogidaHoraInicio='';
String RecogidaHoraFin='';
int RecogidaIntervalo=0;
List<String> listaHoras;
double PctImporteMinimoPagar = 0.0;

class API {
  //VARIABLES-------------------------------------------------------------------------------------------------------------------
  static SetStripeKeySecret(String valor) {
    StripeKeySecret = valor;
  }

  static GetStripeKeySecret() {
    return StripeKeySecret;
  }

  static SetStripeKeyPublic(String valor) {
    StripeKeyPublic = valor;
  }

  static GetStripeKeyPublic() {
    return StripeKeyPublic;
  }

  static SetGastosEnvio(String valor) {
    GastosEnvio = double.parse(valor);
  }

  static GetGastosEnvio() {
    if (GastosEnvioCliente != 999.0) GastosEnvio = GastosEnvioCliente;
    return GastosEnvio;
  }

  static SetGastosEnvioGratis(String valor) {
    GastosEnvioGratis = double.parse(valor);
  }

  static GetGastosEnvioGratis() {
    if (GastosEnvioGratis == null) GastosEnvioGratis = 0;
    return GastosEnvioGratis;
  }

  static SetImporteMinimoParaEnvio(double valor) {
    ImporteMinimoParaEnvio = valor;
  }

  static GetImporteMinimoParaEnvio() {
    return ImporteMinimoParaEnvio;
  }

  static SetIDGastosEnvio(int valor) {
    IDGastosEnvio = valor;
  }

  static GetIDGastosEnvio() {
    return IDGastosEnvio;
  }
  static GetPctImporteMinimoPagar() {
    return PctImporteMinimoPagar;
  }
  static SetPctImporteMinimoPagar(double valor) {
    PctImporteMinimoPagar = valor;
  }

  static GetRecogidaHoraInicio() {
    return RecogidaHoraInicio;
  }
  static GetRecogidaHoraFin() {
    return RecogidaHoraFin;
  }
  static GetRecogidaIntervalo() {
    return RecogidaIntervalo;
  }
  static SetRecogidaHoraInicio(String valor) {
    RecogidaHoraInicio = valor;
  }
  static SetRecogidaHoraFin(String valor) {
    RecogidaHoraFin = valor;
  }

  static SetRecogidaIntervalo(int valor) {
    RecogidaIntervalo = valor;
    listaHoras=[];
    if (valor!=0){
      DateTime  HoraInicio;
      DateTime  HoraFin;
      if (RecogidaHoraInicio.length==4) RecogidaHoraInicio = '0' + RecogidaHoraInicio;
      if (RecogidaHoraFin.length==4) RecogidaHoraFin = '0' + RecogidaHoraFin;
      HoraInicio = DateTime(2020, 1, 1, int.parse(RecogidaHoraInicio.substring(0, 2)), int.parse(RecogidaHoraInicio.substring(3, 5)), 0);
      HoraFin = DateTime(2020, 1, 1, int.parse(RecogidaHoraFin.substring(0, 2)), int.parse(RecogidaHoraFin.substring(3, 5)), 0);
      listaHoras.add(DateFormat('HH:mm').format(HoraInicio));
      while( HoraInicio.compareTo(HoraFin) <= 0 ){
        HoraInicio = HoraInicio + RecogidaIntervalo.minutes;
        if (HoraInicio.compareTo(HoraFin) <= 0) {
          listaHoras.add(DateFormat('HH:mm').format(HoraInicio));
        }
      }
    }
  }

  static SetPreparacionHoraInicial(String valor) {
    PreparacionHoraInicial = valor;
  }
  static GetPreparacionHoraInicial() {
    if (PreparacionHoraInicial == null) PreparacionHoraInicial = '';
    return PreparacionHoraInicial;
  }

  static GetListaHoras() {
    return listaHoras;
  }

  static Future GetPrecioGastosEnvio() async {
    GastosEnvioCliente = 999.0;
    if (IDCliente != 0 && IDGastosEnvio != 0) {
      var url = Uri.parse(UrlConexionExterna +
          '/Articulos/ClientePrecio/$IDCliente/$IDGastosEnvio');
      try {
        await getTOKENCliente();
        var result = await http.get(url, headers: {
          "Content-Type": "application/json; charset=utf-8",
          'Accept': 'application/json',
          'Authorization': 'Bearer $MANAGEMENT_TOKEN',
        });
        // int statusCode = response.statusCode;
        // String body = response.body;
        if (result.body != '') {
          Map map = json.decode(result.body);
          if (map.length > 0) {
            double dto = map['dto'];
            double precio = map['precio'];
            if (precio != 0) {
              GastosEnvioCliente = precio;
            }
            if (dto != 0) {
              GastosEnvioCliente = GastosEnvio - (GastosEnvio * dto / 100);
            }
          }
        }
      } catch (e) {
        print("ERROR Obteniendo GetPrecioGastosEnvio!!!");
        throw new Exception("ERROR Obteniendo GetPrecioGastosEnvio");
      }
    }
  }

  static SetAPPCodPostalesEnvio(String valor) {
    APPCodPostalesEnvio = valor;
  }
  static GetAPPCodPostalesEnvio() {
    if (APPCodPostalesEnvio == null) APPCodPostalesEnvio = '';
    return APPCodPostalesEnvio;
  }

  static SetPoliticaPrivacidad(String valor) {
    htmlPoliticaPrivacidad = valor;
  }
  static GetPoliticaPrivacidad() {
    if (htmlPoliticaPrivacidad == null) htmlPoliticaPrivacidad = '';
    return htmlPoliticaPrivacidad;
  }

  static GetRutaArticulo() {
    /*if (Sector=='ROPA'){
      return 'assets/articuloRopa.png';
    }else{
      return 'assets/articulo.png';
    }*/
    switch (Sector) {
      case 'ROPA':
        {
          return 'assets/articuloRopa.png';
          //break;
        }
      case 'PELUQUERIA':
        {
          return 'assets/articuloPeluqueria.png';
          //break;
        }
      case 'FRUTERIA':
        {
          return 'assets/articuloFruteria.png';
          //break;
        }
      default:
        {
          return 'assets/articulo.png';
          //break;
        }
    }
  }

  static GetRutaFamilia() {
    /*  if (Sector=='ROPA'){
      return 'assets/familiaRopa.png';
    }else{
      return 'assets/familia.png';
    }*/
    switch (Sector) {
      case 'ROPA':
        {
          return 'assets/familiaRopa.png';
          //break;
        }
      case 'PELUQUERIA':
        {
          return 'assets/familiaPeluqueria.png';
          //break;
        }
      case 'FRUTERIA':
        {
          return 'assets/familiaFruteria.png';
          //break;
        }
      default:
        {
          return 'assets/familia.png';
          //break;
        }
    }
  }

  static SetPermitirVenderSinStock(String valor) {
    PermitirVenderSinStock = valor;
  }

  static GetPermitirVenderSinStock() {
    return PermitirVenderSinStock;
  }

  static SetTextoNoDisponible(String valor) {
    TextoNoDisponible = valor;
  }

  static GetTextoNoDisponible() {
    return TextoNoDisponible;
  }

  static SetPermitirEnvioDomicilio(bool valor) {
    PermitirEnvioDomicilio = valor;
  }

  static GetPermitirEnvioDomicilio() {
    return PermitirEnvioDomicilio;
  }

  static varIDCliente() {
    return IDCliente;
  }

  static varClienteDePrepago() {
    return ClienteDePrepago;
  }

  static varAceptacionPoliticaAPP() {
    return AceptacionPoliticaAPP;
  }

  //-------------------------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------------------------

  static Future getIDCliente(String usuario) async {
    var url = Uri.parse(UrlConexionExterna + '/Clientes/DevolverID/$usuario');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err Obteniedo el IDCliente!!!");
      throw new Exception("Err Obteniedo IDCliente");
    }
  }

  //192.168.10.21:5005/api/Articulos/Alergenos/IDArticulo
/*
  "id": 2016,
  "idArticulo": 104,
  "idAlergeno": 5,
  "alergeno": "Apio y productos derivados",
  "contiene": true,
  "trazas": false,
  "posiblesTrazas": false
   */
  static Future getAlergenos_1_Articulo(int ID) async {
    var url = Uri.parse(UrlConexionExterna + '/Articulos/Alergenos/$ID');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err Obteniedo los Alérgenos!!!");
      throw new Exception("Err  los Alérgenos");
    }
  }

  static Future getInfoLicencia(String Licencia, String usuario) async {
    var url = Uri.parse(UrlConexionDiakrosManager +
        'Licencias/LicenciaAPPCliente/$Licencia/$usuario');
    try {
      await getTOKENDiakrosManager();
      var result = await http.get(url, headers: {
        //'Content-Type': 'application/json',
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("ERROR Obteniendo InfoLicencia!!!");
      throw new Exception("ERROR Obteniendo InfoLicencia");
    }
  }

  static Future<String> ComprobarLicencia(
      String licencia, String usuario, String password) async {
    String result = '';
    IDCliente='0';
    usuario = EncodeURL(usuario);
    try {
      await getInfoLicencia(licencia, usuario).then((response) async {
        //int statusCode = response.statusCode;
        Map map = json.decode(response.body);
        if (map.length > 0) {
          bool Activa = map['Activa'];
          Sector = map['Sector'];
          //--------------------------------------------------
          UrlConexionExterna = (map['IPExterna'] ?? "") + '/api';
          UrlTokemCliente = UrlConexionExterna +
              '/Account/LoginCliente?Username=' +
              'DiaKros' +
              '&Password=' +
              'diaKros_4312'; //(Devuelve TOKEN) POST 0,0 DIAKROS
          //--------------------------------------------------
          String IPInterna = (map['IPInterna'] ?? "");
          if (IPInterna == 'No Existe') {
            result = 'Licencia Incorrecta';
          } else if (Activa == false) {
            result = 'Licencia Inactiva.';
          } else {
            await getIDCliente(usuario).then((response) async {
              IDCliente = response.body.toString();
              if (IDCliente.length > 0) {
                IDCliente = IDCliente.substring(0, IDCliente.length - 1);
                IDCliente = IDCliente.substring(1, IDCliente.length);
                if (IDCliente == '0') {
                  ClienteDePrepago = true;
                } else {
                  ClienteDePrepago = true;
                  AceptacionPoliticaAPP = false;
                  await XgetDatosCliente().then((response) async {
                    Map map = json.decode(response.body);
                    if (map.length > 0) {
                      ClienteDePrepago = map['prepagoAPP']??true;
                      AceptacionPoliticaAPP = map['aceptacionPoliticaAPP']??false;
                    }
                  });
                }
                print(
                    'IDCLIENTE <ComprobarLicencia>: $IDCliente Prepago: $ClienteDePrepago');
                result = 'OK';
              } else {
                //ESTA REGISTRADO PERO NO ESTA DADO DE ALTA COMO CLIENTE EN LA BD.
                IDCliente = '0';
                ClienteDePrepago = true;
                result = 'OK';
                print('IDCLIENTE <ComprobarLicencia>: $IDCliente');
              }
            });
            //SE CONFIGURA PARA QUE SOLO ENTREN LOS CLIENTES DADOS DE ALTA.
            if (IDCliente=='0' && Sector=='xOBLIGARCLIENTE'){
              result = 'El Usuario no tiene permisos';
            }
          }
        } else {
          result = 'Map: ' + map.toString();
        }
      });
    } catch (e) {
      print("ERROR ComprobarLicencia!!!");
      return ('ERROR');
      //throw new Exception("ERROR ComprobarLicencia");
    }
    return (result);
  }

  //-------------------------------------------------------------------------------------------------------------------
  static Future XgetDatosCliente() async {
    var url = Uri.parse(UrlConexionExterna + '/Clientes/$IDCliente');
    try {
      await getTOKENCliente();
      var result =  await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getDatosCliente!!!");
      throw new Exception("Err getDatosCliente");
    }
  }

  static Future getArticulos() async {
    print('IDCLIENTE <getArticulos>: $IDCliente');
    var url = Uri.parse(UrlConexionExterna +
        '/Articulos/DeCliente/${IDCliente}'); ////var url = UrlConexionExterna +'/Articulos';
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err getArticulos!!!");
      throw new Exception("Err getArticulos");
    }
  }

  static Future getFamilias() async {
    var url = Uri.parse(UrlConexionExterna + '/MFamilias/DeCliente/${IDCliente}');
    try {
      await getTOKENCliente();
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return response;
    } catch (e) {
      print("Err getFamilia!!!");
      throw new Exception("Err getFamilia");
    }
  }

  static Future getSubFamilias() async {
    var url = Uri.parse(UrlConexionExterna + '/MSubFamilias/DeCliente/${IDCliente}');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err getSubFamilia!!!");
      throw new Exception("Err getSubFamilia");
    }
  }

  static Future getRemotos() async {
    /*192.168.10.21:5005/Api/Remotos*/
    var url = Uri.parse(UrlConexionExterna + '/Remotos');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err getRemotos!!!");
      throw new Exception("Err getRemotos");
    }
  }

  /*
  PUT:  {{Server_URL}}/Api/Articulos/Imagen
"IDArticulo": 1,
    "Imagenbase64": "”
PUT:  {{Server_URL}}/Api/MSubFamilias/Imagen
"IdsubFamilia": 1,
    "Imagenbase64": "”
   */
  /*POST:  192.168.10.21:5005/Api/INI/ColorAPP

  {
  "ColorApp1": 1,
  "ColorApp2": 2,
  "ColorApp3": 3,
  "ColorBoton": 4,
  "ColorLetraAPP": 5,
  "ColorLetraBoton": 6
  }*/
  static Future SendColoresApp(int cApp1, int cApp2, int cApp3, int cBoton,
      int clApp, int clBoton) async {
     var url = Uri.parse(UrlConexionExterna + '/INI/ColorAPP'); //300x300

    //----------------------------------------------------------------------------------------
    String json =
        '{"ColorApp1": $cApp1, "ColorApp2":$cApp2, "ColorApp3":$cApp3, "ColorBoton":$cBoton, "ColorLetraAPP":$clApp, "ColorLetraBoton":$clBoton }';
    //----------------------------------------------------------------------------------------
    try {
      await getTOKENCliente();
      var response = await http.post(url, body: jsonEncode(json), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      // int statusCode = response.statusCode;
      // String body = response.body;
      var result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
      return result;
      //print('STATUS: $statusCode');
      // print('BODY: $body');
    } catch (e) {
      print("Err EnviarFoto!!!");
      throw new Exception("Err EnviarFoto");
    }
  }

  static Future SendFoto(int idArticulo, String Imagenbase64, int iTipo) async {
    var url;
    if (iTipo == 1) url = Uri.parse(UrlConexionExterna + '/Articulos/Imagen1'); //300x300
    if (iTipo == 2)
      url = Uri.parse(UrlConexionExterna + '/Articulos/Imagen2'); //CALIDAD 900x900
    if (iTipo == 3) url = Uri.parse(UrlConexionExterna + '/Articulos/Imagen3'); //ADICIONAL
    //----------------------------------------------------------------------------------------
    String json =
        '{"IDArticulo": $idArticulo, "Imagenbase64":"${Imagenbase64}"}';
    //----------------------------------------------------------------------------------------
    try {
      await getTOKENCliente();
      var response = await http.put(url, body: jsonEncode(json), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      // int statusCode = response.statusCode;
      // String body = response.body;
      var result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
      return result;
      //print('STATUS: $statusCode');
      // print('BODY: $body');
    } catch (e) {
      print("Err EnviarFoto!!!");
      throw new Exception("Err EnviarFoto");
    }
  }

  static Future xSendAlbaran(List<PedidoCab> listaCab, List<PedidoLin> listaLin,
      _GastosEnvioCargados, _IDRemoto, _ImportePagado, Hora) async {
    var url = Uri.parse(UrlConexionExterna + '/Albaranes/APPClientes');
    String fechaservicio = listaCab[0].fechaservicio;
    String observaciones = listaCab[0].observaciones;
    String dia = fechaservicio.substring(0, 2);
    String mes = fechaservicio.substring(3, 5);
    String anno = fechaservicio.substring(6, 10);
    fechaservicio = mes + '-' + dia + '-' + anno;
    if (Hora!='') fechaservicio = fechaservicio + ' ' + Hora;
    //----------------------------------------------------------------------------------------
    String json =
        '{"Serie": "AP", "FechaEntrega":"${fechaservicio}", "IDCliente": $IDCliente, "Observaciones":"${observaciones}", "ImportePagado": $_ImportePagado, "IDRemoto": $_IDRemoto, "AlbaranesLin":[ ';
    for (int x = 0; x < listaLin.length; x++) {
      String jsonlin = '{'
          '"NumLinea":${listaLin[x].numLin},'
          '"IDArticulo":${listaLin[x].idArticulo},'
          '"Articulo":"${listaLin[x].articulo}",'
          '"Precio":${listaLin[x].precio},'
          '"Cantidad":${listaLin[x].cantidad},'
          '"Observacion":"${listaLin[x].comentario}"' //envia null como texto....quitar la palabra 'null'.
          '}';
      if (x < listaLin.length - 1) {
        json = json + jsonlin + ',';
      } else {
        if (_GastosEnvioCargados > 0) {
          // AÑADO LINEA DE GASTOS ENVIO
          json = json + jsonlin + ',';
          jsonlin = '{'
              '"NumLinea":${listaLin[x].numLin + 1},'
              '"IDArticulo": 0,'    //$IDGastosEnvio
              '"Precio":${_GastosEnvioCargados},'
              '"Cantidad": 1,'
              '"Observacion":"GASTOS ENVIO"'
              '}';
        }
        json = json + jsonlin;
      }
    }
    json = json + ']}';
    //----------------------------------------------------------------------------------------
    try {
      await getTOKENCliente();
      var response = await http.post(url, body: jsonEncode(json), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      // int statusCode = response.statusCode;
      // String body = response.body;
      return response;
      //print('STATUS: $statusCode');
      // print('BODY: $body');
    } catch (e) {
      print("Err EnviarAlbaran!!!");
      throw new Exception("Err EnviarAlbaran");
    }
  }

  static Future StockAlbaran(
      List<PedidoCab> listaCab, List<PedidoLin> listaLin, _IDRemoto) async {
    var url = Uri.parse(UrlConexionExterna + '/Albaranes/ComprobarStock');
    String fechaservicio = listaCab[0].fechaservicio;
    String observaciones = listaCab[0].observaciones;
    String dia = fechaservicio.substring(0, 2);
    String mes = fechaservicio.substring(3, 5);
    String anno = fechaservicio.substring(6, 10);
    fechaservicio = mes + '-' + dia + '-' + anno;
    //----------------------------------------------------------------------------------------
    String json =
        '{"Serie": "AP", "FechaEntrega":"${fechaservicio}", "IDCliente": $IDCliente, "Observaciones":"${observaciones}", "IDRemoto": $_IDRemoto, "AlbaranesLin":[ ';
    for (int x = 0; x < listaLin.length; x++) {
      String jsonlin = '{'
          '"NumLinea":${listaLin[x].numLin},'
          '"IDArticulo":${listaLin[x].idArticulo},'
          '"Articulo":"${listaLin[x].articulo}",'
          '"Precio":${listaLin[x].precio},'
          '"Cantidad":${listaLin[x].cantidad},'
          '"Observacion":"${listaLin[x].comentario}"' //envia null como texto....quitar la palabra 'null'.
          '}';
      if (x < listaLin.length - 1) {
        json = json + jsonlin + ',';
      } else {
        json = json + jsonlin;
      }
    }
    json = json + ']}';
    //----------------------------------------------------------------------------------------
    try {
      await getTOKENCliente();
      var response = await http.post(url, body: jsonEncode(json), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return response;
    } catch (e) {
      print("Err StockAlbaran!!!");
      throw new Exception("Err StockAlbaran");
    }
  }

  static Future PreparacionHoraDisponible(
      List<PedidoCab> listaCab, List<PedidoLin> listaLin, _IDRemoto, Hora) async {
    var url = Uri.parse(UrlConexionExterna + '/Albaranes/PreparacionHoraDisponible');
    String fechaservicio = listaCab[0].fechaservicio;
    String observaciones = listaCab[0].observaciones;
    String dia = fechaservicio.substring(0, 2);
    String mes = fechaservicio.substring(3, 5);
    String anno = fechaservicio.substring(6, 10);
    fechaservicio = mes + '-' + dia + '-' + anno + ' ' + Hora;
    //----------------------------------------------------------------------------------------
    String json =
        '{"Serie": "AP", "FechaEntrega":"${fechaservicio}", "IDCliente": $IDCliente, "Observaciones":"${observaciones}", "IDRemoto": $_IDRemoto, "AlbaranesLin":[ ';
    for (int x = 0; x < listaLin.length; x++) {
      String jsonlin = '{'
          '"NumLinea":${listaLin[x].numLin},'
          '"IDArticulo":${listaLin[x].idArticulo},'
          '"Articulo":"${listaLin[x].articulo}",'
          '"Precio":${listaLin[x].precio},'
          '"Cantidad":${listaLin[x].cantidad},'
          '"Observacion":"${listaLin[x].comentario}"' //envia null como texto....quitar la palabra 'null'.
          '}';
      if (x < listaLin.length - 1) {
        json = json + jsonlin + ',';
      } else {
        json = json + jsonlin;
      }
    }
    json = json + ']}';
    //----------------------------------------------------------------------------------------
    try {
      await getTOKENCliente();
      var response = await http.post(url, body: jsonEncode(json), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return response;
    } catch (e) {
      print("Err PreparacionHoraDisponible!!!");
      throw new Exception("Err PreparacionHoraDisponible");
    }
  }

  static Future getINI() async {
    //http://192.168.10.21:5005/api/INI
    var url = Uri.parse(UrlConexionExterna + '/INI');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err getINI!!!");
      throw new Exception("Err getINI");
    }
  }

  static Future getDatos(String Tabla, String CampoADevolver,
      String CampoPorElQueBuscar, String DatoABuscar) async {
    /*  •	GET con TOKEN para leer un dato de cualquier tabla: 192.168.10.21:5005/Api/ObtenerDato/Clientes/NombreLF/IDCliente/2
        Se le envía 4 parámeteros: Tabla/CampoADevolver/CampoPorElQueBuscar/DatoABuscar y devuelve un string con el resultado.
        En este ejemplo devuelvo el NombreLF de clientes, cuyo IDCliente=2
     */
    var result = '';
    var url = Uri.parse(UrlConexionExterna +
        '/ObtenerDato/$Tabla/$CampoADevolver/$CampoPorElQueBuscar/$DatoABuscar');
    try {
      await getTOKENCliente();
      var response = await http.get(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      print("ERROR Obteniendo Dato del Servidor ERP!!!");
      return 'Err';
      //throw new Exception("ERROR Obteniendo InfoLicencia");
    }
    return result;
  }

  //-------------------------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------------------------
  static Future<String> AltaDeUsuario_Registro(
      String usuario, String password) async {
    /*  https://diakrosmanager.com/diLicenciasWeb/api/Registro?Username=rubio@diakros.com&Password=4312
     Responde con un string:
      OK (envía un correo al email del usuario esperando la confirmación y otro a nosotros (registro@diakros.com) para que lo sepamos)
    ESPERANDO ACTIVACION (Aún no le ha dado al link del email de confirmación)
    USUARIO YA REGISTRADO PREVIAMENTE (ya está registrado y verificado)
    ESPERANDO ACTIVACION CON OTRO PASSWORD (este email está registrado con otro password y aún no le ha dado al link del email de confirmación)
    USUARIO YA REGISTRADO PREVIAMENTE CON OTRO PASSWORD (ya está registrado y verificado con otro password)*/
    var result = '';
    usuario = EncodeURL(usuario);
    var url = Uri.parse(UrlConexionDiakrosManager +
        'Registro?UserName=$usuario&Password=$password');
    try {
      await getTOKENDiakrosManager();
      var response = await http.post(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      result = 'Err';
      print("ERROR Obteniendo AltaDeUsuario_Registro!!!");
      throw new Exception("ERROR Obteniendo InfoLicencia");
    }
    return result;
  }

  static Future<String> EnviarPassword(String usuario) async {
    /*Por si un usuario se olvida la contraseña, se puede añadir una opción desde la APP para recibir un email con los datos de acceso.
    o	GET (con TOKEN) https://diakrosmanager.com/diLicenciasWeb/api/Registro?EnviarPassword?Username=rubio@diakros.com
    o	Responde con un string:
    Correcto (se envía un email al usuario con los datos de acceso)*/
    var result = '';
    usuario = EncodeURL(usuario);
    var url =
    Uri.parse(UrlConexionDiakrosManager + 'Registro/EnviarPassword?UserName=$usuario');
    try {
      await getTOKENDiakrosManager();
      var response = await http.get(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      result = 'Err';
      print("ERROR Obteniendo AltaDeUsuario_Registro!!!");
      throw new Exception("ERROR Obteniendo InfoLicencia");
    }
    return result;
  }

  static Future<String> ReenviarMail_Registro(String usuario) async {
    /*GET con TOKEN para enviarle de nuevo el correo de confirmación al usuario:
    https://diakrosmanager.com/diLicenciasWeb/api/Registro/ReenviarConfirmacion?Username=rubio@diakros.com*/
    var result = '';
    usuario = EncodeURL(usuario);
    var url = Uri.parse(UrlConexionDiakrosManager +
        'Registro/ReenviarConfirmacion?UserName=$usuario');
    try {
      await getTOKENDiakrosManager();
      var response = await http.get(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      result = 'Err';
      print("ERROR Obteniendo AltaDeUsuario_Registro!!!");
      throw new Exception("ERROR Obteniendo InfoLicencia");
    }
    return result;
  }

  static Future<String> Acceso_APP(String usuario, String password) async {
    /*Para acceder a la APP:
    	POST (con TOKEN) https://diakrosmanager.com/diLicenciasWeb/api/Account/LoginUsuario?Username=rubio@diakros.com&Password=4312
    	Responde con un string:
    OK
    CANCEL*/
    var result = '';
    usuario = EncodeURL(usuario);
    var url = Uri.parse(UrlConexionDiakrosManager +
        'Account/LoginUsuario?UserName=$usuario&Password=$password');
    try {
      await getTOKENDiakrosManager();
      var response = await http.post(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      result = 'Err';
      print("ERROR Acceso_APP!!!");
      throw new Exception("ERROR Obteniendo InfoLicencia");
    }
    return result;
  }

  //-------------------------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------------------------
  static Future getTOKENCliente() async {
    var response = await http.post(Uri.parse(UrlTokemCliente));
    MANAGEMENT_TOKEN = response.body.toString();
    // print(MANAGEMENT_TOKEN);
    return MANAGEMENT_TOKEN;
  }

  static Future getTOKENDiakrosManager() async {
    var response = await http.post(Uri.parse(UrlTokemDiakrosManager));
    MANAGEMENT_TOKEN = response.body.toString();
    MANAGEMENT_TOKEN =
        MANAGEMENT_TOKEN.substring(0, MANAGEMENT_TOKEN.length - 1);
    MANAGEMENT_TOKEN = MANAGEMENT_TOKEN.substring(1, MANAGEMENT_TOKEN.length);
    return MANAGEMENT_TOKEN;
  }

  //-------------------------------------------------------------------------------------------------------------------
  static Future getImagenEmpleado(int IDEmpleado) async {
    var url = Uri.parse(UrlConexionExterna + '/Empleados/Imagen/$IDEmpleado');
    try {
      await getTOKENCliente();
      return await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
    } catch (e) {
      print("Err getImagenEmpleado!!!");
      throw new Exception("Err getImagenEmpleado");
    }
  }

  static Future getImagenArticulo(int IDArticulo) async {
    var url = Uri.parse(UrlConexionExterna + '/ArticulosImagenes/$IDArticulo');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      print('DESCARGADA IMAGEN IDARTICULO: ${IDArticulo}');
      return result;
    } catch (e) {
      print("Err getImagenArticulo!!!");
      throw new Exception("Err getImagenArticulo");
    }
  }

  static Future getImagenesArticulos() async {
    //http://192.168.10.130:5005/api/ArticulosImagenes/DeCliente/2
    var url = Uri.parse(UrlConexionExterna + '/ArticulosImagenes/DeCliente/${IDCliente}');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getImagenesArticulo!!!");
      throw new Exception("Err getImagenesArticulo");
    }
  }

  static Future getImagenesFamilias() async {
    //192.168.10.21:5005/Api/MFamilias/Imagenes/IDCliente (0 para todas)
    var url = Uri.parse(UrlConexionExterna + '/MFamilias/Imagenes/${IDCliente}');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getImagenesFamilias!!!");
      throw new Exception("Err getImagenesFamilias");
    }
  }

  static Future getImagenesSubFamilias() async {
    //192.168.10.21:5005/Api/MFamilias/Imagenes/IDCliente (0 para todas)
    var url = Uri.parse(UrlConexionExterna + '/MSubFamilias/Imagenes/${IDCliente}');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getSubImagenesFamilias!!!");
      throw new Exception("Err getSubImagenesFamilias");
    }
  }

//  •	Api para las imágenes adicionales:
//  o	192.168.10.21:5005/api/ArticulosImagenes/Adicionales/IDArticulo
  static Future getImagenes_1_Articulo(int IDArticulo) async {
    var url =
    Uri.parse(UrlConexionExterna + '/ArticulosImagenes/Adicionales/${IDArticulo}');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getImagenes_1_Articulo!!!");
      throw new Exception("Err getImagenes_1_Articulo");
    }
  }

  static Future getImagenes_1_Subfamilia(int ID) async {
    // http://192.168.10.21/api/MSubFamilias/ImagenesAdicionales/{idSubFamilia}
    var url = Uri.parse(UrlConexionExterna + '/MSubFamilias/ImagenesAdicionales/${ID}');
    try {
      await getTOKENCliente();
      var result = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return result;
    } catch (e) {
      print("Err getImagenes_1_Subfamilia!!!");
      throw new Exception("Err getImagenes_1_Articulo");
    }
  }

  //-------------------------------------------------------------------------------------------------------------------
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static String Asignar(var cadena, var Defecto) {
    if (cadena == null || cadena == '') {
      cadena = Defecto;
    }

    if ((Defecto == "0") && !isNumeric(cadena)) cadena = Defecto;
    return cadena;
  }

  static EncodeURL(String input) {
    input = Uri.encodeComponent(input);
    input = input.replaceAll('_', '%5F');
    input = input.replaceAll('.', 'dkpunto');
    //input = input.replaceAll('.', '%2E');
    input = input.replaceAll('!', '%21');
    input = input.replaceAll('~', '%7E');
    input = input.replaceAll('*', '%2A');
    input = input.replaceAll('\'', '%5C');
    input = input.replaceAll('(', '%28');
    input = input.replaceAll(')', '%29');
    return input;
  }

  static AvisoToast(BuildContext context, String mensaje) async {
    await Dialogs.Dialogo(context, 'AVISO', mensaje, 'OK', '');
    /*Toast.show(
      '$mensaje',
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      backgroundColor: Colors.blue[700],
    );*/
  }

  static DiferenciaDias(var picked) {
    //Fecha Actual------------------------------
    String FechaActual = DateFormat('dd-MM-yyyy').format(DateTime.now());
    int dia1 = int.parse(FechaActual.substring(0, 2));
    int mes1 = int.parse(FechaActual.substring(3, 5));
    int anno1 = int.parse(FechaActual.substring(6, 10));
    final Fecha = DateTime(anno1, mes1, dia1);
    return picked.difference(Fecha).inDays;
  }

  static HoraPermitida_sin_uso(var fecha) {
    var result = 'OK';
    if (fecha != null) {
      if (DiferenciaDias(fecha) > 1) {
        result = 'OK';
      } else if (DiferenciaDias(fecha) < 0) {
        //FECHA PASADA
        result = 'LO SENTIMOS, ESTA FECHA HA PASADO'; //SOBREPASADA LA HORA PERMITIDA.
      } else if (DiferenciaDias(fecha) == 0) {
        //PARA HOY
        var item = lista_ini_WebS.firstWhere(
            (obj) => obj.clave == "APPHoraMaxPedidos",
            orElse: () => null);
        if (item == null) //NO ESTA CREADA LA ENTRADA...
          result = 'OK';
        else if (item.valor == null)
          result = 'OK';
        else if (item.valor == '')
          result = 'OK';
        else {
          //COMPROBAR LA HORA QUE SEA MAYOR QUE LA ACTUAL
          String HoraActual = DateFormat('HH').format(DateTime.now());
          String MinActual = DateFormat('mm').format(DateTime.now());
          //---------------------------------------------------------------------
          DateTime HoraMax = DateFormat('HH:mm').parse(item.valor);
          DateTime Hora = DateFormat('HH:mm').parse('${HoraActual}:${MinActual}');
          if (HoraMax.difference(Hora).inMinutes >= 0)
            result = 'OK';
          else
            result = (item.valor=='00:00')?
            'LO SENTIMOS, NO SE PERMITEN PEDIDOS PARA EL MISMO DIA': //NO SE PERMITEN PARA MISMO DIA SI ES 00:00
            'LO SENTIMOS, PARA ESTA FECHA, LA HORA MAXIMA PARA REALIZAR PEDIDOS ES HASTA LAS ${item.valor}'; //SOBREPASADA LA HORA PERMITIDA.
          //---------------------------------------------------------------------
        }
      } else if (DiferenciaDias(fecha) == 1) {
        //PARA MAÑANA
        var item = lista_ini_WebS.firstWhere(
            (obj) => obj.clave == "APPHoraMaxPedidosRestoDias",
            orElse: () => null);
        if (item == null) //NO ESTA CREADA LA ENTRADA...
          result = 'OK';
        else if (item.valor == null)
          result = 'OK';
        else if (item.valor == '')
          result = 'OK';
        else {
          //COMPROBAR LA HORA QUE SEA MAYOR QUE LA ACTUAL
          String HoraActual = DateFormat('HH').format(DateTime.now());
          String MinActual = DateFormat('mm').format(DateTime.now());
          //---------------------------------------------------------------------
          DateTime HoraMax = DateFormat('HH:mm').parse(item.valor);
          DateTime Hora = DateFormat('HH:mm').parse('${HoraActual}:${MinActual}');
          if (HoraMax.difference(Hora).inMinutes >= 0)
            result = 'OK';
          else
            result =
                'LO SENTIMOS, PARA ESTA FECHA, LA HORA MAXIMA PARA REALIZAR PEDIDOS ES HASTA LAS ${item.valor}'; //SOBREPASADA LA HORA PERMITIDA.
          //---------------------------------------------------------------------
        }
      }
    }
    return result;
  }

  //  192.168.10.21:5005/api/Albaranes/FechaPedidoCorrecta/IDRemoto/FechaPedido
//  Cuando es envío a domicilio me pasad IDRemoto=0 y cuando es recogida en tienda, el IDRemoto de la tienda de recogida. Devuelve 0 para indicar no permitido, 1 permitido.

  static Future getDisponibilidadFechaServicio_sin_uso(int IDRemoto, String fecha) async {
    var url =
    Uri.parse(UrlConexionExterna + '/Albaranes/FechaPedidoCorrecta/$IDRemoto/$fecha');
    try {
      await getTOKENCliente();
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      return response;
    } catch (e) {
      print("Err Obteniedo getDisponibilidadFechaServicio!!!");
      throw new Exception("Err Obteniedo getDisponibilidadFechaServicio");
    }
  }

/*
  •	/Albaranes/FechaHoraPedidoCorrecta/IDRemoto/Fecha
  •	Devuelve un string:
  o	“0”: No permitido
  o	“-1”: Día anterior:
  o	“12:00” Si devuelve una hora, es la hora máxima permitida.
*/

  static Future getDisponibilidadHoraFechaServicio(int IDRemoto, String fecha) async {
    String result= '';
    var url = Uri.parse(UrlConexionExterna + '/Albaranes/FechaHoraPedidoCorrecta/$IDRemoto/$fecha');
    try {
      await getTOKENCliente();
      var response = await http.get(url, headers: {
        "Content-Type": "application/json; charset=utf-8",
        'Accept': 'application/json',
        'Authorization': 'Bearer $MANAGEMENT_TOKEN',
      });
      result = response.body.toString();
      if (result != '') {
        result = result.substring(0, result.length - 1);
        result = result.substring(1, result.length);
      } else {
        result = 'Err';
      }
    } catch (e) {
      result = 'Err';
      print("Err Obteniedo getDisponibilidadHoraFechaServicio!!!");
      throw new Exception("Err Obteniedo getDisponibilidadHoraFechaServicio");
    }
    return result;
  }
}
