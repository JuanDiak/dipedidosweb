import 'dart:convert';

List<PedidoCab> clientFromJson(String str) => List<PedidoCab>.from(json.decode(str).map((x) => PedidoCab.fromJson(x)));
String clientToJson(List<PedidoCab> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PedidoCab {
  int id;
  String fecha;
  String fechaservicio;
  double importetotal;
  String observaciones;
  String fechaenvio;
  String nombrepedido;
  String licencia;

  PedidoCab({
    this.id,
    this.fecha,
    this.fechaservicio,
    this.importetotal,
    this.observaciones,
    this.fechaenvio,
    this.nombrepedido,
    this.licencia,
  });


  factory PedidoCab.fromJson(Map<String, dynamic> json) => PedidoCab(
    id: json["id"],
    fecha: json["fecha"],
    fechaservicio: json["fechaservicio"],
    importetotal: json["importetotal"].toDouble(),
    observaciones: json["observaciones"],
    fechaenvio: json["fechaenvio"],
    nombrepedido: json["nombrepedido"],
    licencia: json["licencia"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fecha": fecha,
    "fechaservicio":fechaservicio,
    "importetotal":importetotal,
    "observaciones":observaciones,
    "fechaenvio":fechaenvio,
    "nombrepedido":nombrepedido,
    "licencia":licencia,
  };
}

