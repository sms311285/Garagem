import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garagem/models/modelo.dart';
import 'package:garagem/util/configuracoes.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:validadores/Validador.dart';

class AtualizarModelo extends StatefulWidget {
  final Modelo modelo; //PARAMETRO PARA PASSAR NA ROTA E PEGAR OS ANUNCIOS
  final String marca; // Adicione a marca como parâmetro
  const AtualizarModelo({
    //CONSTRUTOR PARA PEGAR OS DETALHES DO ANUNCIO
    Key? key,
    required this.modelo,
    required this.marca,
  }) : super(key: key);

  @override
  State<AtualizarModelo> createState() => AtualizarModeloState();
}

class AtualizarModeloState extends State<AtualizarModelo> {
  late Modelo _modelo; //CHAMMANDO OS ANUNCIOS DA CLASSE ANUNCIO
  late BuildContext _dialogContext; // dialog para mostrar que está salvando...
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _modeloController = TextEditingController();

  List<DropdownMenuItem<String>> _listaItensDropMarcas = [];
  String? _itemSelecionadoMarca;
  final TextEditingController _marcaController = TextEditingController();

  _carregarMarcaDropdown() async {
    //Marcas
    List<DropdownMenuItem<String>> marcas = await Configuracoes.getMarcas();
    setState(() {
      _listaItensDropMarcas = marcas;
    });
  }

  Future _atualizarModelo(String novaMarca) async {
    _abrirDialog(_dialogContext);
    String nomeModelo = _modeloController.text;
    //String nomeMarca = _marcaController.text;
    FirebaseFirestore db =
        FirebaseFirestore.instance; //RECUPERANDO A INSTANCIA DO BANCO

    Map<String, dynamic> dadosAtualizar = {
      // convertendo dados para map
      "nomeModelo": nomeModelo,
      "nomeMarca": novaMarca,
    };

    db.collection("modelos").doc(_modelo.id).update(dadosAtualizar).then((_) {
      Navigator.pop(_dialogContext); //mostrando a dialog salvando....
      Navigator.pop(context); //fechando a tela e mandando para meus anuncios
      _showAlertDialog(
        "Sucesso ao atualizar o modelo:",
        "O modelo foi atualizado com sucesso!",
      );
      //_showDialogSalvar();
    });
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

  // void _showDialogSalvar() {
  //   //dialog quando acabar de salvar
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         // retorna um objeto do tipo Dialog
  //         title: const Text("Modelo atualizado com sucesso!"),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             // define os botões na base do dialogo
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
    _modelo = widget.modelo;
    _modeloController.text = _modelo.nomeModelo;
    _carregarMarcaDropdown();
    //_itemSelecionadoMarca = _modelo.nomeMarca;
    _itemSelecionadoMarca = widget.marca; // Use a marca passada como parâmetro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Atualizar modelo")),
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
                        _marcaController.text = valor!; // Atualize o campo de texto da marca
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                    hint: "Modelo",
                    inputFormatters: const [],
                    controller: _modeloController,
                    // salvando titulo
                    onSaved: (modelo) {
                      _modelo.nomeModelo = modelo!;
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
                  texto: "Atualizar modelo",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      //Configura dialog context
                      _dialogContext = context;
                      // Atualize a marca com o valor selecionado                      
                      // Salvar anúncio com a nova marca
                      _atualizarModelo(_itemSelecionadoMarca!);
                      //_atualizarModelo();
                      //String novaMarca = _itemSelecionadoMarca ?? ""; // Use a marca selecionada
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
