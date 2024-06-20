import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {
  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  const BotaoCustomizado({
    Key? key,
    required this.texto,
    this.corTexto = Colors.white,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xff000080), // Defina a cor de fundo aqui
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: corTexto, // Use a corTexto para a cor do texto
          fontSize: 20,
        ),
      ),
    );
  }
}
