import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/marca.dart';
import 'package:garagem/views/widgets/item_marca.dart';

class Marcas extends StatefulWidget {
  const Marcas({super.key});

  @override
  State<Marcas> createState() => _MarcasState();
}

class _MarcasState extends State<Marcas> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  Future<Stream<QuerySnapshot>> _adicionarListenerMarcas() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db.collection("marcas").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
    return stream; // Adicione este retorno no final da função
  }

  Future<void> _showAlertDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  _removerMarca(String idMarca, String nomeMarca) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // Verifique se existem modelos com a mesma nomeMarca
    QuerySnapshot modelsQuery = await db
        .collection("modelos")
        .where("nomeMarca", isEqualTo: nomeMarca)
        .get();

    if (modelsQuery.docs.isNotEmpty) {
      // Existem modelos vinculados a esta marca, não permita a exclusão
      setState(() {});

      await _showAlertDialog(
        "Erro ao remover a marca:",
        "A marca possui modelos vinculados e não pode ser excluída.",
      );
    } else {
      // Não existem modelos vinculados a esta marca, permita a exclusão
      await db.collection("marcas").doc(idMarca).delete();
      setState(() {});

      await _showAlertDialog(
        "Sucesso ao remover marca:",
        "A marca foi removida com sucesso!",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerMarcas();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = const Center(
      child: Column(
        children: <Widget>[
          Text("Carregando marcas"),
          CircularProgressIndicator()
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Marcas"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        onPressed: () {
          Navigator.pushNamed(context, "/cadastro-marcas");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        //FirebaseFirestore.instance.collection("marcas").snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return carregandoDados;
            //break;
            case ConnectionState.active:
            case ConnectionState.done:
              //Exibe mensagem de erro
              if (snapshot.hasError) {
                return const Text("Erro ao carregar os dados!");
              }
              QuerySnapshot<Object?>? querySnapshot =
                  snapshot.data!; //Primeira execução, recuperando os dados
              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice) {
                    List<DocumentSnapshot> marcas = querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = marcas[indice];
                    Marca marca = Marca.fromDocumentSnapshot(documentSnapshot);

                    return ItemMarca(
                      marca: marca,
                      onPressedRemover: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Confirmar:"),
                                content: const Text(
                                    "Deseja realmente excluir a marca?"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .blue, // Define a cor de fundo vermelha
                                    ),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .red, // Define a cor de fundo vermelha
                                    ),
                                    child: const Text(
                                      "Remover",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      _removerMarca(marca.id, marca.nomeMarca);
                                      Navigator.of(context).pop();
                                      //_showDialogRemover();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      //editar
                      onPressedEditar: () async {
                        //Navigator.pushNamed(context, "/atualizar-marca", arguments: marca);
                        //Verifique se existem anúncios com a marca atual antes de permitir a edição
                        FirebaseFirestore db = FirebaseFirestore.instance;
                        QuerySnapshot anunciosQuery = await db
                            .collection("modelos")
                            .where("nomeMarca", isEqualTo: marca.nomeMarca)
                            .get();

                        if (anunciosQuery.docs.isNotEmpty) {
                          // Existem anúncios associados a esta marca, exiba um alerta e bloqueie a edição
                          await _showAlertDialog(
                            "Não é possível editar a marca:",
                            "Existem modelos associados a esta marca e ela não pode ser editada, tente excluir o modelo vinculado e em seguida editar novamente.",
                          );
                        } else {
                          // Não existem anúncios associados a esta marca, navegue para a tela de edição
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, "/atualizar-marca",
                              arguments: marca);
                        }
                      },
                      //editar
                      // onPressedEditar: () {
                      //   Navigator.pushNamed(context, "/atualizar-marca",
                      //       arguments: marca);
                      // },
                    );
                  });
          }
          //return Container();
        },
      ),
    );
  }
}
