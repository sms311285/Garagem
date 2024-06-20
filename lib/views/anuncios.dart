import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:garagem/main.dart';
import 'package:garagem/models/anuncio.dart';
import 'package:garagem/util/configuracoes.dart';
import 'package:garagem/views/widgets/item_anuncio.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _listaItensDropMarcas = [];
  List<DropdownMenuItem<String>> _listaItensDropModelos = [];

  final _controler = StreamController<QuerySnapshot>.broadcast();

  String? _itemSelecionadoMarca;
  String? _itemSelecionadoModelo;

  void resetDropdowns() {
    setState(() {
      _itemSelecionadoMarca = null;
      _itemSelecionadoModelo = null;
      _listaItensDropModelos = [];
      _adicionarListenerAnuncios();
    });
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Meus anúncios":
        Navigator.pushNamed(context, "/meus-anuncios");
        //resetDropdowns(); // Chame o método resetDropdowns na tela de Anuncios
        break;
      case "Marcas":
        Navigator.pushNamed(context, "/marcas");
        //resetDropdowns();
        break;
      case "Modelos":
        Navigator.pushNamed(context, "/modelos");
        //resetDropdowns();
        break;
      case "Entrar / Cadastrar":
        Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
    resetDropdowns();
  }

  Future _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //final currentContext = context; // Captura o contexto antes de entrar na função assíncrona
    await auth.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado == null) {
      itensMenu = ["Entrar / Cadastrar"];
    } else {
      itensMenu = ["Meus anúncios", "Marcas", "Modelos", "Sair"];
    }
  }

  _carregarItensDropdown() async {
    //Marcas
    List<DropdownMenuItem<String>> marcas = await Configuracoes.getMarcas();
    setState(() {
      _listaItensDropMarcas = marcas;
    });
    //Modelos
    // List<DropdownMenuItem<String>> modelos = await Configuracoes.getModelos(_itemSelecionadoMarca!);
    // setState(() {
    //   _listaItensDropModelos = modelos;
    // });
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
    return stream; // Adicione este retorno no final da função
  }

  // Dentro do método _filtrarAnuncios
  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Query query = db.collection("anuncios");

    if (_itemSelecionadoMarca != null) {
      query = query.where("marca", isEqualTo: _itemSelecionadoMarca);
    }

    if (_itemSelecionadoModelo != null) {
      query = query.where("modelo", isEqualTo: _itemSelecionadoModelo);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
    return stream;
  }

  Future<void> _carregarModelos(String marcaSelecionada) async {
    if (marcaSelecionada.isNotEmpty) {
      List<DropdownMenuItem<String>> modelos = await Configuracoes.getModelos(marcaSelecionada);
      if (modelos.isNotEmpty) {
        setState(() {
          _listaItensDropModelos = modelos;
          _itemSelecionadoModelo = modelos.first.value; // Inicialize com o primeiro modelo da lista
        });
      } else {
        setState(() {
          _listaItensDropModelos = [
            const DropdownMenuItem(
              value: null,
              child: Text(
                "Nenhum modelo disponível",
                style: TextStyle(
                  color: Color(0xff000080),
                ),
              ),
            ),
          ];
          _itemSelecionadoModelo = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _verificarUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = const Center(
      child: Column(
        children: <Widget>[Text("Carregando anúncios"), CircularProgressIndicator()],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Garagem"),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            // Construir itens
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: SizedBox(
        child: Column(
          children: <Widget>[
            //Filtros
            Row(
              children: <Widget>[
                Expanded(
                  //Marcas
                  child: DropdownButtonHideUnderline(
                      child: Center(
                    child: DropdownButton(
                      iconEnabledColor: temaPadrao.primaryColor,
                      value: _itemSelecionadoMarca,
                      items: _listaItensDropMarcas,
                      style: const TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (marca) {
                        setState(() {
                          _itemSelecionadoMarca = marca;
                          _carregarModelos(_itemSelecionadoMarca ?? '');
                          _filtrarAnuncios();
                        });
                      },
                    ),
                  )),
                ),
                Container(
                  // Espaçamento
                  color: Colors.grey[200],
                  width: 2,
                  height: 60,
                ),
                Expanded(
                  //Modelos
                  child: DropdownButtonHideUnderline(
                      child: Center(
                    child: DropdownButton(
                      iconEnabledColor: temaPadrao.primaryColor,
                      value: _itemSelecionadoModelo,
                      items: _listaItensDropModelos,
                      style: const TextStyle(fontSize: 22, color: Colors.black),
                      onChanged: (modelo) {
                        setState(() {
                          _itemSelecionadoModelo = modelo;
                          _filtrarAnuncios();
                        });
                      },
                    ),
                  )),
                )
              ],
            ),
            //Listagem de anúncios
            StreamBuilder(
              stream: _controler.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    //QuerySnapshot<Object?>? querySnapshot = snapshot.data!; //Primeira execução, recuperando os dados
                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(25),
                        child: const Text(
                          "Nenhum anúncio! :( ",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    QuerySnapshot<Object?>? querySnapshot = snapshot.data!; //Primeira execução, recuperando os dados
                    return Expanded(
                      child: ListView.builder(
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (_, indice) {
                            List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                            DocumentSnapshot documentSnapshot = anuncios[indice];
                            Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                            return ItemAnuncio(
                              anuncio: anuncio,
                              onTapItem: () {
                                Navigator.pushNamed(context, "/detalhes-anuncio", arguments: anuncio);
                              },
                            );
                          }),
                    );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
