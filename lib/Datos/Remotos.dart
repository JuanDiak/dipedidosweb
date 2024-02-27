import 'dart:convert';

List<Remotos> clientFromJson(String str) => List<Remotos>.from(json.decode(str).map((x) => Remotos.fromJson(x)));
String clientToJson(List<Remotos> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Remotos {
  int idRemoto;
  String nombreTienda;
  String domicilio;
  String poblacion;
  String provincia;
  String codPostal;
  String telefono;
  String horaMaxPedidos;
  String textoTiendaWeb;

  Remotos({
    this.idRemoto,
    this.nombreTienda,
    this.domicilio,
    this.poblacion,
    this.provincia,
    this.codPostal,
    this.telefono,
    this.horaMaxPedidos,
    this.textoTiendaWeb
  });


  factory Remotos.fromJson(Map<String, dynamic> json) => Remotos(
    idRemoto: json["idRemoto"],
    nombreTienda: json["nombreTienda"],
    domicilio: json["domicilio"],
    poblacion: json["poblacion"],
    provincia: json["provincia"],
    codPostal: json["codPostal"],
    telefono: json["telefono"],
    horaMaxPedidos: json["horaMaxPedidos"],
    textoTiendaWeb: json["textoTiendaWeb"],
  );

  Map<String, dynamic> toJson() => {
    "idRemoto": idRemoto,
    "nombreTienda": nombreTienda,
    "domicilio":domicilio,
    "poblacion":poblacion,
    "provincia":provincia,
    "codPostal":codPostal,
    "telefono":telefono,
    "horaMaxPedidos":horaMaxPedidos,
    "textoTiendaWeb":textoTiendaWeb,
  };
}
