import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:navika/src/routing.dart';
import 'package:navika/src/data/global.dart' as globals;
import 'package:navika/src/widgets/error_block.dart';
import 'package:navika/src/widgets/places/empty.dart';
import 'package:navika/src/widgets/places/listbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:navika/src/widgets/places/load.dart';

class RouteSearch extends StatefulWidget {
  final String type;

	const RouteSearch({
    required this.type,
    super.key
  });

	@override
	State<RouteSearch> createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  final myController = TextEditingController();
	final String title = 'Arrêts';
  
  FocusNode textFieldNode = FocusNode();
  String search = '';
  String error = '';
  bool isLoading = false;
  List places = [];

  Future<void> _getPlaces() async {
    String url = '';

    if ((globals.locationData?.latitude != null || globals.locationData?.longitude != null) && search != '') {
      url = '${globals.API_PLACES}?q=$search&lat=${globals.locationData?.latitude}&lon=${globals.locationData?.longitude}';

    } else if (search != '') {
      url = '${globals.API_PLACES}?q=$search';
      
    } else if (globals.locationData?.latitude != null && globals.locationData?.longitude != null){
      url = '${globals.API_PLACES}?lat=${globals.locationData?.latitude}&lon=${globals.locationData?.longitude}';

    } else {
      url = '${globals.API_PLACES}?q=';

    }

    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted) {
          setState(() {
            places = data['places'];
            isLoading = false;
            error = '';
          });
        }
      } else {
        setState(() {
          error = 'Récupération des informations impossible.';
        });
      }
    } catch (e) {
      setState(() {
        error = "Une erreur s'est produite.";
      });
    }
	}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {
      FocusScope.of(context).requestFocus(textFieldNode),
      _getPlaces()
    });
  }
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
	Widget build(BuildContext context) => Scaffold(
		appBar: AppBar(
			title: TextField(
        controller: myController,
        focusNode: textFieldNode,
        decoration: InputDecoration(
          hintText: widget.type == 'arr' ? 'Arrivée' : 'Départ'
        ),
        onChanged: (text) {
          setState(() {
            search = text;
          });
          _getPlaces();
        },
      ),
		),
		body: ListView(
      children: [

        if (error != '')
          ErrorBlock(
            error: error,
          )
        
        else if (places.isNotEmpty)
          for (var place in places)
            PlacesListButton(
              isLoading: isLoading,
              place: place,
              onTap: () {
                globals.route[widget.type]['id'] = place['id'];
                globals.route[widget.type]['name'] = place['name'];
                RouteStateScope.of(context).go('/journeys');
              },
            )

        else if (places.isEmpty && isLoading == true)
          const PlacesLoad()
          
        else
          const PlacesEmpty(),
      ],
      
    )
  );
}