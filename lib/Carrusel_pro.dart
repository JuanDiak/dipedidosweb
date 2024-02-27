import 'dart:convert';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

import 'Foto.dart';
import 'rutas/Scale.dart';

class Carrusel_pro extends StatelessWidget {
  var itemImagen;
  var listaImagenes;
  String articulo;
  String licencia;
  Carrusel_pro(
      {this.itemImagen, this.listaImagenes, this.articulo, this.licencia});

  ScreenshotController screenshotControllerFoto = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Screenshot(
        controller: screenshotControllerFoto,
        child: Stack(children: [
          Container(
              // height: MediaQuery.of(context).size.height * 0.70,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: (listaImagenes.length > 0)
                  ? Carousel(
                      boxFit: BoxFit.contain,
                      images: listaImagenes.map((i) {
                        return Image.memory(
                          base64Decode(i.imagenbase64),
                          scale: 1.0,
                          // height: double.infinity,
                          // width: double.infinity,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        );
                      }).toList(),
                      dotSize: 4.0,
                      indicatorBgPadding: 4.0,
                      autoplay: false,
                      onImageTap: (i) async {
                        await Navigator.push(
                            context,
                            ScaleRoute(
                                page: Foto(base64Decode(
                                    listaImagenes[i].imagenbase64)),
                                ms: 800));
                      },
                    )
                  : Carousel(
                      boxFit: BoxFit.contain,
                      images: [
                        Image.memory(
                          base64Decode(itemImagen.imagenbase64),
                          scale: 1.0,
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                        ),
                      ],
                      dotSize: 4.0,
                      indicatorBgPadding: 4.0,
                      autoplay: false,
                      onImageTap: (i) async {
                        await Navigator.push(
                            context,
                            ScaleRoute(
                                page:
                                    Foto(base64Decode(itemImagen.imagenbase64)),
                                ms: 800));
                      },
                    )),
          Positioned(
            top: 30.0,
            left: 10.0,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop('OK');
              },
              icon: Icon(Icons.close),
              color: Colors.black38,
            ),
          ),
          Positioned(
              top: 30.0,
              right: 0.0,
              child: IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.black38,
                ),
                onPressed: () async {
                  String msg1 =
                      '¡Mira lo que estoy pensando comprar en ${licencia} gracias a la app de diakros dkPedidos, ${articulo}!';
                  String msg2 = 'descárgatela gratis para Android en ';
                  msg2 = msg2 +
                      'http://play.google.com/store/apps/details?id=com.diakros.dipedidosweb y para iOS en https://apps.apple.com/es/app/dkpedidos/id1501837627';
                  await screenshotControllerFoto.capture().then((capturedImage) async {
                    SocialShare.shareOptions('$msg1\n$msg2',
                            //imagePath: capturedImage.path
                    ).then((data) {
                      print(data);
                    });
                  });
                },
              ))
        ]),
      ),
    );
  }
}
