import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:navika/src/style/style.dart';
import 'package:navika/src/widgets/error_block.dart';
import 'package:navika/src/widgets/home/messages.dart';
import 'package:navika/src/widgets/trafic/block.dart';
import 'package:navika/src/data/global.dart' as globals;

class Trafic extends StatefulWidget {
  const Trafic({super.key});

  @override
  State<Trafic> createState() => _TraficState();
}

class _TraficState extends State<Trafic> {
  final String title = 'Info Trafic';

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  bool state = false;
  List trafic = [];
  String error = '';

  Future<void> _getTrafic() async {
    if (globals.trafic.isNotEmpty) {
      setState(() {
        state = true;
        trafic = globals.trafic;
      });
    }

    try {
      final response = await http.get(Uri.parse(globals.API_TRAFIC));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        globals.trafic = data['trafic'];

        if (mounted) {
          setState(() {
            state = true;
            trafic = data['trafic'];
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title, style: appBarTitle),
        ),
        body: error != ''
            ? ErrorBlock(
                error: error,
              )
            : Container(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RefreshIndicator(
                  onRefresh: _getTrafic,
                  key: _refreshIndicatorKey,
                  child: ListView(
                    children: [
                      // Messages de l'index
                      if (globals.index?['message'] != null)
                        for (var message in globals.index?['message'])
                          Container(
                            margin: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                            child: HomeMessage(
                              message: message,
                              isMarginDisabled: true,
                            ),
                          ),

// RER
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            padding: const EdgeInsets.all(10.0),
                            width: 45,
                            height: 45,
                            child: Image(
                              image: AssetImage(Brightness.dark ==
                                      Theme.of(context).colorScheme.brightness
                                  ? 'assets/img/icons/RER_light.png'
                                  : 'assets/img/icons/RER.png'),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                TraficBlock(
                                  name: 'RER A',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'RER B',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'RER C',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'RER D',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'RER E',
                                  trafic: trafic,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        thickness: 1.5,
                      ),

// TRAIN
                      Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              padding: const EdgeInsets.all(10.0),
                              width: 45,
                              height: 45,
                              child: Image(
                                  image: AssetImage(Brightness.dark ==
                                          Theme.of(context)
                                              .colorScheme
                                              .brightness
                                      ? 'assets/img/icons/train_light.png'
                                      : 'assets/img/icons/train.png'))),
                          Expanded(
                            child: Wrap(
                              children: [
                                TraficBlock(
                                  name: 'TRANSILIEN H',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN J',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN K',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN L',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN N',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN P',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN R',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'TRANSILIEN U',
                                  trafic: trafic,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                     Divider(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        thickness: 1.5,
                      ),

// METRO
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            padding: const EdgeInsets.all(10.0),
                            width: 45,
                            height: 45,
                            child: Image(
                              image: AssetImage(Brightness.dark ==
                                      Theme.of(context).colorScheme.brightness
                                  ? 'assets/img/icons/metro_light.png'
                                  : 'assets/img/icons/metro.png'),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                TraficBlock(
                                  name: 'METRO 1',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 2',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 3',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 3B',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 4',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 5',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 6',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 7',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 7B',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 8',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 9',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 10',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 11',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 12',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 13',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'METRO 14',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'CDG Val',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'Orly val',
                                  trafic: trafic,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        color: const Color.fromARGB(255, 70, 70, 70),
                        thickness: 1.5,
                      ),

// TRAM
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            padding: const EdgeInsets.all(10.0),
                            width: 45,
                            height: 45,
                            child: Image(
                              image: AssetImage(Brightness.dark ==
                                      Theme.of(context).colorScheme.brightness
                                  ? 'assets/img/icons/tram_light.png'
                                  : 'assets/img/icons/tram.png'),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                TraficBlock(
                                  name: 'T1',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T2',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T3A',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T3B',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T4',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T5',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T6',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T7',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T8',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T9',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T11',
                                  trafic: trafic,
                                ),
                                TraficBlock(
                                  name: 'T13',
                                  trafic: trafic,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => {_refreshIndicatorKey.currentState?.show()});
  }

  @override
  void deactivate() {
    super.deactivate();
  }
}
