import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'Api.dart';
import 'Principal.dart';
import 'Utils/Dialogs.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'Variables.dart';

class CamaraFotos extends StatefulWidget {
  int idArticulo;
  String Articulo;
  CamaraFotos({this.idArticulo, this.Articulo});
  _CamaraFotos createState() => _CamaraFotos();
}

class _CamaraFotos extends State<CamaraFotos> {
  File _imageCamara;
  final picker = ImagePicker();
  int idArticulo = 0;
  String Articulo='';
  bool bEnviandofoto=false;
  String imagenBase64_900;
  String imagenBase64_300;
  bool Check_Value=false;
  bool loading=false;

  @override
  void initState() {
    super.initState();
    idArticulo = widget.idArticulo;
    Articulo = widget.Articulo;
  }

  Future<List<int>> testCompressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 90,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  getImageFile(ImageSource source) async {
    int size1=1200;
    int size2=300;
    if (ResolucionImagenesSecundarias.length>3){
      ResolucionImagenesSecundarias= ResolucionImagenesSecundarias.toUpperCase();
      size1=int.parse(ResolucionImagenesSecundarias.substring(0, ResolucionImagenesSecundarias.indexOf('X')));
    }
    if (ResolucionImagenes.length>3){
      ResolucionImagenes= ResolucionImagenes.toUpperCase();
      size2=int.parse(ResolucionImagenes.substring(0, ResolucionImagenes.indexOf('X')));
    }
    final pickedFile = await picker.pickImage(source: source);
    //-----------------------------------------------------
    if (pickedFile!=null) {
      setState(() {
        loading = true;
      });
      _imageCamara = File(pickedFile.path);
      var result300 = await FlutterImageCompress.compressWithFile(
        File(pickedFile.path).absolute.path,
        minWidth: size2,
        minHeight: size2,
        //quality: 94,
        //rotate: 90,
      );
      //-----------------------------------------------------
      imagenBase64_300 = base64Encode(result300);
      //-----------------------------------------------------
      setState(() {
        loading = false;
      });
      //-----------------------------------------------------
      var result900 = await FlutterImageCompress.compressWithFile(
        File(pickedFile.path).absolute.path,
        minWidth: size1,
        minHeight: size1,
      );
      imagenBase64_900 = base64Encode(result900);
    }
    //-----------------------------------------------------
    //List<int> imageBytes =result;
    //List<int> imageBytes = _imageCamara.readAsBytesSync();
    //imagenBase64_900 = base64Encode(imageBytes);
    // print('900: ${File(pickedFile.path).lengthSync()}');
    // print('300: ${result300.length}');
    //-----------------------------------------------------
  }

  Future EnviarFoto(int iTipo) async {
    var result;
    String imagen='';
    if (iTipo == 1) imagen = imagenBase64_300;
    if (iTipo == 2 || iTipo == 3) imagen = imagenBase64_900;
    try {
      await API.SendFoto(idArticulo, imagen, iTipo).then((response) async {
        if (response == 'OK') {
          result = response;
          if (iTipo == 1) {
            var index = lista_imagenesArticulos_WebS.indexWhere((user) =>
            user.idArticulo == idArticulo);
            lista_imagenesArticulos_WebS[index].imagenbase64 =
                imagenBase64_300;
          }
        } else {
          await Dialogs.Dialogo(
              context, 'ERROR', idArticulo.toString(), 'OK', '');
        }
      });
    } catch (e) {}
    return result;
  }

  void _onCheckboxChanged(bool newValue) => setState(() {
    Check_Value = newValue;
    if (Check_Value) {
      // TODO: Here goes your functionality that remembers the user.
    } else {
      // TODO: Forget the user
    }
  });

  Widget Imagen(){
    return  (_imageCamara != null) ?
      Center(child: Container(child: Image.file(_imageCamara,width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.width,fit: BoxFit.cover ,)))
        :SizedBox.shrink();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: colorApp3, //Color(0xFF7A9BEE),
      appBar: NewGradientAppBar(
        gradient: LinearGradient(colors: [colorApp1, colorApp2, colorApp3]),
        title: Text('Fotos',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: colorletraApp,
            )),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Imágenes adicionales'),
                  Checkbox(
                    value: Check_Value,
                    onChanged: _onCheckboxChanged,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text(Articulo,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: 20,),
              (loading)?
              Column(
                children: [
                  SizedBox(height: 100,),
                  Center(child: CircularProgressIndicator()),
                ],
              ):
              Imagen(),
              SizedBox(
                height: 10,
              ),

            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
              label: Text('Cámara'),
              backgroundColor: colorBoton,
              foregroundColor: colorletraBoton,
              onPressed: () => getImageFile(ImageSource.camera),
              heroTag: null, //UniqueKey(),
              icon: Icon(Icons.camera)),
          SizedBox(width: 10,),
          FloatingActionButton.extended(
              label: Text('Galería'),
              backgroundColor: colorBoton,
              foregroundColor: colorletraBoton,
              onPressed: () => getImageFile(ImageSource.gallery),
              heroTag: null, //UniqueKey(),
              icon: Icon(Icons.photo_library)),
          SizedBox(width: 10,),
          FloatingActionButton(
            tooltip: 'Enviar',
            child: Icon(Icons.send),
            //label: Text('Enviar'),
            backgroundColor: colorBoton,
            foregroundColor: colorletraBoton,
            onPressed: () async {
              if (bEnviandofoto==false && imagenBase64_300!=null && imagenBase64_300!='') {
                bEnviandofoto=true;
                ProgressDialog dialog = new ProgressDialog(context);
                dialog.style(message: 'Enviando foto...');
                await dialog.show();
                var result;
                if (Check_Value) {
                  result = await EnviarFoto(3); //ADICIONEALES
                }else {
                  result = await EnviarFoto(1);   //300x300
                  result = await EnviarFoto(2); //CALIDAD
                }
                await dialog.hide();
                bEnviandofoto=false;
                if (result=='OK' ) Navigator.of(context).pop('OK'); //&& Check_Value==false
              }
            },
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
