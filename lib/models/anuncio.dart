import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio{

  late String id;
  late String marca;
  late String modelo;
  late String titulo;
  late String ano;
  late String preco;
  late String telefone;
  late String descricao;
  late List<String> fotos;

  Anuncio();

  Anuncio.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){    
    id = documentSnapshot.id;
    marca = documentSnapshot["marca"];
    modelo = documentSnapshot["modelo"];
    titulo     = documentSnapshot["titulo"];
    ano     = documentSnapshot["ano"];
    preco      = documentSnapshot["preco"];
    telefone   = documentSnapshot["telefone"];
    descricao  = documentSnapshot["descricao"];
    fotos  = List<String>.from(documentSnapshot["fotos"]);    
  }

  Anuncio.gerarId(){
    CollectionReference anuncios = FirebaseFirestore.instance.collection("meus_anuncios");
    id = anuncios.doc().id;  
    fotos = [];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id" : id,
      "marca" : marca,
      "modelo" : modelo,
      "titulo" : titulo,
      "ano" : ano,
      "preco" : preco,
      "telefone" : telefone,
      "descricao" : descricao,
      "fotos" : fotos,
    };
    return map;
  }
}