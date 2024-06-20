import 'package:flutter/material.dart';
import 'package:garagem/main.dart';
import 'package:garagem/models/anuncio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:url_launcher/url_launcher_string.dart';

class DetalhesAnuncio extends StatefulWidget {
  final Anuncio anuncio; //PARAMETRO PARA PASSAR NA ROTA E PEGAR OS ANUNCIOS
  const DetalhesAnuncio(
      { //CONSTRUTOR PARA PEGAR OS DETALHES DO ANUNCIO
      Key? key,
      required this.anuncio})
      : super(key: key);

  @override
  State<DetalhesAnuncio> createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {
  late Anuncio _anuncio;
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  final CarouselController _dialogCarouselController = CarouselController(); // Mova a criação para fora da função
  final logger = Logger();

  void _mostrarImagemAmpliada(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        int initialIndex = _anuncio.fotos.indexOf(imageUrl);
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CarouselSlider(
                items: _getListaImagensDialog(),
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  initialPage: initialIndex,
                  autoPlay: false, // Não reproduza automaticamente no diálogo
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                carouselController: _dialogCarouselController,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: temaPadrao.primaryColor,
                  backgroundColor: Colors.transparent,
                ),
                child: const Text("Fechar"),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getListaImagensDialog() {
    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url) {
      return Stack(
        children: [
          Image.network(
            url,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: temaPadrao.primaryColor,
                  onPressed: () {
                    _dialogCarouselController.previousPage();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: temaPadrao.primaryColor,
                  onPressed: () {
                    _dialogCarouselController.nextPage();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _getListaImagens() {
    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url) {
      return Stack(
        children: [
          Image.network(
            url,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                _mostrarImagemAmpliada(url);
              },
              child: Icon(
                Icons.zoom_in,
                color: temaPadrao.primaryColor,
                size: 40,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Future<void> _enviarMensagemWhatsApp(String telefone) async {
    final mensagem = "Olá, tenho interesse no anúncio: ${'😃'.characters}\n"
        "${'🏷'.characters} ${_anuncio.titulo}\n"
        "${'📋'.characters} Descrição: \n ${_anuncio.descricao}\n"
        "${'💰'.characters} ${_anuncio.preco}";
    final numeroTelefone = telefone.replaceAll(RegExp(r'[^\d]'), '');

    final whatsappUrl = Uri.parse("https://wa.me/$numeroTelefone/?text=${Uri.encodeComponent(mensagem)}");

    if (!await launchUrl(whatsappUrl)) {
      throw Exception('Não foi possível abrir o WhatsApp $whatsappUrl');
    }
  }

  @override
  void initState() {
    super.initState();
    _anuncio = widget.anuncio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes"),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              SizedBox(
                height: 250,
                //Imagens
                child: CarouselSlider(
                  items: _getListaImagens(),
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    height: 200,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  carouselController: _carouselController,
                ),
              ),
              const SizedBox(
                width: 2,
                height: 2,
              ),
              // botões controladores do carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getListaImagens().asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _carouselController.animateToPage(entry.key);
                    },
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? temaPadrao.primaryColor // Cor ativa
                            : Colors.grey, // Cor inativa
                      ),
                    ),
                  );
                }).toList(),
              ),
              //Conteúdos
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      " ${_anuncio.preco}",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: temaPadrao.primaryColor),
                    ),

                    Text(
                      " ${_anuncio.titulo}",
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      " ${_anuncio.ano}",
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),

                    Text(
                      "Descrição:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: temaPadrao.primaryColor),
                    ),

                    Text(
                      " ${_anuncio.descricao}",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),

                    SizedBox(
                      child: Row(
                        children: [
                          Text(
                            "Contato:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: temaPadrao.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8), // Espaço entre os textos
                          Text(
                            _anuncio.telefone,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //espaçamento
                    const SizedBox(
                      //color: Colors.grey[200],
                      width: 7,
                      height: 10,
                    ),

                    SizedBox(
                      child: Row(
                        children: [
                          Text(
                            "Marca:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: temaPadrao.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8), // Espaço entre os textos
                          Text(
                            _anuncio.marca,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //espaçamento
                    const SizedBox(
                      //color: Colors.grey[200],
                      width: 7,
                      height: 10,
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Text(
                            "Modelo:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: temaPadrao.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8), // Espaço entre os textos
                          Text(
                            _anuncio.modelo,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
      //Botao wpp
      floatingActionButton: SizedBox(
        width: 70, // Ajuste o tamanho do círculo aqui
        height: 70, // Ajuste o tamanho do círculo aqui
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF2CB741),
          foregroundColor: Colors.white,
          elevation: 6.0, // Ajuste a elevação para aumentar o tamanho percebido
          child: const FaIcon(FontAwesomeIcons.whatsapp, size: 43), // Ajuste o tamanho do ícone aqui
          onPressed: () {
            // _ligarTelefone(_anuncio.telefone);
            _enviarMensagemWhatsApp(_anuncio.telefone); // Chame o método ao pressionar
          },
        ),
      ),
    );
  }
}
