import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'Principal.dart';
import 'Notificadores.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  bool _loggedIn = false;
  @override
  build( context) {
    return ChangeNotifierProvider<ChangePage>(
      create: (_)=>ChangePage(page:'Articulos'),
      child: MaterialApp(
          localizationsDelegates: [
             GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('es', 'ES'),
            Locale('en', 'US'), // English
            Locale('es', 'MX'), // Mexico
            Locale('en', 'GB'), // Reino Unido
            Locale('en', 'GI'), // Gibraltar
          ],
          title: 'dkPedidos',
          debugShowCheckedModeBanner: false,
          theme: new ThemeData(
            //primarySwatch: Colors.blue,
            primaryColor: Colors.blue[700],
          ),
          routes: {
            '/': (BuildContext context) {
              if (_loggedIn) {
                return Principal();
              } else {
                //return WidgetTiendasRecogida(); //LoginPage();
                return LoginPage(); //LoginPage();
              }
            }
          },
          //home: ListaPrincipal(),
        ),
    );
  }

}



