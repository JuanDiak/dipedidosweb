import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'Licencias.dart';
import 'rutas/SlideFromRightPageRoute.dart';
import 'package:flutter/material.dart';
import 'Api.dart';
import 'Principal.dart';
import 'Registro.dart';
import 'Utils/Dialogs.dart';
import 'animations/fadeAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:social_share/social_share.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:barcode_scan_fix/barcode_scan.dart';

final ctrl_licencia = TextEditingController();
final ctrl_usuario = TextEditingController();
final ctrl_password = TextEditingController();
bool isSending = false;
bool Espera = false;
final iAltoCursorCircular = 40.0;
bool _obscureText = true;
final licenciaFieldFocusNode = FocusNode();
final passwordFieldFocusNode = FocusNode();
ScreenshotController screenshotControllerFoto = ScreenshotController();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
  //JIA
}

class _LoginPageState extends State<LoginPage> {
  String licencia, usuario, password;
  var barcode;

  @override
  void initState() {
    super.initState();
   // initPlatformState();
    _LeerPreferencias();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
/*    ctrl_licencia.dispose();
    ctrl_usuario.dispose();
    ctrl_password.dispose();*/
  }

  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //final counter = prefs.getInt('counter') ?? 0; Intenta leer datos de la clave del contador. Si no existe, retorna 0.
    //prefs.remove('counter');
    //Intenta leer datos de la clave del licencia. Si no existe, retorna "".
    licencia = (prefs.getString('licencia') ?? "");
    //licencia = licencia.replaceAll(" ", "");
    usuario = (prefs.getString('usuario') ?? "");
    usuario = usuario.replaceAll(" ", "");
    password = (prefs.getString('password') ?? "");
    setState(() {
      ctrl_licencia.text = licencia;
      ctrl_usuario.text = usuario;
      ctrl_password.text = password;
    });
  }

  _GrabarPreferencias() async {
    licencia = ctrl_licencia.text;
    usuario = ctrl_usuario.text;
    usuario = usuario.replaceAll(" ", "");
    password = ctrl_password.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('licencia', licencia);
    await prefs.setString('usuario', usuario);
    await prefs.setString('password', password);
  }

  _GrabarLicencias() async {
    licencia = ctrl_licencia.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //---------------------------------
    /* for( var i = 1 ; i <= 10; i++ ) { //BORRA TODAS LAS LICENCIAS
      await prefs.setString('licencia$i', '');
    }*/
    for (var i = 1; i <= 10; i++) {
      String lic = (prefs.getString('licencia$i') ?? "");
      if (lic == licencia) {
        break;
      } else {
        if (lic == '') {
          await prefs.setString('licencia$i', licencia);
          break;
        }
      }
    }
  }

  _ReenviarPassword() async {
    var result;
    if (Espera == false) {
      Espera = true;
      isSending = true;
      usuario = ctrl_usuario.text;
      usuario = usuario.replaceAll(" ", "");
      result = await API.EnviarPassword(usuario);
      if (result == 'Correcto') {
        await Dialogs.Dialogo(
            context,
            'EMAIL ENVIADO',
            'Se ha enviado un correo electrónico con los datos de acceso a: ${usuario}',
            'OK',
            '');
      } else {
        if (result == 'No registrado') {
          await Dialogs.Dialogo(context, 'ERROR DE VERIFICACION',
              'Usuario no registrado', 'OK', '');
        } else {
          await Dialogs.Dialogo(
              context,
              'ERROR DE VERIFICACION',
              '${result.toString()}. Por favor, revisa tus datos de inicio de sesión',
              'OK',
              '');
        }
      }
      Espera = false;
    }
    isSending = false;
    return result;
  }

  _GetLicencia() async {
    var result;
    String licenciaAdministrador;
    if (Espera == false) {
      Espera = true;
      isSending = true;
      result = await API.ComprobarLicencia(licencia, usuario, password);
      if (result == 'OK') {
        result = await API.Acceso_APP(usuario, password);
        if (result.indexOf('#')!=-1) {
          if (result.substring(0, result.indexOf('#')) == 'ADMINISTRADOR') {
            licenciaAdministrador =
                result.substring(result.indexOf('#') + 1, result
                    .toString()
                    .length);
            result = 'OK';
            var _licenciaAdministrador = licenciaAdministrador.split(";");
            for (int i=0; i<_licenciaAdministrador.length; i++ ){
              print(_licenciaAdministrador[i].toUpperCase());
              if (_licenciaAdministrador[i].toUpperCase()==licencia.toUpperCase()){
                //print(_licenciaAdministrador[i].toUpperCase());
                result = 'ADMINISTRADOR';
              }
            }
          }
        }
        if (result == 'OK' || result == 'ADMINISTRADOR') {
          await _GrabarLicencias();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return Principal(
              usuario: usuario,
              administrador: (result == 'ADMINISTRADOR')? true: false,
            );
          }));
        } else {
          await Dialogs.Dialogo(
              context,
              'No se ha podido iniciar sesión',
              'Email o contraseña no válidos. Por favor, revisa tus datos de inicio de sesión',
              'OK',
              '');
        }
      } else {
        await Dialogs.Dialogo(
            context,
            'No se ha podido iniciar sesión',
            '${result.toString()}. Por favor, revisa tus datos de inicio de sesión',
            'OK',
            '');
      }
      Espera = false;
    }
    isSending = false;
    return result;
  }

/*  _GetLicenciaScanQR() async {
    String result = await _scanQR2();
    if (result == 'OK') {
      ctrl_licencia.text = barcode;
      setState(() {
        ctrl_licencia.text = barcode;
      });
    } else {
      await Dialogs.Dialogo(
          context,
          'No se ha podido iniciar sesión',
          '${result.toString()}. Por favor, revisa tus datos de inicio de sesión',
          'OK',
          '');
      //'Email o contraseña no válidos.
    }
  }*/

  /*Future _scanQR2() async {
    String result = 'OK';
    barcode = '';
    try {
      barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
          result = 'El usuario no otorgó permiso a la cámara!';
      } else {
        result = 'Error: $e';
      }
    } on FormatException{
    result = 'El usuario canceló usando el botón "atrás" antes de escanear';
    } catch (e) {
      result = 'Error: $e';
    }
    return (result);
  }*/

  Widget getInfo(BuildContext context) {
    return FutureBuilder(
      future: _GetLicencia(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: iAltoCursorCircular,
                    width: iAltoCursorCircular,
                    child: CircularProgressIndicator(
                      strokeWidth: 8,
                    )),
              ],
            ));
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return SizedBox(
              height: iAltoCursorCircular,
            );
          default:
            return Text('Presiona el boton para recargar');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginButon = FadeAnimation(
        2.2,
        Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      // begin: Alignment.centerRight,
                      colors: [
                        Colors.blue[900], Colors.blue[800], Colors.blue[600]
                      ])), //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: () async {
                  if (isSending == false) {
                    _GrabarPreferencias();
                    if (licencia == '' || usuario == '' || password == '') {
                      await Dialogs.Dialogo(
                          context,
                          'No se ha podido iniciar sesión',
                          'Email o contraseña no válidos. Por favor, revisa tus datos de inicio de sesión',
                          'OK',
                          '');
                    } else {
                      setState(() {
                        isSending = true;
                      });
                    }
                  }
                },
                child: Text("INICIA SESIÓN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            )));
    final registrarse = FadeAnimation(
        2.2,
        Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      // begin: Alignment.centerRight,
                      colors: [
                        Colors.blue[900], Colors.blue[800], Colors.blue[600]
                      ])), //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                onPressed: () async {
                  usuario = ctrl_usuario.text;
                  usuario = usuario.replaceAll(" ", "");
                  password = ctrl_password.text;
                  if (usuario == '' || password == ''){
                      await Dialogs.Dialogo(
                          context,
                          'FALTAN DATOS',
                          'Debe introducir un mail y una contraseña',
                          'OK',
                          '');
                  }else{
                    if (!RegExp(
                        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                        .hasMatch(usuario)) {
                          await Dialogs.Dialogo(
                            context,
                            'ERROR EN DATOS',
                            'Por favor introduzca un email válido',
                            'OK',
                          '');
                    }else{
                      await _GrabarPreferencias();
                      Navigator.push(
                          context, SlideFromRightPageRoute(widget: Registro()));
                    }
                  }
                },
                child: Text("REGÍSTRATE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            )));
    final obtenerLicencia = FadeAnimation(
        2.2,
        Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      //begin: Alignment.centerRight,
                      colors: [
                        Colors.teal[800],
                        Colors.teal[700],
                        Colors.teal[600]
                      ])), //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                onPressed: () {
                 // _GetLicenciaScanQR();
                },
                child: Text("OBTENER LICENCIA QR...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            )));
    final licenciaField = FadeAnimation(
        1.6,
        Container(
          //width:  MediaQuery.of(context).size.width-100,
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
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            decoration: BoxDecoration(
                //    border: Border(bottom: BorderSide(color: Colors.grey))
                ),
            child: TextField(
              focusNode: licenciaFieldFocusNode,
              textCapitalization: TextCapitalization.characters,
              controller: ctrl_licencia,
              decoration: InputDecoration(
                  hintText: "Licencia",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.create),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.store,
                      color: Colors.blue[700],
                      size: 36,
                    ),
                    onPressed: () async {
                      licenciaFieldFocusNode.unfocus();
                      licenciaFieldFocusNode.canRequestFocus = false;
                      Future.delayed(Duration(milliseconds: 100), () {
                        licenciaFieldFocusNode.canRequestFocus = true;
                      });
                      var result = await Navigator.of(context).push(
                          CupertinoPageRoute(builder: (BuildContext context) {
                        return WidgetLicencias();
                      }));
                      if (result != null) {
                        ctrl_licencia.text = result;
                      }
                    },
                  ),
                  border: InputBorder.none),
            ),
          ),
        ));
    final usuarioField = FadeAnimation(
        1.6,
        Container(
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
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            decoration: BoxDecoration(
                //    border: Border(bottom: BorderSide(color: Colors.grey))
                ),
            child: TextField(
              controller: ctrl_usuario,
              decoration: InputDecoration(
                  hintText: "Usuario",
                  hintStyle: TextStyle(color: Colors.grey),
                  //border: OutlineInputBorder(
                  //  borderRadius: BorderRadius.circular(20.0),
                  //),
                  prefixIcon: Icon(Icons.person),
                  border: InputBorder.none),
            ),
          ),
        ));
    final passwordField = FadeAnimation(
        1.9,
        Container(
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
            padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            decoration: BoxDecoration(
                //    border: Border(bottom: BorderSide(color: Colors.grey))
                ),
            child: TextField(
              focusNode: passwordFieldFocusNode,
              controller: ctrl_password,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      passwordFieldFocusNode.unfocus();
                      passwordFieldFocusNode.canRequestFocus = false;
                      Future.delayed(Duration(milliseconds: 100), () {
                        passwordFieldFocusNode.canRequestFocus = true;
                      });
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: InputBorder.none),
            ),
          ),
        ));
    final cambiarpassword = FadeAnimation(
        1.9,
        Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 30,
                  child: MaterialButton(
                    highlightColor: Colors.lightBlue[100],
                    onPressed: () async {
                      await _ReenviarPassword();
                    },
                    child: Text('¿Olvidaste tu contraseña?',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ),
            ),
          ]),
        ));
    /*final wasapButon = FadeAnimation(
      1.9,
      InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                width: 50,
                height: 50,
                child: Image.asset(
                  'assets/wasap.png',
                  fit: BoxFit.contain,
                )),
          ],
        ),
        onTap: () {
          //String msg='¡Mira lo que estoy pensando comprar en ${licencia} gracias a la app de diakros dkpedidos, ${widget.articulo}! ';
          String msg =
              '¡Puedes pedir en ${licencia} gracias a la app de diakros dkpedidos! ';
          msg = msg + 'descárgatela gratis para Android en ';
          msg = msg +
              'http://play.google.com/store/apps/details?id=com.diakros.dipedidosweb y para iOS en https://apps.apple.com/es/app/dkpedidos/id1501837627';
          SocialShare.shareWhatsapp(msg).then((data) {print(data);});
          //FlutterOpenWhatsapp.sendSingleMessage("", msg);
        },
      ),
    );*/

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.blue[900], Colors.blue[800], Colors.blue[600]
            //Color(0xFFF206ffd),
            //Color(0xFFF3280fb),
            //Color(0xFFF28c3eb)
          ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Row(children: [
                Expanded(
                  child:
                  Screenshot(
                    controller: screenshotControllerFoto,
                    child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 55.0,
                        child:
                       Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 15),
                      FadeAnimation(
                          1.2,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("dkPedidos",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )),
                    ],
                  ),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.share),
                    color: Colors.white,
                    onPressed: () async {
                      String msg =
                          '¡Puedes pedir en ${licencia} gracias a la app de diakros dkpedidos! ';
                      msg = msg + 'descárgatela gratis para Android en ';
                      msg = msg +
                          'http://play.google.com/store/apps/details?id=com.diakros.dipedidosweb y para iOS en https://apps.apple.com/es/app/dkpedidos/id1501837627';
                      io.Directory appDocDirectory;
                      if (io.Platform.isIOS) {
                        appDocDirectory = await getApplicationDocumentsDirectory();
                      } else {
                        appDocDirectory = await getExternalStorageDirectory();
                      }
                      String _mPath = '${appDocDirectory.path}/logo.png';
                      await deleteFile(_mPath);
                      io.File imgFile = io.File(_mPath);
                      final ByteData bytes = await rootBundle.load('assets/logo.png');
                      final Uint8List pngBytes = bytes.buffer.asUint8List();
                      await imgFile.writeAsBytes(pngBytes).then((onValue) {});
                      SocialShare.shareOptions(msg, imagePath: imgFile.path).then((data) {print(data);});
                      }
                  ),
                ),
              ]),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFFf4f7fc),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(35),
                          topLeft: Radius.circular(35))),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          licenciaField,
                          SizedBox(height: 10),
                          usuarioField,
                          SizedBox(height: 10),
                          passwordField,
                          SizedBox(height: 10),
                          cambiarpassword,
                          Stack(
                            children: [
                              (isSending)
                                  ? getInfo(context)
                                  : SizedBox(height: iAltoCursorCircular),
                            ],
                          ),
                          loginButon,
                          SizedBox(height: 10),
                          registrarse,
                          SizedBox(height: 10),
                          obtenerLicencia,
                          SizedBox(height: 10),
                          //wasapButon,
                          // SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
