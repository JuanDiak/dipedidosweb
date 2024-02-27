import 'DatabaseHelper.dart';
import 'Principal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Datos/Articulos.dart';
import 'Notificadores.dart';
import 'PedidoActual.dart';

DBHelper dbHelper = DBHelper();

class DataSearch extends SearchDelegate<String> {
  List<Articulos> ListaArticulos;
  String desde;
  DataSearch({this.ListaArticulos, this.desde});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final lista = query.isEmpty
        ? lista_articulos_WebS
        : ListaArticulos.where(
                (p) => p.articulo.toUpperCase().contains(query.toUpperCase()))
            .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () async {
          if (desde=='principal'){
            bool EnPromocion = (lista[index].precioPromocion != 0 && lista[index].precioPromocion < lista[index].precioCliente);
            await dbHelper.Insertar_en_Pedido(lista[index].idArticulo, lista[index].articulo, (EnPromocion) ? lista[index].precioPromocion : lista[index].precioCliente);
            await LoadlistLineasPedido();
            await LoadPedido();
            await GrabarCabeceraPedido();
            context.read<ChangePage>().setPage('Pedido');
            Navigator.pop(context, 'OK');
          }else if (desde =='fotos'){
            close (context, lista[index].idArticulo.toString());
          }
        },
        leading: Icon(Icons.add),
        //   title: Text(lista[index].articulo),
        title: ResaltarTexto(articulo: lista[index].articulo, query: query, ),
        subtitle: Text('Precio: ${NumberFormat.simpleCurrency().format(lista[index].precioCliente)}'),
      ),
      itemCount: lista.length,
    );
  }
}

class ResaltarTexto extends StatelessWidget {
  final String articulo;
  final String query;
  final TextStyle textStyle;
  final TextStyle textStyleHight;

  ResaltarTexto({
    @required this.articulo,
    @required this.query,
    this.textStyle= const TextStyle(color: Colors.black),
    this.textStyleHight= const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
   if (query.isEmpty){
     return Text(articulo,style: textStyle,);
   }else{
     String queryLC = query.toLowerCase();
     List<InlineSpan> children=[];
     List<String> spanList = articulo.toLowerCase().split(queryLC);
     int i=0;
     for (var v in spanList ){
       if (v.isNotEmpty){
         children.add(TextSpan(
           text: articulo.substring(i, i+v.length), style: textStyle));
         i+=v.length;
       }
      if (i < articulo.length){
        children.add(TextSpan(
            text: articulo.substring(i, i+query.length), style: textStyleHight));
        i+=query.length;
      }
     }
      return RichText(text: TextSpan(children: children) ,);
   }
  }
}
