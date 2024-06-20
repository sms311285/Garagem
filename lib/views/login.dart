import 'package:flutter/material.dart';
import 'package:garagem/models/usuario.dart';
import 'package:garagem/views/widgets/botao_customizado.dart';
import 'package:garagem/views/widgets/input_customizado.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerEmail = TextEditingController(text: "samuel@gmail.com");
  final TextEditingController _controllerSenha = TextEditingController(text: "1234567");

  late bool _cadastrar = false;
  late String _mensagemErro = "";
  late String _textoBotao = "Entrar";

  _cadastrarUsuario(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.createUserWithEmailAndPassword(email: usuario.email, password: usuario.senha).then((firebaseUser) {
      //redireciona para tela principal
      //Navigator.pushReplacementNamed(context, "/");
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
    });
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: usuario.email, password: usuario.senha).then((firebaseUser) {
      //redireciona para tela principal
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
    });
  }

  _validarCampos() {
    //Recupera dados dos campos
    final String email = _controllerEmail.text;
    final String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        //Configura usuario
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        //cadastrar ou logar
        if (_cadastrar) {
          //Cadastrar
          _cadastrarUsuario(usuario);
        } else {
          //Logar
          _logarUsuario(usuario);
        }
      } else {
        setState(() {
          _mensagemErro = "Preencha a senha! digite mais de 6 caracteres";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o E-mail válido";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "asset/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "E-mail",
                  inputFormatters: const [],
                  autofocus: true,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 5,
                ),
                InputCustomizado(controller: _controllerSenha, hint: "Senha", inputFormatters: const [], obscure: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Logar"),
                    Switch(
                      value: _cadastrar,
                      onChanged: (bool valor) {
                        setState(() {
                          _cadastrar = valor;
                          _textoBotao = "Entrar";
                          if (_cadastrar) {
                            _textoBotao = "Cadastrar";
                          }
                        });
                      },
                    ),
                    const Text("Cadastrar"),
                  ],
                ),
                BotaoCustomizado(
                  texto: _textoBotao,
                  onPressed: () {
                    _validarCampos();
                  },
                ),
                TextButton(
                  child: const Text("Ir para anúncios -->"),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
