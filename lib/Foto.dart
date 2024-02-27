import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Foto extends StatefulWidget {
  var imagen;
  Foto(this.imagen);

  @override
  _Foto createState() => _Foto();
}

class _Foto extends State<Foto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Stack(children: [
        Container(
          alignment: FractionalOffset.center,
          child: PhotoView(
            imageProvider: MemoryImage(
              widget.imagen,
              scale: 1.0,
            ),
            minScale: PhotoViewComputedScale.contained * 1.0,
            maxScale: PhotoViewComputedScale.covered * 1.0,
          ),
        ),
        Positioned(
          top: 30.0,
          left: 10.0,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop('OK');
            },
            icon: Icon(Icons.close),
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}