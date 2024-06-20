import 'package:flutter/material.dart';
import 'package:garagem/models/marca.dart';

class ItemMarca extends StatelessWidget {
  final Marca marca;
  final VoidCallback? onTapItem;
  final VoidCallback? onPressedRemover;
  final VoidCallback? onPressedEditar;

  const ItemMarca({
    Key? key,
    required this.marca,
    this.onTapItem,
    this.onPressedRemover,
    this.onPressedEditar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        marca.nomeMarca,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // editar
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Use style para definir o estilo do botão
                    backgroundColor: Colors.blue, // Define a cor de fundo
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: onPressedEditar,
                  child: const Icon(Icons.edit, color: Colors.white,),
                ),
              ),
              //ESPAÇAMENTO ENTRE OS DROPDOWN
              const SizedBox(
                width: 7,
                height: 90,
              ),
              //remover
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Use style para definir o estilo do botão
                    backgroundColor: Colors.red, // Define a cor de fundo
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: onPressedRemover,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
