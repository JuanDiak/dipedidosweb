import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'Utils/Dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Variables.dart';
import 'package:flutter/gestures.dart';

bool isSending = false;

class Registro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegistroState();
  }
}

class RegistroState extends State<Registro> {
  String _usuario,
      _password,
      _telefono,
      _nombre,
      _provincia,
      _localidad,
      _domicilio,
      _codpostal;
  final ctrl_usuario = TextEditingController();
  final ctrl_password = TextEditingController();
  final ctrl_telefono = TextEditingController();
  final ctrl_nombre = TextEditingController();
  final ctrl_provincia = TextEditingController();
  final ctrl_localidad = TextEditingController();
  final ctrl_domicilio = TextEditingController();
  final ctrl_codpostal = TextEditingController();
  bool Check_Value = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> _launched;
  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  void _onCheckboxChanged(bool newValue) => setState(() {Check_Value = newValue;});

  Widget LinkTerminos(){
    const String toLaunch = 'http://diakros.com/politica-de-privacidad/';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
        value: Check_Value,
        onChanged: _onCheckboxChanged,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
                text: 'He leído y acepto la ',
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: 'Política de Privacidad*',
                      style: TextStyle(
                          color: Colors.lightGreen),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => setState(() {
                          _launched = _launchInBrowser(toLaunch);
                        }),
                  )
                ]
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(8.0)),
        FutureBuilder<void>(future: _launched, builder: _launchStatus),
      ],
    );
  }
  RegistroState() {
    _LeerPreferencias();
  }
  _EnviarRegistro() async {
    String mensaje1, mensaje2;
    isSending = true;
    var result = await API.AltaDeUsuario_Registro(_usuario, _password);
    setState(() {
      isSending = false;
    });
    switch (result) {
      case 'CORRECTO':
        mensaje1 = 'EMAIL ENVIADO';
        mensaje2 =
            'Simplemente haga clic en el enlace VERIFICAR SU CUENTA enviado a: $_usuario';
        break;
      case 'ESPERANDO ACTIVACION':
        mensaje1 = 'EMAIL ENVIADO';
        mensaje2 =
            '¿ No has recibido un correo electrónico ?\nRevise su bandeja de entrada. Asegúrese de revisar la carpeta de spam por si acaso.';
        break;
      case 'USUARIO YA REGISTRADO PREVIAMENTE':
        mensaje1 = 'ERROR DE VERIFICACION';
        mensaje2 = 'Este usuario ya está registrado.';
        break;
      case 'ESPERANDO ACTIVACION CON OTRO PASSWORD':
        mensaje1 = 'ERROR DE VERIFICACION';
        mensaje2 = result;
        break;
      case 'USUARIO YA REGISTRADO PREVIAMENTE CON OTRO PASSWORD':
        mensaje1 = 'ERROR DE VERIFICACION';
        mensaje2 = result;
        break;
      default:
        mensaje1 = 'ERROR DE VERIFICACION';
        mensaje2 = result;
        break;
    }
    await Dialogs.Dialogo(context, mensaje1, mensaje2, 'OK', '');
    isSending = false;
    Navigator.pop(context, 'OK');
    return result;
  }

  _ReenviarMail_Registro() async {
    isSending = true;
    var result = await API.ReenviarMail_Registro(_usuario);
    setState(() {
      isSending = false;
    });
    if (result == 'OK') {
      await Dialogs.Dialogo(
          context,
          'EMAIL ENVIADO',
          'Se ha enviado un correo electrónico con los datos de acceso a: ${_usuario}',
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
    Navigator.pop(context, 'OK');
    return result;
  }

  Widget getInfo(BuildContext context) {
    return FutureBuilder(
      future: _EnviarRegistro(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: 40, width: 40, child: CircularProgressIndicator()),
              ],
            ));
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return SizedBox.shrink();
          default:
            return Text('Presiona el boton para recargar');
        }
      },
    );
  }

  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _usuario = (prefs.getString('usuario') ?? "");
    _password = (prefs.getString('password') ?? "");
    _telefono = (prefs.getString('telefono') ?? "");
    _nombre = (prefs.getString('nombre') ?? "");
    _provincia = (prefs.getString('provincia') ?? "");
    _localidad = (prefs.getString('localidad') ?? "");
    _domicilio = (prefs.getString('domicilio') ?? "");
    _codpostal = (prefs.getString('codpostal') ?? "");
    ctrl_usuario.text = (_usuario ?? "");
    ctrl_password.text = (_password ?? "");
    ctrl_telefono.text = (_telefono ?? "");
    ctrl_nombre.text = (_nombre ?? "");
    ctrl_provincia.text = (_provincia ?? "");
    ctrl_localidad.text = (_localidad ?? "");
    ctrl_domicilio.text = (_domicilio ?? "");
    ctrl_codpostal.text = (_codpostal ?? "");
    setState(() {
      ctrl_usuario.text = _usuario;
      ctrl_password.text = _password;
    });
  }
  _GrabarPreferencias() async {
  //  _usuario = ctrl_usuario.text;
  //  _password = ctrl_password.text;
    _telefono = ctrl_telefono.text;
    _nombre = ctrl_nombre.text;
    _provincia = ctrl_provincia.text;
    _localidad = ctrl_localidad.text;
    _domicilio = ctrl_domicilio.text;
    _codpostal = ctrl_codpostal.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
  //  await prefs.setString('usuario', _usuario);
  //  await prefs.setString('password', _password);
    await prefs.setString('telefono', _telefono);
    await prefs.setString('nombre', _nombre);
    await prefs.setString('provincia', _provincia);
    await prefs.setString('localidad', _localidad);
    await prefs.setString('domicilio', _domicilio);
    await prefs.setString('codpostal', _codpostal);
  }

  @override
  void initState() {
    super.initState();
    _LeerPreferencias();
  }

  @override
  void dispose() {
    ctrl_usuario.dispose();
    ctrl_password.dispose();
    ctrl_telefono.dispose();
    ctrl_nombre.dispose();
    ctrl_provincia.dispose();
    ctrl_localidad.dispose();
    ctrl_domicilio.dispose();
    ctrl_codpostal.dispose();
    super.dispose();
  }

  Widget _buildUsuario2() {
    return TextFormField(
      controller: ctrl_usuario,
      decoration: InputDecoration(labelText: 'Tu email'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir un Email';
        }
        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Por favor introduzca un email válido';
        }
        return null;
      },
      onSaved: (String value) {
        _usuario = value;
      },
    );
  }
  Widget _buildPassword2() {
    return TextFormField(
      controller: ctrl_password,
      decoration: InputDecoration(labelText: 'Tu contraseña'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir una contraseña';
        }
        return null;
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }
  Widget _buildUsuario() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,10,0,5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:[
          Text('Usuario: $_usuario',
              textAlign: TextAlign.left,
              style: TextStyle(
                //fontFamily: 'Roboto',
                fontSize: 16.0,
                //fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
  Widget _buildPassword() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0,10,0,5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:[
          Text('Password: $_password',
              textAlign: TextAlign.left,
              style: TextStyle(
                //fontFamily: 'Roboto',
                fontSize: 16.0,
                //fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildTelefono() {
    return TextFormField(
      controller: ctrl_telefono,
      decoration: InputDecoration(labelText: 'Tu teléfono'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir un número de teléfono';
        }
        return null;
      },
      onSaved: (String value) {
        _telefono = value;
      },
    );
  }
  Widget _buildNombre() {
    return TextFormField(
      controller: ctrl_nombre,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: 'Tu nombre'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir un nombre';
        }
        return null;
      },
      onSaved: (String value) {
        _nombre = value;
      },
    );
  }
  Widget _buildProvincia() {
    return TextFormField(
      controller: ctrl_provincia,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: 'Tu provincia'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir una provincia';
        }
        return null;
      },
      onSaved: (String value) {
        _provincia = value;
      },
    );
  }
  Widget _buildLocalidad() {
    return TextFormField(
      controller: ctrl_localidad,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: 'Tu localidad'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir una localidad';
        }
        return null;
      },
      onSaved: (String value) {
        _localidad = value;
      },
    );
  }
  Widget _buildDomicilio() {
    return TextFormField(
      controller: ctrl_domicilio,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: 'Tu domicilio'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir un domicilio';
        }
        return null;
      },
      onSaved: (String value) {
        _domicilio = value;
      },
    );
  }
  Widget _buildCodPostal() {
    return TextFormField(
      controller: ctrl_codpostal,
      decoration: InputDecoration(labelText: 'Tu código postal'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Es necesario introducir un código postal';
        }
        return null;
      },
      onSaved: (String value) {
        _codpostal = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BotonRegistrarme = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  colors: [colorBoton, colorBoton])),
          //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            onPressed: () {
              if (Check_Value) {
                //if (!_formKey.currentState.validate()) {
                //  return;
                //}
                _GrabarPreferencias();
                setState(() {
                  isSending = true;
                });
                _EnviarRegistro();
              }else{
                Dialogs.Dialogo(context, 'Error de registro', 'Debes aceptar las condiciones de uso', 'OK','');
              }
              //_formKey.currentState.save();
            },
            child: Text("REGISTRARME",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: colorletraBoton,
                    fontWeight: FontWeight.bold)),
          ),
        ));
    final BotonGrabar = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  colors: [colorBoton, colorBoton])),
          //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            onPressed: () async {
              _GrabarPreferencias();
              await Dialogs.Dialogo(
                  context, 'AVISO', 'DATOS GRABADOS CORRECTAMENTE.', 'OK', '');
              // Navigator.pop(context, 'OK');
            },
            child: Text("GRABAR",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: colorletraBoton,
                    fontWeight: FontWeight.bold)),
          ),
        ));
    final BotonReenviarMail = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  colors: [colorBoton, colorBoton])),
          //[Color(0xFFF206ffd), Color(0xFFF3280fb)])),
          child: MaterialButton(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            onPressed: () {
              _GrabarPreferencias();
              setState(() {
                isSending=true;
              });
              _ReenviarMail_Registro();
            },
            child: Text("REENVIAR MAIL",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: colorletraBoton,
                    fontWeight: FontWeight.bold)),
          ),
        ));
    return Scaffold(
        appBar: NewGradientAppBar(
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: (){
                _GrabarPreferencias();
                Navigator.pop(context, 'OK');
              }
          ),
          title: Text('Registro'),
          gradient: LinearGradient(
              colors: [colorApp1, colorApp2, colorApp3]),
          /*  actions: [
          IconButton(
              icon: Icon(
                Icons.save_alt,
                color: Colors.white,
              ),
              onPressed: () {
                _GrabarPreferencias();
                Navigator.pop(context, 'OK');
              })
        ]*/
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(children: [
              Container(
                  padding: EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildUsuario(),
                        _buildPassword(),
                        _buildNombre(),
                        _buildTelefono(),
                        _buildDomicilio(),
                        Stack(
                          children: [
                            _buildLocalidad(),
                            (isSending) ? Center(child: CircularProgressIndicator()) : SizedBox.shrink(),
                          ],
                        ),
                        _buildCodPostal(),
                        _buildProvincia(),
                        SizedBox(height: 10),
                        //BotonGrabar,
                        //SizedBox(height: 10),
                        BotonRegistrarme,
                        SizedBox(height: 10),
                        BotonReenviarMail,
                        SizedBox(height: 30),
                        LinkTerminos(),
                        SizedBox(height: 30),
                      ],
                    ),
                  )),
            ])));
  }
}
