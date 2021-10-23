import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:examen_api/helpers/api_helper.dart';
import 'package:examen_api/models/dog.dart';
import 'package:examen_api/models/response.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DogInfoScreen extends StatefulWidget {
  final Dog dog;

  DogInfoScreen({required this.dog});

  @override
  _DogInfoScreenState createState() => _DogInfoScreenState();
}

class _DogInfoScreenState extends State<DogInfoScreen> {
  late Dog _dog;

  @override
  void initState() {
    super.initState();
    print(widget.dog);
    _dog = widget.dog;
    _getDog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dog.name),
      ),
      body: Center(
        child: _getContent(),
      ),
    );
  }

  Future<Null> _getDog() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getDogImages(_dog.name);
    _dog.images = response.result;

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    setState(() {
      _dog.images = response.result;
      print(_dog.images);
    });
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showDogInfo(),
        Expanded(
          child: _dog.type.length == 0 ? _noContent() : _getListView(),
        ),
      ],
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'El perro no tiene tipos de raza.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getDog,
      child: ListView(
        children: _dog.type.map((e) {
          return Card(
            child: InkWell(
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                e,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _showDogInfo() {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.5,
      child: Swiper(
        itemCount: _dog.images.length,
        layout: SwiperLayout.STACK,
        itemWidth: size.width * 0.6,
        itemHeight: size.height * 0.4,
        itemBuilder: (_, int index) {
          final dog = _dog;

          dog.name = 'swiper-${dog.name}';

          return GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, 'details', arguments: dog),
            child: Hero(
              tag: dog.name!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: AssetImage('assets/noimage.png'),
                  image: NetworkImage(dog.images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
