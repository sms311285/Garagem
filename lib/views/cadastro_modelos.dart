import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/modelo.dart';
import 'package:garagem/util/configuracoes.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';

class CadastroModelos extends StatefulWidget {
  const CadastroModelos({super.key});

  @override
  State<CadastroModelos> createState() => _CadastroModelosState();
}

class _CadastroModelosState extends State<CadastroModelos> {
  late Modelo _modelo;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modeloController = TextEditingController();
  late BuildContext _dialogContext;

  List<DropdownMenuItem<String>> _listaItensDropMarcas = [];
  String? _itemSelecionadoMarca;

  _carregarMarcaDropdown() async {
    //Marcas
    List<DropdownMenuItem<String>> marcas = await Configuracoes.getMarcas();
    setState(() {
      _listaItensDropMarcas = marcas;
    });
  }

  Future<void> _salvarModelo() async {
    if (_itemSelecionadoMarca != null) {
      _modelo.nomeMarca = _itemSelecionadoMarca!;
    }
    _abrirDialog(_dialogContext);
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
    .collection("modelos")
    .doc(_modelo.id)
    .set(_modelo.toMap())
    .then((_) {
      Navigator.pop(_dialogContext);
      Navigator.pop(context);
      _showAlertDialog(
        "Sucesso ao salvar modelo:",
        "O modelo foi salvo com sucesso.",
      );
    });
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
                Text("Salvando modelo...")
              ],
            ),
          );
        });
  }

  // void _showDialogSalvar() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // retorna um objeto do tipo Dialog
  //       return AlertDialog(
  //         title: const Text("Modelo salvo com sucesso!"),
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

  @override
  void initState() {
    super.initState();
    _carregarMarcaDropdown();
    _modelo = Modelo(nomeModelo: '', nomeMarca: '');
    _modelo = Modelo.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Modelos"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButtonFormField(
                    value: _itemSelecionadoMarca,
                    hint: const Text("Marcas"),
                    onSaved: (marca) {
                      _itemSelecionadoMarca = marca!;
                    },
                    style: const TextStyle(color: Colors.black, fontSize: 19),
                    items: _listaItensDropMarcas,
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                    onChanged: (valor) {
                      setState(() {
                        _itemSelecionadoMarca = valor;
                      });
                    },
                  ),
                ),
                //Caixas de textos e botoes
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Modelo",
                    onSaved: (modelo) {
                      _modelo.nomeModelo = modelo!;
                      return null;
                    },
                    inputFormatters: const [],
                    controller: _modeloController,
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                BotaoCustomizado(
                  texto: "Cadastrar Modelo",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //salva campos
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      //salvar anuncio
                      _salvarModelo();
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
