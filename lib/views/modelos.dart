import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/modelo.dart';
import 'package:garagem/views/widgets/item_modelo.dart';

class Modelos extends StatefulWidget {
  const Modelos({super.key});

  @override
  State<Modelos> createState() => _ModelosState();
}

class _ModelosState extends State<Modelos> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  Future<Stream<QuerySnapshot>> _adicionarListenerModelos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db.collection("modelos").snapshots();
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

  _removerModelo(String idModelo, String modelo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    // Verifique se existem anúncios associados a este modelo
    QuerySnapshot anunciosQuery = await db.collection("anuncios").where("modelo", isEqualTo: modelo).get();
    if (anunciosQuery.docs.isNotEmpty) {
      // Existem anúncios associados a este modelo, não permita a exclusão
      setState(() {});
      await _showAlertDialog(
        "Erro ao remover o modelo:",
        "Existem anúncios associados a este modelo e ele não pode ser excluído.",
      );
    } else {
      // Não existem anúncios associados a este modelo, permita a exclusão
      await db.collection("modelos").doc(idModelo).delete();
      setState(() {});
      await _showAlertDialog(
        "Sucesso ao remover modelo:",
        "O modelo foi removido com sucesso!",
      );
    }

    // db.collection("modelos").doc(idModelo).delete();
    // setState(() {}); // Atualize o StreamBuilder
  }

  // void _showDialogRemover() {
  //   //dialog quando remover
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // retorna um objeto do tipo Dialog
  //       return AlertDialog(
  //         title: const Text("Modelo removido com sucesso!"),
  //         actions: <Widget>[
  //           // define os botões na base do dialogo
  //           ElevatedButton(
  //             child: const Text("Fechar"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _adicionarListenerModelos();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = const Center(
      child: Column(
        children: <Widget>[Text("Carregando modelos"), CircularProgressIndicator()],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Modelos"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        onPressed: () {
          Navigator.pushNamed(context, "/cadastro-modelos");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        //FirebaseFirestore.instance.collection("modelos").snapshots(),
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
              QuerySnapshot<Object?>? querySnapshot = snapshot.data!; //Primeira execução, recuperando os dados
              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice) {
                    List<DocumentSnapshot> modelos = querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = modelos[indice];
                    Modelo modelo = Modelo.fromDocumentSnapshot(documentSnapshot);

                    return ItemModelo(
                      modelo: modelo,
                      onPressedRemover: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Confirmar:"),
                                content: const Text("Deseja realmente excluir o modelo?"),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue, // Define a cor de fundo vermelha
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
                                      backgroundColor: Colors.red, // Define a cor de fundo vermelha
                                    ),
                                    child: const Text(
                                      "Remover",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      _removerModelo(modelo.id, modelo.nomeModelo);
                                      Navigator.of(context).pop();
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
                        QuerySnapshot anunciosQuery =
                            await db.collection("anuncios").where("modelo", isEqualTo: modelo.nomeModelo).get();

                        if (anunciosQuery.docs.isNotEmpty) {
                          // Existem anúncios associados a esta marca, exiba um alerta e bloqueie a edição
                          await _showAlertDialog(
                            "Não é possível editar o modelo:",
                            "Existem anuncios associados a este modelo e ele não pode ser editada, tente excluir o anuncio vinculado e em seguida editar novamente.",
                          );
                        } else {
                          // Não existem anúncios associados a esta marca, navegue para a tela de edição
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(
                            // ignore: use_build_context_synchronously
                            context,
                            "/atualizar-modelo",
                            arguments: {
                              'modelo': modelo,
                              'marca': modelo
                                  .nomeMarca, // Substitua isso pelo campo correto do seu modelo que armazena a marca
                            },
                          );
                        }
                      },
                      // onPressedEditar: () {
                      //   Navigator.pushNamed(
                      //     context,
                      //     "/atualizar-modelo",
                      //     arguments: {
                      //       'modelo': modelo,
                      //       'marca': modelo.nomeMarca, // Substitua isso pelo campo correto do seu modelo que armazena a marca
                      //     },
                      //   );
                      // },
                      // //editar
                      // onPressedEditar: () {
                      //   Navigator.pushNamed(context, "/atualizar-modelo",
                      //       arguments: modelo);
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
