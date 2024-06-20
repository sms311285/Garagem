class Usuario {
  late String idUsuario;
  late String nome;
  late String email;
  late String senha;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": idUsuario,
      "nome": nome,
      "email": email
    };
    return map;
  }
}