import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/marca.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';

class CadastroMarcas extends StatefulWidget {
  const CadastroMarcas({super.key});

  @override
  State<CadastroMarcas> createState() => _CadastroMarcasState();
}

class _CadastroMarcasState extends State<CadastroMarcas> {
  late Marca _marca;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marcaController = TextEditingController();
  late BuildContext _dialogContext;

  Future<void> _salvarMarca() async {
    _abrirDialog(_dialogContext);
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db.collection("marcas").doc(_marca.id).set(_marca.toMap()).then((_) {
      Navigator.pop(_dialogContext);
      Navigator.pop(context);
      _showAlertDialog(
        "Sucesso ao salvar marca:",
        "A marca foi salva com sucesso.",
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
                Text("Salvando marca...")
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
  //         title: const Text("Marca salva com sucesso!"),
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
    _marca = Marca(nomeMarca: '');
    _marca = Marca.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Marcas"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //Caixas de textos e botoes
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Marca",
                    onSaved: (marca) {
                      _marca.nomeMarca = marca!;
                      return null;
                    },
                    inputFormatters: const [],
                    controller: _marcaController,
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                BotaoCustomizado(
                  texto: "Cadastrar Marca",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      //salva campos
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      //salvar anuncio
                      _salvarMarca();
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
