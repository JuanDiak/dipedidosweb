import 'dart:convert';

List<Articulos> clientFromJson(String str) => List<Articulos>.from(json.decode(str).map((x) => Articulos.fromJson(x)));
String clientToJson(List<Articulos> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
class Articulos {
  int idArticulo;
  String refCodBarras;
  String articulo;
  double precio;
  double precioCliente;
  double precioPromocion;
  double stock;
  double dto;
  int idTipoIva;
  int idFamilia;
  int idSubFamilia;
  String talla;
  String color;
  //Uint8List imagenbytes ;
  double cantidad=0;
  String observacion;
  String ObservacionesArticulo;
  String comentarioAPP;

  Articulos({
    this.idArticulo,
    this.refCodBarras,
    this.articulo,
    this.precio,
    this.precioCliente,
    this.precioPromocion,
    this.stock,
    this.dto,
    this.idTipoIva,
    this.idFamilia,
    this.idSubFamilia,
    this.talla,
    this.color,
    this.observacion, //Comentario que introduce el cliente
    this.ObservacionesArticulo,   //Observaciones de la ficha del Artículo
    this.comentarioAPP,
  });


  factory Articulos.fromJson(Map<String, dynamic> json) => Articulos(

    idArticulo: json["idArticulo"],
    refCodBarras: json["refCodBarras"],
    articulo: json["articulo"],
    precio: json["precio"].toDouble(),
    dto: json["dto"].toDouble(),
    precioCliente:
        (json["precioCliente"].toDouble()!=0)?
                ( (json["dto"].toDouble()==0)?
                              json["precioCliente"].toDouble():
                              json["precioCliente"].toDouble()-(json["precioCliente"].toDouble()*json["dto"].toDouble()/100)
                )
        : (json["dto"].toDouble()==0) ?
                json["precio"].toDouble()
                : json["precio"].toDouble()-(json["precio"].toDouble()*json["dto"].toDouble()/100),
    idTipoIva: json["idTipoIVA"],
    idFamilia: json["idFamilia"] == null ? null : json["idFamilia"],
    idSubFamilia: json["idSubFamilia"] == null ? null : json["idSubFamilia"],
    talla: json["talla"],
    color: json["color"],
    precioPromocion: json["precioPromocion"] == null ? 0 :  (json["precioCliente"].toDouble()!=0)? 0:json["precioPromocion"].toDouble(),
    stock: json["stock"] == null ? 0 : json["stock"].toDouble(),
    ObservacionesArticulo: json["observaciones"],
    comentarioAPP: json["comentarioAPP"],
  );

  //SI TIENE PRECIO CLIENTE ---> EL PRECIO PROMOCION SE LO PONGO A 0.

  Map<String, dynamic> toJson() => {
    "idArticulo": idArticulo,
    "refCodBarras": refCodBarras,
    "articulo": articulo,
    "precio": precio,
    "dto": dto,
    "precioCliente": precioCliente,
    "stock": stock,
    "precioPromocion": precioPromocion,
    "idTipoIVA": idTipoIva,
    "idFamilia": idFamilia == null ? null : idFamilia,
    "idSubFamilia": idSubFamilia == null ? null : idSubFamilia,
    "talla": talla,
    "color": color,
    "ObservacionesArticulo": ObservacionesArticulo,
    "comentarioAPP": comentarioAPP,
  };
}

class Familias {
  int idfamilia;
  String familia;
  bool conCombinaciones;
  Familias({
    this.idfamilia,
    this.familia,
    this.conCombinaciones,
  });
  factory Familias.fromJson(Map<String, dynamic> json) => Familias(
    idfamilia: json["idfamilia"],
    familia: json["familia"],
    conCombinaciones: json["conCombinaciones"],
  );
  Map<String, dynamic> toJson() => {
    "idfamilia": idfamilia,
    "familia": familia,
    "conCombinaciones": conCombinaciones,
  };
}

class SubFamilias {
  int idsubFamilia;
  int idFamilia;
  String subFamilia;
  int orden;
  SubFamilias({
    this.idsubFamilia,
    this.idFamilia,
    this.subFamilia,
    this.orden,
  });
  factory SubFamilias.fromJson(Map<String, dynamic> json) => SubFamilias(
    idsubFamilia: json["idsubFamilia"],
    idFamilia: json["idFamilia"],
    subFamilia: json["subFamilia"],
    orden: json["orden"],
  );
  Map<String, dynamic> toJson() => {
    "idsubFamilia": idsubFamilia,
    "idFamilia": idFamilia,
    "subFamilia": subFamilia,
    "orden": orden,
  };
}

class ArticulosImagenes {
  int idArticulo;
  String imagenbase64;

  ArticulosImagenes({
    this.idArticulo,
    this.imagenbase64,
  });

  factory ArticulosImagenes.fromJson(Map<String, dynamic> json) => ArticulosImagenes(
    idArticulo: json["idArticulo"],
    imagenbase64: json["imagenbase64"],
  );

  Map<String, dynamic> toJson() => {
    "idArticulo": idArticulo,
    "imagenbase64": imagenbase64,
  };
}

class SubFamiliasImagenes {
  int idsubFamilia;
  String imagenbase64;

  SubFamiliasImagenes({
    this.idsubFamilia,
    this.imagenbase64,
  });

  factory SubFamiliasImagenes.fromJson(Map<String, dynamic> json) => SubFamiliasImagenes(
    idsubFamilia: json["idsubFamilia"],
    imagenbase64: json["imagenbase64"],
  );

  Map<String, dynamic> toJson() => {
    "idsubFamilia": idsubFamilia,
    "imagenbase64": imagenbase64,
  };
}

class FamiliasImagenes {
  int idfamilia;
  String imagenbase64;

  FamiliasImagenes({
    this.idfamilia,
    this.imagenbase64,
  });

  factory FamiliasImagenes.fromJson(Map<String, dynamic> json) => FamiliasImagenes(
    idfamilia: json["idfamilia"],
    imagenbase64: json["imagenbase64"],
  );

  Map<String, dynamic> toJson() => {
    "idfamilia": idfamilia,
    "imagenbase64": imagenbase64,
  };
}

class INI {
  String clave;
  String valor;

  INI({
    this.clave,
    this.valor,
  });

  factory INI.fromJson(Map<String, dynamic> json) => INI(
    clave: json["clave"],
    valor: json["valor"],
  );

  Map<String, dynamic> toJson() => {
    "clave": clave,
    "valor": valor,
  };
}

class ArticulosLin_Stock {
  int idArticulo;
  String articulo;
  double stock;

  ArticulosLin_Stock({
    this.idArticulo,
    this.articulo,
    this.stock,
  });


  factory ArticulosLin_Stock.fromJson(Map<String, dynamic> json) => ArticulosLin_Stock(
    idArticulo: json["idArticulo"],
    articulo: json["articulo"],
    stock: json["stock"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "idArticulo": idArticulo,
    "articulo": articulo,
    "precio":stock,
  };
}

class Articulo_Colores_Tallas {
  String color;
  double stockColor;
  List<Articulo_Tallas> tallas;


  Articulo_Colores_Tallas({
    this.color,
    this.stockColor,
    this.tallas,
  });

  Articulo_Colores_Tallas.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    if (json['tallas'] != null) {
      List<Articulo_Tallas> tallas = [];
      json['tallas'].forEach((v) {
        tallas.add(new Articulo_Tallas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    if (this.tallas != null) {
      data['tallas'] =this.tallas.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Articulo_Tallas {
  String talla;
  double stockTalla;
  double precio;
  double precioCliente;
  double precioPromocion;
  int idArticulo;
  String articulo;

  Articulo_Tallas({
    this.talla,
    this.stockTalla,
    this.precio,
    this.precioCliente,
    this.precioPromocion,
    this.idArticulo,
    this.articulo,
  });

  factory Articulo_Tallas.fromJson(Map<String, dynamic> json) => Articulo_Tallas(
    talla: json["talla"],
  );

  Map<String, dynamic> toJson() => {
    "talla": talla,
  };
}

class Articulo_Alergenos {
  int id;
  int idArticulo;
  int idAlergeno;
  String alergeno;
  bool contiene;
  bool trazas;
  bool posiblesTrazas;

  Articulo_Alergenos({
    this.id,
    this.idArticulo,
    this.idAlergeno,
    this.alergeno,
    this.contiene,
    this.trazas,
    this.posiblesTrazas,
  });

  factory Articulo_Alergenos.fromJson(Map<String, dynamic> json) => Articulo_Alergenos(
    id: json["id"],
    idArticulo: json["idArticulo"],
    idAlergeno: json["idAlergeno"],
    alergeno: json["alergeno"],
    contiene: json["contiene"],
    trazas: json["trazas"],
    posiblesTrazas: json["posiblesTrazas"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idArticulo": idArticulo,
    "idAlergeno": idAlergeno,
    "alergeno": alergeno,
    "contiene": contiene,
    "trazas": trazas,
    "posiblesTrazas": posiblesTrazas,
  };
}

/* 1          Altramuces y productos a base de altramuces
  2          Apio y productos derivados
  3          Cacahuetes y productos a base de cacahuetes
  4          Cereales que contengan gluten
  5          Crustáceos y productos a base de crustáceos
  6          Dióxido de azufre y sulfitos
  7          Frutos de cáscara
  8          Granos de sésamo y productos a base de granos de sésamo
  9          Huevos y productos a base de huevo
  10        Leche y sus derivados
  11        Moluscos y productos a base de moluscos
  12        Mostaza y productos derivados
  13        Pescado y productos a base de pescado
  14        Soja y productos a base de soja*/