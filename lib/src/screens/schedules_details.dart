import 'package:flutter/material.dart';
import 'package:navika/src/widgets/schedules/body.dart';
import '../data/global.dart' as globals;

class SchedulesDetails extends StatefulWidget {
  final String? navPos;

  const SchedulesDetails({this.navPos, super.key});

  @override
  State<SchedulesDetails> createState() => _SchedulesDetailsState();
}

class _SchedulesDetailsState extends State<SchedulesDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool state = false;
  int up = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(globals.schedulesStopName),
    ),
    body: SchedulesBody(
      scrollController: ScrollController()
    )
  );
}