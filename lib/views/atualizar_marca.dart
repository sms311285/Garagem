import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/marca.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';

class AtualizarMarca extends StatefulWidget {
  final Marca marca; //PARAMETRO PARA PASSAR NA ROTA E PEGAR OS ANUNCIOS
  const AtualizarMarca(
      { //CONSTRUTOR PARA PEGAR OS DETALHES DO ANUNCIO
      Key? key,
      required this.marca})
      : super(key: key);

  @override
  State<AtualizarMarca> createState() => _AtualizarMarcaState();
}

class _AtualizarMarcaState extends State<AtualizarMarca> {
  late Marca _marca; //CHAMMANDO OS ANUNCIOS DA CLASSE ANUNCIO
  late BuildContext _dialogContext; // dialog para mostrar que está salvando...
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marcaController = TextEditingController();

  Future _atualizarMarca() async {
    _abrirDialog(_dialogContext);
    String nomeMarca = _marcaController.text;
    FirebaseFirestore db =
        FirebaseFirestore.instance; //RECUPERANDO A INSTANCIA DO BANCO

    Map<String, dynamic> dadosAtualizar = {
      // convertendo dados para map
      "nomeMarca": nomeMarca
    };

    db // setando a img no bd
      .collection("marcas")
      .doc(_marca.id)
      .update(dadosAtualizar)
      .then((_) {
        Navigator.pop(_dialogContext); //mostrando a dialog salvando....
        Navigator.pop(context); //fechando a tela e mandando para meus anuncios
        _showAlertDialog(
          "Sucesso ao atualizar a marca:",
          "A marca foi atualizada com sucesso.",
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

  @override
  void initState() {
    super.initState();
    _marca = widget.marca;
    _marcaController.text = _marca.nomeMarca;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atualizar marca")),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Marca",
                    inputFormatters: const [],
                    controller: _marcaController,
                    // salvando titulo
                    onSaved: (marca) {
                      _marca.nomeMarca = marca!;
                      return null;
                    },
                    validator: (valor) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),
                BotaoCustomizado(
                  texto: "Atualizar marca",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      //salvar anuncio
                      _atualizarMarca();
                      //_atualizarMarca();
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
