import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/anuncio.dart';
import 'package:garagem/views/widgets/item_anuncio.dart';
import 'package:logger/logger.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({super.key});

  @override
  State<MeusAnuncios> createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  late String _idUsuarioLogado;
  final logger = Logger();

  Future<void> _recuperaDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    await _recuperaDadosUsuarioLogado();
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
    return stream; // Adicione este retorno no final da função
  }

  _removerAnuncio(String idAnuncio, List<String> imagens) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    // Exclua as imagens do Firebase Storage
    for (String imageUrl in imagens) {
      await excluirImagemDoStorage(imageUrl);
    }

    db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .doc(idAnuncio)
        .delete()
        .then((_) {
      db.collection("anuncios").doc(idAnuncio).delete();
    });
  }

  Future<void> excluirImagemDoStorage(String imageUrl) async {
    try {
      // Criar uma referência para a imagem no Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      // Excluir a imagem
      await storageRef.delete();
      logger.i('Imagem excluída com sucessooooo.');
    } catch (e) {
      logger.i('Erro ao excluir imagem: $e');
    }
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

  // void _showDialogRemover() {
  //   //dialog quando remover
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // retorna um objeto do tipo Dialog
  //       return AlertDialog(
  //         title: const Text("Anúncio removido com sucesso!"),
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
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = const Center(
      child: Column(
        children: <Widget>[
          Text("Carregando anúncios"),
          CircularProgressIndicator()
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Anúncios"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"),
        onPressed: () {
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder(
        stream: _controller.stream,
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
                    List<DocumentSnapshot> anuncios =
                        querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio =
                        Anuncio.fromDocumentSnapshot(documentSnapshot);

                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Confirmar:"),
                                content: const Text(
                                    "Deseja realmente excluir o anúncio?"),
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
                                      _removerAnuncio(
                                          anuncio.id, anuncio.fotos);
                                      Navigator.of(context).pop();
                                      _showAlertDialog(
                                        "Sucesso ao remover o anúncio:",
                                        "O anúncio foi removido com sucesso!",
                                      );
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      //editar anuncio
                      onPressedEditar: () {
                        Navigator.pushNamed(context, "/atualizar-anuncio",
                            arguments: anuncio);
                      },
                    );
                  });
          }
          //return Container();
        },
      ),
    );
  }
}
