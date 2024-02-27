import 'dart:convert';

List<PedidoLin> clientFromJson(String str) => List<PedidoLin>.from(json.decode(str).map((x) => PedidoLin.fromJson(x)));
String clientToJson(List<PedidoLin> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PedidoLin {
  int numLin;
  int idArticulo;
  String articulo;
  double precio;
  double cantidad;
  double importe;
  String comentario;

  PedidoLin({
    this.numLin,
    this.idArticulo,
    this.articulo,
    this.precio,
    this.cantidad,
    this.importe,
    this.comentario
  });


  factory PedidoLin.fromJson(Map<String, dynamic> json) => PedidoLin(
    numLin: json["numLin"],
    idArticulo: json["idArticulo"],
    articulo: json["articulo"],
    precio: json["precio"].toDouble(),
    cantidad: json["cantidad"].toDouble(),
    importe: json["importe"].toDouble(),
    comentario: json["comentario"],
  );

  Map<String, dynamic> toJson() => {
    "numLin": numLin,
    "idArticulo": idArticulo,
    "articulo": articulo,
    "precio":precio,
    "cantidad":cantidad,
    "importe":importe,
    "comentario":comentario,
  };
}

