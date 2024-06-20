import 'package:flutter/material.dart';
import 'package:garagem/models/anuncio.dart';

class ItemAnuncio extends StatelessWidget {

  final Anuncio anuncio;
  final VoidCallback? onTapItem;
  final VoidCallback? onPressedRemover;
  final VoidCallback? onPressedEditar;

  const ItemAnuncio({
    Key? key,
    required this.anuncio,
    this.onTapItem,
    this.onPressedRemover,
    this.onPressedEditar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapItem,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: <Widget>[
            //Imagem
            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(anuncio.fotos[0],
                fit: BoxFit.cover,
              ),
            ),
            //Titulo e Preço
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Text( 
                    anuncio.marca,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text( 
                    anuncio.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text( 
                    anuncio.ano,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(" ${anuncio.preco} "),
                ],),
              ),
            ),
            //botao editar 
            if( onPressedEditar != null )Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom( // Use style para definir o estilo do botão
                  backgroundColor: Colors.blue, // Define a cor de fundo
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: onPressedEditar,  
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
            //ESPAÇAMENTO ENTRE OS DROPDOWN
            const SizedBox(
              width: 7,
              height: 90,
            ),
            //botao remover 
            if( onPressedRemover != null )Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom( // Use style para definir o estilo do botão
                  backgroundColor: Colors.red, // Define a cor de fundo
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: onPressedRemover,  
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
          ],),
        ),
      ),
    );
  }
}