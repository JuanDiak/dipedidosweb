import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utils/Dialogs.dart';
import 'animations/fadeAnimation.dart';
import 'Variables.dart';

class DireccionEnvio extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DireccionEnvioState();
  }
}

class DireccionEnvioState extends State<DireccionEnvio> {
  String _provinciaEnvio, _localidadEnvio, _domiciliodEnvio, _codpostalEnvio;
  final ctrl_provinciaEnvio = TextEditingController();
  final ctrl_localidadEnvio = TextEditingController();
  final ctrl_domiciliodEnvio = TextEditingController();
  final ctrl_codpostalEnvio = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DireccionEnvioState() {
    _LeerPreferencias();
  }

  _LeerPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _domiciliodEnvio = (prefs.getString('domicilioEnvio') ?? "");
    if (_domiciliodEnvio == "") {
      _domiciliodEnvio = (prefs.getString('domicilio') ?? "");
      _localidadEnvio = (prefs.getString('localidad') ?? "");
      _codpostalEnvio = (prefs.getString('codpostal') ?? "");
      _provinciaEnvio = (prefs.getString('provincia') ?? "");
    }else {
      _localidadEnvio = (prefs.getString('localidadEnvio') ?? "");
      _codpostalEnvio = (prefs.getString('codpostalEnvio') ?? "");
      _provinciaEnvio = (prefs.getString('provinciaEnvio') ?? "");
    }
    ctrl_provinciaEnvio.text = (_provinciaEnvio ?? "");
    ctrl_localidadEnvio.text = (_localidadEnvio ?? "");
    ctrl_domiciliodEnvio.text = (_domiciliodEnvio ?? "");
    ctrl_codpostalEnvio.text = (_codpostalEnvio ?? "");
    setState(() {});
  }

  _GrabarPreferencias() async {
    _provinciaEnvio = ctrl_provinciaEnvio.text;
    _localidadEnvio = ctrl_localidadEnvio.text;
    _domiciliodEnvio = ctrl_domiciliodEnvio.text;
    _codpostalEnvio = ctrl_codpostalEnvio.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('provinciaEnvio', _provinciaEnvio);
    await prefs.setString('localidadEnvio', _localidadEnvio);
    await prefs.setString('domicilioEnvio', _domiciliodEnvio);
    await prefs.setString('codpostalEnvio', _codpostalEnvio);
  }

  Widget _buildCampo(TextEditingController ctrl, String Texto, var Dato) {
    return FadeAnimation(
        0.2,
        Material(
            child: TextFormField(
          controller: ctrl,
          decoration: InputDecoration(labelText: 'Tu ${Texto} de envío '),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Es necesario introducir ${Texto}';
            }
            return null;
          },
          onSaved: (String value) {
            Dato = value;
          },
        )));
  }

  @override
  Widget build(BuildContext context) {
    final BotonGrabar = FadeAnimation(
        0.2,
        Material(
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
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  await _GrabarPreferencias();
                  await Dialogs.Dialogo(
                      context,
                      'AVISO',
                      'DATOS GRABADOS CORRECTAMENTE.',
                      'OK','');
                  Navigator.pop(context, 'OK');
                },
                child: Text("GRABAR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: colorletraBoton,
                        fontWeight: FontWeight.bold)),
              ),
            )));
    return Scaffold(
        appBar: NewGradientAppBar(
          gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
          title: Text('Dirección de Envío'),
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
                        _buildCampo(ctrl_domiciliodEnvio, 'domicilio', _domiciliodEnvio),
                        _buildCampo(ctrl_localidadEnvio, 'localidad', _localidadEnvio),
                        _buildCampo(ctrl_codpostalEnvio, 'código postal', _codpostalEnvio),
                        _buildCampo(ctrl_provinciaEnvio, 'provincia', _provinciaEnvio),
                        SizedBox(height: 60,),
                        BotonGrabar,
                      ],
                    ),
                  )),
            ])));
  }

  @override
  void dispose() {
    ctrl_provinciaEnvio.dispose();
    ctrl_localidadEnvio.dispose();
    ctrl_domiciliodEnvio.dispose();
    ctrl_codpostalEnvio.dispose();
    super.dispose();
  }
}
