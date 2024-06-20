import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garagem/main.dart';
import 'package:garagem/models/anuncio.dart';
import 'package:garagem/util/configuracoes.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  const NovoAnuncio({super.key});

  @override
  State<NovoAnuncio> createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final List<File> _listaImagens = [];
  List<DropdownMenuItem<String>> _listaItensDropMarcas = [];
  List<DropdownMenuItem<String>> _listaItensDropModelos = [];
  final _formKey = GlobalKey<FormState>();
  late Anuncio _anuncio;
  late BuildContext _dialogContext;

  String? _itemSelecionadoMarca;
  String? _itemSelecionadoModelo;

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  Future<void> _selecionarImagemGaleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);
    if (imagemSelecionada?.path != null) {
      setState(() {
        _listaImagens.add(File(imagemSelecionada!.path));
      });
    }
  }

  _abrirDialog(BuildContext context) {
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
                Text("Salvando anúncio...")
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

  Future _salvarAnuncio() async {
    _abrirDialog(_dialogContext);
    await _uploadImagens();
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser!;
    String idUsuarioLogado = usuarioLogado.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .doc(_anuncio.id)
        .set(_anuncio.toMap())
        .then((_) {
      //salvar anúncio público
      db.collection("anuncios").doc(_anuncio.id).set(_anuncio.toMap()).then((_) {
        Navigator.pop(_dialogContext);
        Navigator.pop(context);
        _showAlertDialog(
          "Sucesso ao cadastrar anúncio:",
          "O anúncio foi cadastrado com sucesso!",
        );
        //_showDialogSalvar();
      });
    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz.child("meus_anuncios").child(_anuncio.id).child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
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

  _carregarItensDropdown() async {
    // Marcas
    List<DropdownMenuItem<String>> marcas = await Configuracoes.getMarcas();
    if (marcas.isNotEmpty) {
      setState(() {
        _listaItensDropMarcas = marcas;
        _itemSelecionadoMarca = marcas.first.value; // Inicialize com a primeira marca da lista
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //área de imagens - //formfiled é um validador de campos
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
                              scrollDirection: Axis.horizontal,
                              //+1 para exibir icone add foto ultimo
                              itemCount: _listaImagens.length + 1,
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
                                                      Image.file(_listaImagens[indice]),
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
                                        backgroundImage: FileImage(_listaImagens[indice]),
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
                              } // item builder
                              ),
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
                //Menus Dropdown
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoMarca,
                          hint: const Text("Marcas"),
                          onSaved: (marca) {
                            _anuncio.marca = marca!;
                          },
                          style: const TextStyle(color: Colors.black, fontSize: 19),
                          items: _listaItensDropMarcas,
                          validator: (valor) {
                            return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                          },
                          onChanged: (valor) {
                            setState(() {
                              _itemSelecionadoMarca = valor!;
                              _carregarModelos(_itemSelecionadoMarca ?? '');
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoModelo,
                          hint: const Text("Modelos"),
                          onSaved: (modelo) {
                            _anuncio.modelo = modelo!;
                          },
                          style: const TextStyle(color: Colors.black, fontSize: 19),
                          items: _listaItensDropModelos,
                          validator: (valor) {
                            return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                          },
                          onChanged: (valor) {
                            setState(() {
                              _itemSelecionadoModelo = valor!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                //Caixas de textos e botoes
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Título",
                    onSaved: (titulo) {
                      _anuncio.titulo = titulo!;
                      return null;
                    },
                    inputFormatters: const [],
                    controller: _tituloController,
                    validator: (valor) {
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Ano",
                    onSaved: (ano) {
                      _anuncio.ano = ano!;
                      return null;
                    },
                    inputFormatters: const [],
                    controller: _anoController,
                    type: TextInputType.number,
                    validator: (valor) {
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Preço",
                    onSaved: (preco) {
                      _anuncio.preco = preco!;
                      return null;
                    },
                    controller: _precoController,
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
                    onSaved: (telefone) {
                      _anuncio.telefone = telefone!;
                      return null;
                    },
                    controller: _telefoneController,
                    type: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                    validator: (valor) {
                      return Validador().add(Validar.OBRIGATORIO, msg: "Campo obrigatório").valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    hint: "Descrição (200 caracteres)",
                    onSaved: (descricao) {
                      _anuncio.descricao = descricao!;
                      return null;
                    },
                    controller: _descricaoController,
                    type: TextInputType.multiline,
                    inputFormatters: const [],
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
                  texto: "Cadastrar Anúncio",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //salva campos
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      //salvar anuncio
                      _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
