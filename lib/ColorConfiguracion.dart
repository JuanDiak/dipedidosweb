import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'Variables.dart';
import 'package:provider/provider.dart';
import 'Notificadores.dart';

class ColorConfiguracion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ColorConfiguracionState();
  }
}

class _ColorConfiguracionState extends State<ColorConfiguracion> {
  int group = 1;
  Color _colorApp1 = colorApp1;
  Color _colorApp2 = colorApp2;
  Color _colorApp3 = colorApp3;
  Color _colorletraApp = colorletraApp;
  Color _colorBoton = colorBoton;
  Color _colorletraBoton = colorletraBoton;
  Color _currentColor = colorApp1;
  final _controller = CircleColorPickerController(initialColor: colorApp1,);

  void _onColorChanged(Color color) {
    setState(() => _currentColor = color);
    switch (group) {
      case 1:
        _colorApp1 = color;
        _colorApp2 = color;
        _colorApp3 = color;
        break;
      case 2:
        _colorletraApp=color;
        break;
      case 3:
        _colorBoton=color;
        break;
      case 4:
        _colorletraBoton=color;
        break;
    }
  }

  _GrabarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorApp1', colorApp1.value.toString());
    await prefs.setString('colorApp2', colorApp2.value.toString());
    await prefs.setString('colorApp3', colorApp3.value.toString());
    await prefs.setString('colorBoton',colorBoton.value.toString());
    await prefs.setString('colorletraBoton', colorletraBoton.value.toString());
    await prefs.setString('colorletraApp',colorletraApp.value.toString());
  }

  Future EnviarColores() async {
    var result;
    int cApp1, cApp2, cApp3, cBoton, clApp, clBoton ;
    cApp1=colorApp1.value;
    cApp2=colorApp2.value;
    cApp3=colorApp3.value;
    cBoton=colorBoton.value;
    clApp=_colorletraApp.value;
    clBoton=colorletraBoton.value;
    try {
      await API.SendColoresApp(cApp1, cApp2, cApp3, cBoton, clApp, clBoton).then((response) async {
        if (response=='OK') {
          result = response;
        }
      });
    } catch (e) {}
    return result;
  }

  Widget opciones() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Radio(
                    value: 1,
                    groupValue: group,
                    onChanged: (T) {
                      print(T);
                      setState(() {
                        _currentColor = _colorApp1;
                        group = T;
                      });
                    }),
                Text('barra título'),
              ],
            ),

            Row(
              children: [
                Text('letra título'),
                Radio(
                    value: 2,
                    groupValue: group,
                    onChanged: (T) {
                      print(T);
                      setState(() {
                        _currentColor = _colorletraApp;
                        group = T;
                      });
                    }),

              ],
            ),

          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: _colorApp1,
              ),
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Text("Ejemplo...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: _colorletraApp,
                        fontWeight: FontWeight.bold)),
                onPressed: (){},
              ),
            ),

          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Radio(
                    value: 3,
                    groupValue: group,
                    onChanged: (T) {
                      print(T);
                      setState(() {
                        _currentColor = _colorBoton;
                        group = T;
                      });
                    }),
                Text('botón'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('letra botón'),
                Radio(
                    value: 4,
                    groupValue: group,
                    onChanged: (T) {
                      print(T);
                      setState(() {
                        _currentColor = _colorletraBoton;
                        group = T;
                      });
                    }),
              ],
            ),


          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: _colorBoton,
              ),
              child: MaterialButton(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Text("Ejemplo...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0,
                        color: _colorletraBoton,
                        fontWeight: FontWeight.bold)),
                onPressed: (){},
              ),
            ),

          ],
        )
      ],
    );
  }

  void AsignarColores(){
    colorApp1 = _colorApp1;
    colorApp2 = _colorApp2;
    colorApp3 = _colorApp3;
    colorletraApp = _colorletraApp;
    colorBoton = _colorBoton;
    colorletraBoton = _colorletraBoton;
  }

  ColoresIniciales(){
    _colorApp1=Colors.blue[900];
    _colorApp2=Colors.blue[800];
    _colorApp3=Colors.blue[600];
    _colorBoton=Colors.blue[600]; //=Colors.teal;
    _colorletraBoton=Colors.white;
    _colorletraApp=Colors.white;
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewGradientAppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, 'OK');
            }),
        title: Text('Configuración Color'),
        gradient: LinearGradient(
            colors: [_colorApp1, _colorApp1, _colorApp1]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             Center(
              child: CircleColorPicker(
                controller: _controller,
                //initialColor: _currentColor,
                onChanged: _onColorChanged,
                colorCodeBuilder: (context, color) {
                  return SizedBox.shrink();
                  /*Text(
                    'rgb(${color.red}, ${color.green}, ${color.blue})',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );*/
                },
              ),
            ),
            opciones(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Colores iniciales',
            child: Icon(Icons.info),
            //label: Text('Enviar'),
            backgroundColor: colorBoton,
            foregroundColor: colorletraBoton,
            onPressed: () async {
              ColoresIniciales();
              setState(() {

              });
            },
            heroTag: null,
          ),
          SizedBox(width: 20,),
          FloatingActionButton.extended(
              label: Text('Prueba'),
              backgroundColor: colorBoton,
              foregroundColor: colorletraBoton,
              onPressed: () {
                AsignarColores();
                context.read<ChangePage>().setPage('Articulo');
                Navigator.pop(context, 'OK');
              },
              heroTag: null, //UniqueKey(),
              icon: Icon(Icons.check)),
          SizedBox(width: 20,),
          FloatingActionButton.extended(
              label: Text('Enviar'),
              backgroundColor: colorBoton,
              foregroundColor: colorletraBoton,
              onPressed: () async {
                AsignarColores();
                _GrabarPreferencias();
                await EnviarColores();
                context.read<ChangePage>().setPage('Articulo');
                Navigator.pop(context, 'OK');
              },
              heroTag: null, //UniqueKey(),
              icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}
