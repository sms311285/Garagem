import 'package:cloud_firestore/cloud_firestore.dart';

class Marca {
  late String id;
  late String nomeMarca;

  Marca({required this.nomeMarca});
  
  Marca.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.id;
    nomeMarca = documentSnapshot["nomeMarca"];
  }

  Marca.gerarId(){
    CollectionReference marcas = FirebaseFirestore.instance.collection("marcas");
    id = marcas.doc().id;
  }


  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nomeMarca": nomeMarca,
    };
  }
}

