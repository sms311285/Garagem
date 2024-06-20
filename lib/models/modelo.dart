import 'package:cloud_firestore/cloud_firestore.dart';

class Modelo {
  late String id;
  late String nomeModelo;
  late String nomeMarca;

  Modelo({required this.nomeModelo, required this.nomeMarca});
  
  Modelo.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot.id;
    nomeModelo = documentSnapshot["nomeModelo"];
    nomeMarca = documentSnapshot["nomeMarca"];
  }

  Modelo.gerarId(){
    CollectionReference modelos = FirebaseFirestore.instance.collection("modelos");
    id = modelos.doc().id;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nomeModelo": nomeModelo,
      "nomeMarca": nomeMarca,
    };
  }
}

