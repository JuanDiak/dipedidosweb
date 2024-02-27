import 'PoliticaPrivacidad.dart';
import 'TiendasRecogida.dart';
import 'package:flutter/cupertino.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'Stripe/payment-service.dart';
import 'Api.dart';
import 'PedidoActual.dart';
import 'Principal.dart';
import 'DireccionEnvio.dart';
import 'Utils/Config.dart';
import 'Utils/Dialogo.dart';
import 'Utils/Dialogs.dart';
import 'rutas/SlideFromRightPageRoute.dart';
import 'Variables.dart';

bool isLoading = false;
var itemImagen;
bool _clienteDePrepago = true;
final ctrl_Observaciones = TextEditingController();
final focus_Observaciones = FocusNode();
double _gastosEnvio = 0;
double _gastosEnvioGratis = 0;
double _TotalAPagar = 0;
double _ImportePagado = 0;
double _ImporteAdelantoPago = 0;
double _importeMinimoParaEnvio = 0;
double _GastosEnvioCargados = 0;
String _MensajeGastosEnvio;
bool realizandoPedido = false;
bool comprobandoFecha = false;
bool check_ValuePrivacidad = false;
bool check_ValueImporteMinimoPagar = false;
String HoraValue = '';

class Realizarpedido extends StatefulWidget {
  double total;
  Realizarpedido({
    this.total,
  });
  @override
  _RealizarpedidoState createState() => _RealizarpedidoState();
}

class _RealizarpedidoState extends State<Realizarpedido> {
  bool PermitirEnvioADomicilio = API.GetPermitirEnvioDomicilio();
  String _Envio;
  List<String> _OptionEnvio;

  int _idRemoto = 0;
  String _provincia = "",
      _localidad = "",
      _domicilio = "",
      _codpostal = "",
      _telefono = "",
      _nombreTiendaRecogida = "",
      _textoTiendaRecogida = '';

  initState() {
    super.initState();
    realizandoPedido = false;
    comprobandoFecha = false;
    if (PermitirEnvioADomicilio) {
      _LeerPreferencias();
      _OptionEnvio = ['RECOGIDA EN TIENDA', 'ENVIO A DOMICILIO'];
      _Envio = 'ENVIO A DOMICILIO';
      _gastosEnvio = API.GetGastosEnvio();
    } else {
      _Envio = 'RECOGIDA EN TIENDA';
      cargarTiendasRecogida();
      _gastosEnvio = 0;
    }
    _importeMinimoParaEnvio = API.GetImporteMinimoParaEnvio();
    _clienteDePrepago = API.varClienteDePrepago();
    _TotalAPagar = widget.total;
    if (_gastosEnvio > 0) {
      _TotalAPagar = widget.total + _gastosEnvio;
      _gastosEnvioGratis = API.GetGastosEnvioGratis();
      if (_gastosEnvioGratis > 0) {
        if (widget.total >= _gastosEnvioGratis) {
          _gastosEnvio = 0;
          _TotalAPagar = widget.total;
        }
      }
    }
    _GastosEnvioCargados = _gastosEnvio;
    _TotalAPagar = num.parse(_TotalAPagar.toStringAsFixed(2));
  }

  cargarTiendasRecogida() {
    if (lista_Remotos_WebS.length > 0) {
      _nombreTiendaRecogida = lista_Remotos_WebS[0].nombreTienda ?? '';
      _domicilio = lista_Remotos_WebS[0].domicilio ?? '';
      _codpostal = lista_Remotos_WebS[0].codPostal ?? '';
      _localidad = lista_Remotos_WebS[0].poblacion ?? '';
      _provincia = lista_Remotos_WebS[0].provincia ?? '';
      _textoTiendaRecogida = lista_Remotos_WebS[0].textoTiendaWeb ?? '';
      _telefono = lista_Remotos_WebS[0].telefono ?? '';
      _idRemoto = lista_Remotos_WebS[0].idRemoto;
    } else {
      _nombreTiendaRecogida = '';
      _domicilio = '';
      _codpostal = '';
      _localidad = '';
      _provincia = '';
      _textoTiendaRecogida = '';
      _telefono = '';
      _idRemoto = 0;
    }
    setState(() {});
  }

/*  payViaNewCard(context, importe) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Por favor espere...');
    await dialog.show();
    var response =
        await StripeService.createPaymentIntent(amount: importe, currency: 'EUR');
    await dialog.hide();
    if (response.success == true) {
      //ENVIAR PEDIDO.....
      _EnviarPedidoAlERP();
    } else {
      //await DialogHelper.exit(context, 'OPERACION CANCELADA', 'Pulse Aceptar para continuar','Aceptar');
    }
  }*/

  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _telefono = (prefs.getString('telefono') ?? "");
    _domicilio = (prefs.getString('domicilioEnvio') ?? "");
    if (_domicilio == "") {
      _domicilio = (prefs.getString('domicilio') ?? "");
      _localidad = (prefs.getString('localidad') ?? "");
      _codpostal = (prefs.getString('codpostal') ?? "");
      _provincia = (prefs.getString('provincia') ?? "");
    } else {
      _localidad = (prefs.getString('localidadEnvio') ?? "");
      _provincia = (prefs.getString('provinciaEnvio') ?? "");
      _codpostal = (prefs.getString('codpostalEnvio') ?? "");
    }
    setState(() {});
  }

  Widget _CambiarDatosEnvio() {
    return InkWell(
      onTap: () async {
        var result;
        result = await Navigator.push(
            context, SlideFromRightPageRoute(widget: DireccionEnvio()));
        if (result != null) {
          await _LeerPreferencias();
          setState(() {});
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CAMBIAR DIRECCION DE ENVIO >',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkEnvio(String value) async {
    _Envio = value;
    _idRemoto = 0;
    if (_Envio == 'RECOGIDA EN TIENDA') {
      //SI SOLO TIENE UNA TIENDA Q NO VAYA A ELEGIR------
      final result = await Navigator.of(context)
          .push(CupertinoPageRoute(builder: (BuildContext context) {
        return WidgetTiendasRecogida();
      }));
      if (result != null) {
        _nombreTiendaRecogida = result.nombreTienda ?? '';
        _domicilio = result.domicilio ?? '';
        _codpostal = result.codPostal ?? '';
        _localidad = result.poblacion ?? '';
        _provincia = result.provincia ?? '';
        _textoTiendaRecogida = result.textoTiendaWeb ?? '';
        _telefono = result.telefono ?? '';
        _idRemoto = result.idRemoto;
        //------------------------------------
        _TotalAPagar = widget.total;
        _GastosEnvioCargados = 0;
      } else {
        _checkEnvio('ENVIO A DOMICILIO');
      }
    } else {
      _LeerPreferencias();
      _TotalAPagar = widget.total + _gastosEnvio;
      _GastosEnvioCargados = _gastosEnvio;
    }
    setState(() {});
  }

  Widget _TextoGastosEnvio() {
    String _textoGastosGratis = '', _textoGastos = 'GASTOS DE ENVIO GRATIS';
    String texto = '';
    if (_gastosEnvioGratis != 0) {
      _textoGastosGratis =
          NumberFormat.simpleCurrency().format(_gastosEnvioGratis);
      _textoGastosGratis =
          'ENVIO GRATIS POR IMPORTES SUPERIORES A $_textoGastosGratis.\n';
    }
    if (_gastosEnvio != 0) {
      _textoGastos = NumberFormat.simpleCurrency().format(_gastosEnvio);
      _textoGastos =
          'PEDIDO ${NumberFormat.simpleCurrency().format(widget.total)}  +  GASTOS DE ENVIO $_textoGastos';
    }
    _MensajeGastosEnvio = _textoGastosGratis + _textoGastos;

    if (_Envio == 'RECOGIDA EN TIENDA') {
      texto = _textoTiendaRecogida;
    } else {
      texto = _MensajeGastosEnvio;
    }

    return (texto != '')
        ? Card(
            elevation: 10.0,
            margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          texto,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            height: 10.0,
          );
  }

  ComprobacionesDatosEnvio_Fecha_Stock() async {
    //MIRAR LA FECHA Y POSIBLIDAD DE ENVIO O RECOGIDA
    //MIRAR SI ES ENVIO, SI CUMPLE EL IMPORTE MINIMO PARA ENVIO
    var result = 'OK';
    int _TipoEnvio = 0;
    String dia, mes, anno;
    if (listaPedidoCab()[0].fechaservicio != null) {
      dia = listaPedidoCab()[0].fechaservicio.substring(0, 2);
      mes = listaPedidoCab()[0].fechaservicio.substring(3, 5);
      anno = listaPedidoCab()[0].fechaservicio.substring(6, 10);
    } else {
      await Dialogs.Dialogo(
          context, 'AVISO', 'Por favor, revisa tu fecha de servicio', 'OK', '');
      result = 'FECHA NO CORRECTA';
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR EL IMPORTE MINIMO Y DATOS SI ES ENVIO A DOMICILIO.
    if (result == 'OK') {
      if (_Envio == 'ENVIO A DOMICILIO') {
        _TipoEnvio = 1;
        if (_provincia == "" ||
            _localidad == "" ||
            _domicilio == "" ||
            _codpostal == "") {
          await Dialogs.Dialogo(context, 'AVISO',
              'Por favor, revisa tus datos de envío a domicilio', 'OK', '');
          result = 'NULL';
        } else {
          if ((_TotalAPagar - _GastosEnvioCargados) < _importeMinimoParaEnvio) {
            await Dialogs.Dialogo(
                context,
                'AVISO',
                'Lo sentimos, el importe mínimo para el envío es de ${NumberFormat.simpleCurrency().format(_importeMinimoParaEnvio)}',
                'OK',
                '');
            result = 'NULL';
          }
        }
      } else {
        _TipoEnvio = 2; //RECOGIDA EN TIENDA;
      }
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR EL STOCK SI HAY DISPONIBILIDAD DE LOS ARTICULOS
    if (result == 'OK') {
      if (API.GetPermitirVenderSinStock() == 'No') {
        result = await ComprobarStockAlbaran(_idRemoto);
        if (result != 'OK') {
          await Dialogs.Dialogo(context, 'AVISO', result, 'OK', '');
          result = 'NULL';
        }
      }
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR EL HORARIO DE DISPONIBILIDAD PARA LAS BRASAS PE. LAS PAELLAS
    if (result == 'OK') {
      if (API.GetPreparacionHoraInicial() != '') {
        result = await ComprobarPreparacionHoraDisponible(_idRemoto, HoraValue);
        if (result != 'OK') {
          await Dialogs.Dialogo(context, 'AVISO', 'NO HAY DISPONIBILIDAD PARA ESTA HORA', 'OK', '');
          result = 'NULL';
        }
      }
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR PARA EL ENVIO A DOMICILIO LOS CODIGOS POSTALES
    if (result == 'OK' && _TipoEnvio == 1) {
      String codPostalesPermitidos = API.GetAPPCodPostalesEnvio();
      if (!codPostalesPermitidos.contains(_codpostal) &&
          codPostalesPermitidos.length > 4) {
        await Dialogs.Dialogo(
            context,
            'AVISO',
            'Lo sentimos, para este código postal, no está disponible el reparto a domicilio',
            'OK',
            '');
        result = '¡SIN REPARTO A ESTE CODIGO POSTAL!';
      }
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR DISPONIBILIDAD PARA ESA FECHA SI HAY RECOGIDA EN TIENDA O ENVIO A DOMICILIO
    if (result == 'OK') {
      String _fecha = dia + '-' + mes + '-' + anno;
      String msg = 'la recogida en tienda';
      if (_TipoEnvio == 1) msg = 'el envío a domicilio';
      //----------------------------------------------------------------
      await API
          .getDisponibilidadHoraFechaServicio(_idRemoto, _fecha)
          .then((response) async {
        if (response == '1') {
          result = 'OK';
        } else {
          if (response == '0' || response == '-1') {
            await Dialogs.Dialogo(
                context,
                'AVISO',
                'Lo sentimos, para esta fecha no está disponible $msg',
                'OK',
                '');
          } else {
            if (response == '00:00') {
              msg =
                  'LO SENTIMOS, NO SE PERMITEN PEDIDOS PARA EL MISMO DIA'; //NO SE PERMITEN PARA ESE MISMO DIA.
            } else {
              msg =
                  'LO SENTIMOS, PARA ESTA FECHA, LA HORA MAXIMA PARA REALIZAR PEDIDOS ES HASTA LAS $response'; //SOBREPASADA LA HORA PERMITIDA.
            }
            await Dialogs.Dialogo(context, 'AVISO', '$msg', 'OK', '');
          }
          result = 'NULL';
        }
      });
    }
    //--------------------------------------------------------------------------------
    //COMPROBAR POLITICA DE PRIVACIDAD
    if (result == 'OK') {
      if (API.GetPoliticaPrivacidad() != '' &&
          API.varAceptacionPoliticaAPP() == false) {
        //DEBE ACEPTAR LA PRIVACIDAD
        if (check_ValuePrivacidad == false) {
          await Dialogs.Dialogo(context, 'AVISO',
              'Debes aceptar la Política de Privacidad. ', 'OK', '');
          result = '¡NO HA APROBADO LA POLITICA DE PRIVACIDAD!';
        }
      }
    }
    //--------------------------------------------------------------------------------
    return result;
  }

  _EnviarPedidoAlERP() async {
    focus_Observaciones.unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String n = String.fromCharCode(13) + String.fromCharCode(10);
    String Observaciones = '';
    Observaciones = 'NOMBRE: ' + (prefs.getString('nombre') ?? "") + '$n';
    Observaciones += 'USUARIO: ' + (prefs.getString('usuario') ?? "") + '$n';
    Observaciones +=
        'DOMICILIO: ' + (prefs.getString('domicilio') ?? "") + '$n';
    Observaciones +=
        'LOCALIDAD: ' + (prefs.getString('localidad') ?? "") + '$n';
    Observaciones +=
        'COD POSTAL: ' + (prefs.getString('codpostal') ?? "") + '$n';
    Observaciones +=
        'PROVINCIA: ' + (prefs.getString('provincia') ?? "") + '$n';
    Observaciones += 'TELEFONO: ' + (prefs.getString('telefono') ?? "") + '$n';
    if (_Envio == 'ENVIO A DOMICILIO') {
      Observaciones += 'ENVIO DOMICILIO: $_domicilio $n';
      Observaciones += 'ENVIO LOCALIDAD: $_localidad  $n';
      Observaciones += 'ENVIO COD POSTAL: $_codpostal $n';
      Observaciones += 'ENVIO PROVINCIA: $_provincia $n';
    } else {
      Observaciones += 'RECOGIDA TIENDA: $_nombreTiendaRecogida $n';
    }
    if (_clienteDePrepago == true) {
      Observaciones += 'FORMA DE PAGO: ' + 'PAGADO' + '$n';
    } else {
      Observaciones += 'FORMA DE PAGO: ' + 'CLIENTE' + '$n';
      _ImportePagado = 0.0;
    }
    if (ctrl_Observaciones.text != '' && ctrl_Observaciones.text != null) {
      String cadena;
      cadena = ctrl_Observaciones.text;
      Observaciones +=
          'OBSERVACIONES: ' + cadena.replaceAll('\n', '\r\n') + '$n';
    }
    lista_pedidoCab[0].observaciones = Observaciones;
    await pEnviarPedido(
        context, _GastosEnvioCargados, _idRemoto, _ImportePagado, HoraValue);
    //---------------------------------------------------------------------------------------------------------------------
    String texto = 'OPERACION REALIZADA CORRECTAMENTE';
    if (_ImportePagado != 0)
      texto =
          'OPERACION REALIZADA CORRECTAMENTE \n PAGADO ${NumberFormat.simpleCurrency().format(_ImportePagado)} *';
    await DialogHelper.exit(
        context, texto, 'Pulse Aceptar para continuar', 'Aceptar');
    Navigator.pop(context, 'OK');
  }

  Widget _buildDatosEnvio(String Texto, var Dato, String Texto2, var Dato2) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Texto,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.0,
                    color: Colors.grey),
              ),
              Text(
                Texto2 ?? '',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.0,
                    color: Colors.grey),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Dato,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Text(
                  Dato2 ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _WidgetTotal() {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0)),
            color: colorBoton), //Color(0xFF7A9BEE)),
        height: 50.0,
        child: Center(
          child: Text('${NumberFormat.simpleCurrency().format(_TotalAPagar)}',
              style: TextStyle(
                color: colorletraBoton, //Colors.white,
                fontFamily: 'Montserrat',
                fontSize: 32,
              )),
        ),
      ),
    );
  }

  Widget _DatosEnvio() {
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            (_Envio == 'RECOGIDA EN TIENDA')
                ? _buildDatosEnvio('TIENDA', _nombreTiendaRecogida, '', '')
                : SizedBox.shrink(),
            _buildDatosEnvio('Domicilio', _domicilio, '', ''),
            Stack(
              children: [
                _buildDatosEnvio(
                    'Localidad', _localidad, 'Cod. Postal', _codpostal),
                (comprobandoFecha || realizandoPedido)
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink(),
              ],
            ),
            _buildDatosEnvio('Provincia', _provincia, 'Teléfono', _telefono),
          ],
        ),
      ),
    );
  }

  Future SelectDate(context) async {
    var result;
    DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale('es', 'ES'),
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2020),
        lastDate: new DateTime(2050));
    if (picked == null)
      return 'err';
    else {
      String _fechaAnterior = lista_pedidoCab[0].fechaservicio;
      lista_pedidoCab[0].fechaservicio =
          DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        comprobandoFecha = true;
      });
      var result = await ComprobacionesDatosEnvio_Fecha_Stock();
      if (result == 'OK') {
        GrabarCabeceraPedido();
      } else {
        if (result == 'FECHA NO CORRECTA')
          lista_pedidoCab[0].fechaservicio = _fechaAnterior;
      }
      setState(() {
        comprobandoFecha = false;
      });
    }
    return result;
  }

  bool HoraPertenece() {
    for (int x = 0; x < listaHoras.length; x++) {
      if (HoraValue == listaHoras[x]) {
        return true;
      }
    }
    return false;
  }

  Widget _FechaServicio() {
    if (listaHoras.length > 0) {
      if (HoraValue == '' || HoraPertenece() == false ) HoraValue = listaHoras[0];
    } else {
      HoraValue = '';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () async {
                await SelectDate(context);
                setState(() {});
              },
              child: FittedBox(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 3))
                          ]),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                        child: Text(
                            (lista_pedidoCab[0].fechaservicio == null)
                                ? 'FECHA DE SERVICIO...'
                                : lista_pedidoCab[0].fechaservicio,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                              color: Color(0xFF0F538F),
                              //fontWeight: FontWeight.w600,
                            )),
                      ),
                    )),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            (HoraValue!='')
                ? DropdownButton<String>(
                    value: HoraValue,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueGrey,
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18.0,
                        color:
                            Color(0xFF0F538F)), //fontWeight: FontWeight.w600,),
                    underline: Container(
                      height: 2,
                      color: Color(0xFF0F538F),
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        HoraValue = newValue;
                      });
                    },
                    items: listaHoras.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  Widget _OpcionesRecogidaButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.0,
/*            child: MaterialSwitch(
              //padding: EdgeInsets.only(bottom: 15, left: 10),
              padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
              options: _OptionEnvio,
              selectedOption: _Envio,
              selectedBackgroundColor: colorApp3, //Colors.blue[700],
              selectedTextColor: colorletraApp, //Colors.white,
              //style: TextStyle(fontSize: 18.0,),
              onSelect: (String value) {
                _checkEnvio(value);
              },
            ),*/
          ),
        ],
      ),
    );
  }

  Widget _BotonElegirTienda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
      child: MaterialButton(
        child: Text('Elegir Tienda Recogida'),
        color: colorBoton,
        textColor: colorletraBoton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        onPressed: () {
          _checkEnvio('RECOGIDA EN TIENDA');
        },
        //icon: Icon(mostrarAlergenos ? Icons.menu : Icons.local_hospital),
      ),
    );
  }

  Widget _OpcionPrivacidad() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: check_ValuePrivacidad,
          onChanged: (bool newValue) => setState(() {
            check_ValuePrivacidad = newValue;
          }),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
                text: 'He leído y acepto la ',
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Política de Privacidad*',
                    style: TextStyle(color: Colors.lightGreen),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            SlideFromRightPageRoute(
                                widget: PoliticaPrivacidad()));
                      },
                  )
                ]),
          ),
        ),
        //const Padding(padding: EdgeInsets.fromLTRB(8,0,8,0)),
        //FutureBuilder<void>(future: _launched, builder: _launchStatus),
      ],
    );
  }

//
  Widget _OpcionImporteMinimoPagar() {
    _ImporteAdelantoPago = _TotalAPagar * API.GetPctImporteMinimoPagar() / 100;

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Checkbox(
        value: check_ValueImporteMinimoPagar,
        onChanged: (bool newValue) => setState(() {
          check_ValueImporteMinimoPagar = newValue;
        }),
      ),
      Expanded(
        child: RichText(
          text: TextSpan(
              text:
                  'Deseo pagar la cantidad mínima del ${API.GetPctImporteMinimoPagar()}% del importe total. ',
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text:
                      '${NumberFormat.simpleCurrency().format(_ImporteAdelantoPago)} *',
                  style: TextStyle(color: Colors.lightGreen),
                )
              ]),
        ),
      ),
    ]);
  }

  Widget _Observaciones() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: TextField(
          controller: ctrl_Observaciones,
          textCapitalization: TextCapitalization.sentences,
          focusNode: focus_Observaciones,
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          maxLines: 2,
          decoration: InputDecoration(
            labelText: "Observaciones sobre el pedido",
            labelStyle: TextStyle(
              color: colorBoton, //Color(0xFF7A9BEE),
              fontStyle: FontStyle.italic,
            ),
            // hintText: "Inserte un comentario ...",
            // hintStyle: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorBoton, //Color(0xFF7A9BEE),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorBoton, //Color(0xFF7A9BEE),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _PagoTarjeta() {
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.all(5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 55.0,
                width: 80,
                child: Image.asset(
                  'assets/tarjetas.png',
                  fit: BoxFit.contain,
                ),
              ),
              //SizedBox(width:5,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarjeta Crédito',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    'Introducir tarjeta para pago',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: SizeConfig.safeBlockHorizontal * 2.6,
                        letterSpacing: 0.1,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                //size: SizeConfig.safeBlockHorizontal * 3.2,
              ),
            ],
          ),
        ),
        onTap: () async {
            var result = await ComprobacionesDatosEnvio_Fecha_Stock();
            if (result == 'OK') {
              //----------------------------------------------------------------
              _ImportePagado = _TotalAPagar;
              if (_ImporteAdelantoPago != 0 &&
                  check_ValueImporteMinimoPagar == true)
                _ImportePagado = _ImporteAdelantoPago;
              //----------------------------------------------------------------
              String importe = (_ImportePagado * 100).round().toString();
              StripeService.init();
              var result = await StripeService.makePayment(amount:importe, currency:'EUR');
              if (result == 'OK') {
                //ENVIAR PEDIDO.....
                _EnviarPedidoAlERP();
              } else {
                //await DialogHelper.exit(context, 'OPERACION CANCELADA', 'Pulse Aceptar para continuar','Aceptar');
              }
            }
            //Navigator.push(context, SlideFromRightPageRoute(widget: HomePageStripe(importe:importe,))); //VA EN CTMS
          }
        //splashColor: Color(0xFF7A9BEE),
      ),
    );
  }


  Widget _botonConfimarPedido() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(begin: Alignment.centerRight, colors: [
            colorBoton, colorBoton,
            //Color(0xFF7A9BEE),Color(0xFF7A9BEE),
          ])), //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          var result = await ComprobacionesDatosEnvio_Fecha_Stock();
          if (result == 'OK') {
            setState(() {
              realizandoPedido = true;
            });
            _EnviarPedidoAlERP();
          }
        },
        child: Text("CONFIRMAR PEDIDO",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18.0,
                color: colorletraBoton, //Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      //backgroundColor: Color(0xFF7A9BEE),
      appBar: NewGradientAppBar(
        gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        //backgroundColor: Color(0xFF7A9BEE),
        elevation: 0.0,
        title: Text('Detalles Pedido',
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 18.0, color: Colors.white)),
        centerTitle: true,
      ),
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Observaciones(),
                (PermitirEnvioADomicilio)
                    ? _OpcionesRecogidaButton()
                    : _BotonElegirTienda(),
                _FechaServicio(),
                _DatosEnvio(),
                (_Envio == 'ENVIO A DOMICILIO')
                    ? _CambiarDatosEnvio()
                    : SizedBox.shrink(),
                SizedBox(height: 5.0),
                _TextoGastosEnvio(),
                (API.GetPoliticaPrivacidad() != '' &&
                        API.varAceptacionPoliticaAPP() == false)
                    ? _OpcionPrivacidad()
                    : SizedBox(height: 10.0),
                _WidgetTotal(),
                (API.GetPctImporteMinimoPagar() > 0.0 &&
                        _clienteDePrepago == true)
                    ? _OpcionImporteMinimoPagar()
                    : SizedBox.shrink(),
                SizedBox(height: 5.0),
                (_clienteDePrepago == true)
                    ? _PagoTarjeta()
                    : _botonConfimarPedido(),
              SizedBox(height: 5.0),
              ],
            ),
          )),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var action = await DialogHelper.exit(
              context, 'OPERACION REALIZADA CORRECTAMENTE',
              'Pulse Aceptar para continuar', 'Aceptar');
          Navigator.pop(context, 'OK');
        },
        child: Icon(Icons.done),
      ),*/
    );
  }
}
