import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes {
  static Future<List<DropdownMenuItem<String>>> getMarcas() async {
    List<DropdownMenuItem<String>> itensDropMarcas = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('marcas').get();

    itensDropMarcas.add(
      const DropdownMenuItem(
        value: null,
        child: Text(
          "Marcas",
          style: TextStyle(
            color: Color(0xff000080),
          ),
        ),
      ),
    );

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String marca = doc.get(
        'nomeMarca',
      );
      // Verifique se a marca já foi adicionada à lista antes de adicioná-la novamente
      if (!itensDropMarcas.any((item) => item.value == marca)) {
        itensDropMarcas.add(
          DropdownMenuItem(value: marca, child: Text(marca)),
        );
      }
      // itensDropMarcas.add(
      //   DropdownMenuItem(value: marca, child: Text(marca)),
      // );
    }
    return itensDropMarcas;
  }

  static Future<List<DropdownMenuItem<String>>> getModelos(String marcaSelecionada) async {
    List<DropdownMenuItem<String>> itensDropModelos = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('modelos')
        .where('nomeMarca', isEqualTo: marcaSelecionada) // Filtrar modelos pela marca selecionada
        .get();

    itensDropModelos.add(
      const DropdownMenuItem(
        value: null,
        child: Text(
          "Modelos",
          style: TextStyle(
            color: Color(0xff000080),
          ),
        ),
      ),
    );

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String modelo = doc.get('nomeModelo');
      // Verifique se o modelo já foi adicionado à lista antes de adicioná-lo novamente
      if (!itensDropModelos.any((item) => item.value == modelo)) {
        itensDropModelos.add(
          DropdownMenuItem(value: modelo, child: Text(modelo)),
        );
      }
      // itensDropModelos.add(
      //   DropdownMenuItem(value: modelo, child: Text(modelo)),
      // );
    }
    return itensDropModelos;
  }
}
