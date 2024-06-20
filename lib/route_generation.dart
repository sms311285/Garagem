import 'package:flutter/material.dart';
import 'package:garagem/models/marca.dart';
import 'package:garagem/models/modelo.dart';
import 'package:garagem/views/atualizar_marca.dart';
import 'package:garagem/views/atualizar_modelo.dart';
import 'package:garagem/views/cadastro_marcas.dart';
import 'package:garagem/views/cadastro_modelos.dart';
import 'package:garagem/views/detalhes_anuncio.dart';
import 'package:garagem/views/marcas.dart';
import 'package:garagem/views/meus_anuncios.dart';
import 'package:garagem/views/anuncios.dart';
import 'package:garagem/views/atualizar_anuncio.dart';
import 'package:garagem/views/login.dart';
import 'package:garagem/views/modelos.dart';
import 'package:garagem/views/novo_anuncio.dart';
import 'package:garagem/models/anuncio.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const Anuncios());
      case "/login":
        return MaterialPageRoute(builder: (_) => const Login());
      case "/meus-anuncios":
        return MaterialPageRoute(builder: (_) => const MeusAnuncios());
      case "/novo-anuncio":
        return MaterialPageRoute(builder: (_) => const NovoAnuncio());
      case "/marcas":
        return MaterialPageRoute(builder: (_) => const Marcas());       
      case "/cadastro-marcas":
        return MaterialPageRoute(builder: (_) => const CadastroMarcas()); 
      case "/modelos":
        return MaterialPageRoute(builder: (_) => const Modelos());    
      case "/cadastro-modelos":
        return MaterialPageRoute(builder: (_) => const CadastroModelos());   
      case "/detalhes-anuncio":
        if (arguments is Anuncio) {
          return MaterialPageRoute(builder: (_) => DetalhesAnuncio(anuncio: arguments));
        } else {
          return _erroRota();
        }
      case "/atualizar-marca":
        if (arguments is Marca) {
          return MaterialPageRoute(builder: (_) => AtualizarMarca(marca: arguments));
        } else {
          return _erroRota();
        }  
      case "/atualizar-modelo":
        if (arguments is Map<String, dynamic>) {
          final modelo = arguments['modelo'] as Modelo;
          final marca = arguments['marca'] as String; // Supondo que você tenha a marca como uma String
          return MaterialPageRoute(builder: (_) => AtualizarModelo(modelo: modelo, marca: marca));
        } else {
          return _erroRota();
        }    
      // case "/atualizar-modelo":
      //   if (arguments is Modelo) {
      //     return MaterialPageRoute(builder: (_) => AtualizarModelo(modelo: arguments));
      //   } else {
      //     return _erroRota();
      //   }  
      case "/atualizar-anuncio":
        if (arguments is Anuncio) {
          return MaterialPageRoute(builder: (_) => AtualizarAnuncio(anuncio: arguments));
        } else {
          return _erroRota();
        }
      default:
        return _erroRota(); // Adicione um retorno aqui
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tela não encontrada!"),
        ),
        body: const Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }
}
