import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:examen_api/components/loader_component.dart';
import 'package:examen_api/models/dog.dart';
import 'package:examen_api/screens/dog_Info_screen.dart';
import 'package:flutter/material.dart';
import 'package:examen_api/helpers/api_helper.dart';
import 'package:examen_api/models/response.dart';

class DogsScreen extends StatefulWidget {
  @override
  _DogsScreenState createState() => _DogsScreenState();
}

class _DogsScreenState extends State<DogsScreen> {
  List<Dog> _dogs = [];
  bool _isFiltered = false;
  String _search = '';
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getDogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00897B),
        title: Text('Perros'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
    );
  }

  Future<Null> _getDogs() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getDogsList();

    setState(() {
      _showLoader = false;
    });

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
      _dogs = response.result;
      // print(_dogs);
    });
  }

  Widget _getContent() {
    return _dogs.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay perros con ese criterio de búsqueda.'
              : 'No hay perros registrados.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getDogs,
      child: ListView(
        children: _dogs.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goDogDetails(e),
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.name,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar Perros'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Escriba las primeras letras del perro'),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'Criterio de búsqueda...',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (value) {
                    _search = value;
                  },
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar')),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getDogs();
  }

  void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<Dog> filteredList = [];
    for (var dog in _dogs) {
      if (dog.name.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(dog);
      }
    }

    setState(() {
      _dogs = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goDogDetails(Dog dog) async {
    String? result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => DogInfoScreen(dog: dog)));
    // if (result == 'yes') {
    //   _getUsers();
    // }
  }
}
