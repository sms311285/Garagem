import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garagem/main.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:garagem/models/anuncio.dart';
import 'package:logger/logger.dart';

class AtualizarAnuncio extends StatefulWidget {
  final Anuncio anuncio; //PARAMETRO PARA PASSAR NA ROTA E PEGAR OS ANUNCIOS
  const AtualizarAnuncio(
      { //CONSTRUTOR PARA PEGAR OS DETALHES DO ANUNCIO
      Key? key,
      required this.anuncio})
      : super(key: key);

  @override
  State<AtualizarAnuncio> createState() => _AtualizarAnuncioState();
}

class _AtualizarAnuncioState extends State<AtualizarAnuncio> {
  late Anuncio _anuncio; //CHAMMANDO OS ANUNCIOS DA CLASSE ANUNCIO
  late BuildContext _dialogContext; // dialog para mostrar que está salvando...

  List<String> _listaImagens = [];
  final List<String> _imagensAntigas = [];
  final List<String> _listaUrls = [];
  // List<DropdownMenuItem<String>> _listaItensDropMarcas = [];
  // List<DropdownMenuItem<String>> _listaItensDropModelos = [];
  final _formKey = GlobalKey<FormState>();

  String? _itemSelecionadoMarca;
  String? _itemSelecionadoModelo;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final logger = Logger();

  Future<void> _selecionarImagemGaleria() async {
    ImagePicker picker = ImagePicker();
    final imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);
    if (imagemSelecionada?.path != null) {
      setState(() {
        _listaImagens.add(imagemSelecionada!.path);
        _listaUrls.add(imagemSelecionada.path);
      });
    }
  }

  Future _atualizarAnuncio() async {
    _abrirDialog(_dialogContext);
    List<String> novasUrls = await _uploadNovasImagens();

    String titulo = _tituloController.text;
    String ano = _anoController.text;
    String preco = _precoController.text;
    String telefone = _telefoneController.text;
    String descricao = _descricaoController.text;
    String? marca = _itemSelecionadoMarca;
    String? modelo = _itemSelecionadoModelo;

    FirebaseAuth auth = FirebaseAuth.instance; //recuperando user logado
    User usuarioLogado = auth.currentUser!;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance; //RECUPERANDO A INSTANCIA DO BANCO

    Map<String, dynamic> dadosAtualizar = {
      // convertendo dados para map
      "titulo": titulo,
      "ano": ano,
      "preco": preco,
      "telefone": telefone,
      "descricao": descricao,
      "marca": marca,
      "modelo": modelo,
      "fotos": novasUrls
    };

    db // setando a img no bd
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .doc(_anuncio.id) //dentro do objeto anuncio já constam as imagens
        .update(dadosAtualizar)
        .then((_) {
      db //salvar anúncio público
          .collection("anuncios")
          .doc(_anuncio.id)
          .update(dadosAtualizar)
          .then((_) {
        Navigator.pop(_dialogContext); //mostrando a dialog salvando....
        Navigator.pop(context); //fechando a tela e mandando para meus anuncios
        _showAlertDialog(
          "Sucesso ao atualizar anúncio:",
          "O anúncio foi atualizado com sucesso!",
        );
      });
    });
  }

  Future<List<String>> _uploadNovasImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    List<String> novasUrls = [];

    for (var imagemPath in _listaImagens) {
      if (imagemPath.startsWith('https://firebasestorage.googleapis.com')) {
        // Tratar imagem da galeria (URL)
        novasUrls.add(imagemPath); // Não precisa fazer upload novamente
      } else {
        String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
        Reference arquivo = pastaRaiz.child("meus_anuncios").child(_anuncio.id).child(nomeImagem);

        UploadTask uploadTask = arquivo.putFile(File(imagemPath));
        TaskSnapshot taskSnapshot = await uploadTask;

        String url = await taskSnapshot.ref.getDownloadURL();
        novasUrls.add(url);
      }
    }
    return novasUrls;
  }

  Future<void> excluirImagemDoStorage(String imageUrl) async {
    try {
      // Criar uma referência para a imagem no Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      // Excluir a imagem
      await storageRef.delete();
      logger.i('Imagem excluída com sucesso.');
    } catch (e) {
      logger.i('Erro ao excluir imagem: $e');
    }
  }

  _abrirDialog(BuildContext context) {
    // dialog mostrar salvando ...
    showDialog(
        context: context,
        barrierDismissible: false, //Bloqueio de tela
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Atualizando anúncio...")
              ],
            ),
          );
        });
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

  // _carregarItensDropdown() async {
  //   //Marcas
  //   List<DropdownMenuItem<String>> marcas = await Configuracoes.getMarcas();
  //   setState(() {
  //     _listaItensDropMarcas = marcas;
  //   });
  //   //Modelos
  //   List<DropdownMenuItem<String>> modelos =
  //       await Configuracoes.getModelos(_itemSelecionadoMarca!);
  //   setState(() {
  //     _listaItensDropModelos = modelos;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    _anuncio = widget.anuncio;
    _tituloController.text = _anuncio.titulo;
    _anoController.text = _anuncio.ano;
    _precoController.text = _anuncio.preco;
    _telefoneController.text = _anuncio.telefone;
    _descricaoController.text = _anuncio.descricao;
    _listaImagens = _anuncio.fotos;
    // Carregar marcas e modelos no initState
    //_carregarItensDropdown();
    // Defina o valor inicial do modelo
    _itemSelecionadoModelo = _anuncio.modelo;
    _imagensAntigas.addAll(_listaImagens);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      // Intercepta a ação de pressionar o botão "Voltar" no dispositivo
      onWillPop: () async {
        // Verifique se o usuário fez alterações nas imagens
        bool imagensAlteradas = !const ListEquality().equals(_listaImagens, _imagensAntigas);
        if (imagensAlteradas) {
          bool confirmacao = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Atenção, alterações nas imagens!"),
              content: const Text("Houve alterações nas imagens. Necessário atualizar anúncio para voltar!"),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Não confirma a saída
                  },
                  child: const Text("Continuar editando"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      //salvar anuncio
                      _atualizarAnuncio();
                    }
                    Navigator.of(context).pop(true); // Confirma a saída
                  },
                  child: const Text("Atualizar e voltar"),
                ),
              ],
            ),
          );
          // Se o usuário confirmou a saída sem salvar, volte
          if (!confirmacao) {
            return false;
          }
        }
        // Se não houver imagens não salvas, permita a saída
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Atualizar anúncio"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FormField<List>(
                    initialValue: _listaImagens,
                    validator: (imagens) {
                      if (imagens!.isEmpty) {
                        return "Necessário selecionar uma imagem!";
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                                // construindo o listview lista de img
                                scrollDirection: Axis.horizontal,
                                itemCount: _listaImagens.length + 1, //3
                                itemBuilder: (context, indice) {
                                  if (indice == _listaImagens.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          _selecionarImagemGaleria();
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey[400],
                                          radius: 50,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.add_a_photo,
                                                size: 40,
                                                color: Colors.grey[100],
                                              ),
                                              Text(
                                                "Adicionar",
                                                style: TextStyle(color: Colors.grey[100]),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  if (_listaImagens.isNotEmpty) {
                                    // testando caso tiver imagens para exibir e conseguir excluir
                                    // Testando a exibição das imagens no avatar e ao excluir
                                    String imageUrl = _listaImagens[indice];
                                    bool isFirebaseImage =
                                        imageUrl.startsWith('https://firebasestorage.googleapis.com');
                                    ImageProvider<Object>? imageProvider;
                                    if (isFirebaseImage) {
                                      imageProvider = NetworkImage(imageUrl); // Imagem do Firebase
                                    } else {
                                      imageProvider = FileImage(File(imageUrl)); // Imagem da galeria local
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        if (imageUrl
                                                            .startsWith('https://firebasestorage.googleapis.com'))
                                                          Image.network(imageUrl)
                                                        else
                                                          Image.file(File(imageUrl)),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  Navigator.of(context).pop();
                                                                });
                                                              },
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: temaPadrao.primaryColor,
                                                                backgroundColor: Colors.transparent,
                                                              ),
                                                              child: const Text("Cancelar"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _listaImagens.removeAt(indice);
                                                                  if (isFirebaseImage) {
                                                                    excluirImagemDoStorage(imageUrl);
                                                                  }
                                                                  Navigator.of(context).pop();
                                                                });
                                                              },
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.red,
                                                                backgroundColor: Colors.transparent,
                                                              ),
                                                              child: const Text("Excluir"),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                        },
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage: imageProvider,
                                          child: Container(
                                            color: const Color.fromRGBO(255, 255, 255, 0.4),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                }),
                          ),
                          if (state.hasError)
                            Text(
                              "[${state.errorText}]",
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('marcas').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              List<DropdownMenuItem<String>> marcas = [];
                              marcas.add(DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "Marcas",
                                  style: TextStyle(color: temaPadrao.primaryColor),
                                ),
                              ));

                              for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
                                String marca = doc.get('nomeMarca');
                                marcas.add(DropdownMenuItem(value: marca, child: Text(marca)));
                              }

                              return DropdownButtonFormField(
                                value: _anuncio.marca,
                                hint: const Text("Marcas"),
                                onChanged: (valor) {
                                  setState(() {
                                    _itemSelecionadoMarca = valor;
                                    _itemSelecionadoModelo = null;
                                  });
                                },
                                onSaved: (marca) {
                                  _itemSelecionadoMarca = marca;
                                },
                                style: const TextStyle(color: Colors.black, fontSize: 19),
                                items: marcas,
                                // ... (resto do código do DropdownButtonFormField)
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('modelos')
                                .where('nomeMarca', isEqualTo: _itemSelecionadoMarca)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              List<DropdownMenuItem<String>> modelos = [];
                              modelos.add(DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "Modelos",
                                  style: TextStyle(color: temaPadrao.primaryColor),
                                ),
                              ));

                              for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
                                String modelo = doc.get('nomeModelo');
                                modelos.add(DropdownMenuItem(value: modelo, child: Text(modelo)));
                              }

                              return DropdownButtonFormField(
                                value: _itemSelecionadoModelo,
                                hint: const Text("Modelos"),
                                onChanged: (valor) {
                                  setState(() {
                                    _itemSelecionadoModelo = valor;
                                  });
                                },
                                onSaved: (modelo) {
                                  _itemSelecionadoModelo = modelo;
                                },
                                style: const TextStyle(color: Colors.black, fontSize: 19),
                                items: modelos,
                                validator: (valor) {
                                  return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 15),
                    child: InputCustomizado(
                      hint: "Título",
                      inputFormatters: const [],
                      controller: _tituloController,
                      // salvando titulo
                      onSaved: (titulo) {
                        _anuncio.titulo = titulo!;
                        return null;
                      },
                      validator: (valor) {
                        return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15, top: 15),
                    child: InputCustomizado(
                      hint: "Ano",
                      inputFormatters: const [],
                      controller: _anoController,
                      onSaved: (ano) {
                        _anuncio.ano = ano!;
                        return null;
                      },
                      validator: (valor) {
                        return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      hint: "Preço",
                      controller: _precoController,
                      onSaved: (preco) {
                        _anuncio.preco = preco!;
                        return null;
                      },
                      type: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                      validator: (valor) {
                        return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      hint: "Telefone",
                      controller: _telefoneController,
                      onSaved: (telefone) {
                        _anuncio.telefone = telefone!;
                        return null;
                      },
                      type: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter() // Dependencia brasil_fields
                      ],
                      validator: (valor) {
                        return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: InputCustomizado(
                      hint: "Descrição (500 caracteres)",
                      controller: _descricaoController,
                      type: TextInputType.multiline,
                      inputFormatters: const [],
                      onSaved: (descricao) {
                        _anuncio.descricao = descricao!;
                        return null;
                      },
                      maxLines: null,
                      validator: (valor) {
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .maxLength(1000, msg: "Máximo de 1000 caracteres")
                            .valido(valor);
                      },
                    ),
                  ),
                  BotaoCustomizado(
                    texto: "Atualizar anúncio",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState?.save();
                        //Configura dialog context
                        _dialogContext = context;
                        //salvar anuncio
                        _atualizarAnuncio();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
