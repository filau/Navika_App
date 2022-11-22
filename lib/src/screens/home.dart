import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/gestures.dart';
import 'package:http/http.dart' as http; 
import 'package:location/location.dart' as gps;
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:navika/src/routing/route_state.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/global.dart' as globals;
import '../controller/here_map_controller.dart';

import '../widgets/home/body.dart';
import '../widgets/home/header.dart';
import '../widgets/schedules/body.dart';
import '../widgets/schedules/header.dart';

class HomeScreen extends StatefulWidget {
  final bool displaySchedules;

	const HomeScreen({
    this.displaySchedules = false,
		super.key,
	});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HereController? _controller;
  PanelController panelController = PanelController();

  GeoCoordinates camGeoCoords = GeoCoordinates(0, 0);
  gps.Location location = gps.Location();

  CompassEvent? compassEvent;
  double compassHeading = 0;

  bool isPanned = false;
  bool is3dMap = false;
  bool _isInBox = false;
  late Timer _timer;

  double panelButtonBottomOffsetClosed = 120;
  double panelButtonBottomOffset = 120;
  double _position = 0;

  List pointNearby = [];
  Map index = {};

  String _panel = '';

  Future<void> _getLocation() async {
    print({'INFO_Widget', widget.displaySchedules});
    bool serviceEnabled;
    gps.PermissionStatus permissionGranted;
    gps.LocationData locationData;

    if (!globals.isSetLocation){
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == gps.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != gps.PermissionStatus.granted) {
          return;
        }
      }
      
      locationData = await location.getLocation();
      FlutterCompass.events?.listen((CompassEvent compassEvent ) {
        _updateCompass(compassEvent);
      });
      _addLocationIndicator(locationData);
      location.onLocationChanged.listen((gps.LocationData currentLocation) {
        _updateLocationIndicator(currentLocation);
      });
      await _getPoints();
      
    } else {
      locationData = await location.getLocation();

      FlutterCompass.events?.listen((CompassEvent compassEvent ) {
        _updateCompass(compassEvent);
      });
      location.onLocationChanged.listen((gps.LocationData currentLocation) {
        _updateLocationIndicator(currentLocation);
      });
      await _getPoints();
    }
	}

  String getMarkerImageByType (modes) {
    if (modes.contains('physical_mode:RapidTransit')){
      return "assets/marker/marker_rer_blue.png";

    } else if (modes.contains('physical_mode:Train') || modes.contains('physical_mode:RailShuttle') || modes.contains('physical_mode:LocalTrain') || modes.contains('physical_mode:LongDistanceTrain')){
      return "assets/marker/marker_train_blue.png";

    } else if (modes.contains('physical_mode:Metro') || modes.contains('physical_mode:Shuttle')){
      return "assets/marker/marker_metro_blue.png";

    } else if (modes.contains('physical_mode:Tramway')){
      return "assets/marker/marker_tram_blue.png";

    } else if (modes.contains('physical_mode:SuspendedCableCar')){
      return "assets/marker/marker_cable_blue.png";

    } else if (modes.contains('physical_mode:Boat')){
      return "assets/marker/marker_navette_fluviale_blue.png";

    } else if (modes.contains('physical_mode:Bus') || modes.contains('physical_mode:BusRapidTransit') ){
      return "assets/marker/marker_bus_blue.png";
    }
    // physical_mode:Funicular
    return "";
  }

  Future<void> _getPoints() async {
    // final response = await http.get(Uri.parse('${globals.API_POINTS}?lat=${camGeoCoords.latitude == 0 ? globals.locationData?.latitude : camGeoCoords.latitude}&lon=${camGeoCoords.longitude == 0 ? globals.locationData?.longitude : camGeoCoords.longitude}'));
    final response = await http.get(Uri.parse('${globals.API_STOP_AREA}?lat=${camGeoCoords.latitude == 0 ? globals.locationData?.latitude : camGeoCoords.latitude}&lon=${camGeoCoords.longitude == 0 ? globals.locationData?.longitude : camGeoCoords.longitude}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (mounted) {
        setState(() {
          pointNearby = data['places'];
        });
      }

      for (var stop in data['places']) {
        GeoCoordinates stopCoords = GeoCoordinates(stop['coord']['lat'], stop['coord']['lon']);
        Metadata metadata = Metadata();
        metadata.setString("id", stop['id']);
        metadata.setString("name", stop['name']);
        metadata.setString("modes", json.encode(stop['modes']));
        metadata.setDouble("lat", stop['coord']['lat']);
        metadata.setDouble("lon", stop['coord']['lon']);

        _controller?.addMapMarker(stopCoords, getMarkerImageByType(stop['modes']), metadata);
      }
    }
	}

  Future<void> _getIndex() async {
    if (globals.index != null) {
      setState(() {
        index = globals.index!;
      });
      
    } else {
      final response = await http.get(Uri.parse('${globals.API_INDEX}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted) {
          setState(() {
            index = data;
          });
          globals.index = data;
        }
      }
    }
	}

  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness : Brightness.dark,
    ),
    child: Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SlidingUpPanel(
            parallaxEnabled: true,
            parallaxOffset: 0.6,
            color: const Color(0xfffafafa),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
            snapPoint: 0.55,
            minHeight: widget.displaySchedules ? 75 : 100,
            maxHeight: (MediaQuery.of(context).size.height - 110),
            controller: panelController,
            onPanelSlide: (position) => onPanelSlide(position),

            header: widget.displaySchedules
              ? SchedulesPannel(
                  tooglePanel: tooglePanel
                )
              : HomePannel(
                  tooglePanel: tooglePanel
                ),

            panelBuilder: (ScrollController scrollController) => widget.displaySchedules
              ? Container(
                  margin: const EdgeInsets.only(top:40),
                  child: Schedules_Body(
                    scrollController: scrollController
                  )
                )
              : HomeBody(
                  scrollController: scrollController,
                  index: index,
                ),

            body: HereMap(onMapCreated: _onMapCreated),
            
          ),

          Positioned(
            right: 20,
            bottom: panelButtonBottomOffset,
            child: Opacity(
              opacity: _position > 0.7 ? ((1 / _position - 1) * 2.33) : 1,
              child: FloatingActionButton(
                backgroundColor: Colors.grey[200],
                child: _isInBox ?
                  SvgPicture.asset(
                    'assets/location-indicator.svg',
                    width: 30
                  )
                : SvgPicture.asset(
                    'assets/locate.svg',
                    width: 30
                  ),
                onPressed: () {
                  _zoomOn();
                  closePanel();
                }
              )
            ),
          ),
          
          Positioned(
            left: 10,
            bottom: panelButtonBottomOffset - 20,
            child: Opacity(
              opacity: _position > 0.7 ? ((1 / _position - 1) * 2.33) : 1,
              child: const Image(
                width: 50,
                image: AssetImage('assets/Here.png')
              )
            ),
          ),
        ],
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getIndex();
      _getPoints();
      getInBox();
      panelController.animatePanelToSnapPoint( );
    });
  }
  
  @override
  void dispose() async {
    super.dispose();
    globals.isSetLocation = false;
    _timer.cancel();
  }

  void getInBox(){
    bool isInBox;
    isInBox = _controller?.isOverLocation() ?? false;
    setState(() {
      _isInBox = isInBox;
    });
    _timer = Timer(const Duration(milliseconds: 100), () {
      getInBox();
    });
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (MapError? error) {
      if (error != null) {
        return;
      }

      _controller = HereController(hereMapController);
      _getLocation();

      GeoCoordinates geoCoords;
      double distanceToEarthInMeters = 10000;
      if (globals.isSetLocation) { // Resume Map
        geoCoords = GeoCoordinates(globals.locationData?.latitude ?? 48.859481, globals.locationData?.longitude ?? 2.346711);
        distanceToEarthInMeters = 1000;

      } else if (globals.hiveBox?.get('latitude') != null && globals.hiveBox?.get('longitude') != null){ // Opening App
        geoCoords = GeoCoordinates(globals.hiveBox.get('latitude') ?? 48.859481, globals.hiveBox.get('longitude') ?? 2.346711);
        distanceToEarthInMeters = 10000;

      } else {
        geoCoords = GeoCoordinates(48.859481, 2.346711);
        _controller?.addLocationIndicator(globals.locationData, LocationIndicatorIndicatorStyle.pedestrian, globals.compassHeading, true);
      
      }

      MapMeasure mapMeasureZoom = MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
      hereMapController.camera.lookAtPointWithMeasure(geoCoords, mapMeasureZoom);

      hereMapController.gestures.panListener = PanListener((GestureState state, Point2D origin, Point2D translation, double velocity) {
        if (mounted){
          if (state == GestureState.begin) {
            setState(() {
              isPanned = true;
            });
          }
          if (state == GestureState.end) {
            setState(() {
              camGeoCoords = _controller?.getOverLocation() ?? camGeoCoords;
            });
            _getPoints();
          }
        }
      } );

      _controller?.addLocationIndicator(globals.locationData, LocationIndicatorIndicatorStyle.pedestrian, globals.compassHeading, false);
      _addTapListener();
      _getPoints();
    });
  }

  void _addTapListener() {
    var tapListener = TapListener((Point2D touchPoint) {
      _pickMapMarker(touchPoint);
    });
    _controller?.addTapListener(tapListener); 
  }
  

  void _pickMapMarker(Point2D touchPoint) {
    double radiusInPixel = 2;
      _controller?.pickMapItems(touchPoint, radiusInPixel, (pickMapItemsResult) {
      if (pickMapItemsResult == null) {
        print("Pick operation failed.");
        return;
      }
      List<MapMarker> mapMarkerList = pickMapItemsResult.markers;
      if (mapMarkerList.length == 0) {
        print("No map markers found.");
        return;
      }

      MapMarker topmostMapMarker = mapMarkerList.first;
      Metadata? metadata = topmostMapMarker.metadata;
      if (metadata != null) {
        globals.schedulesStopArea = metadata.getString("id") ?? "";
        globals.schedulesStopName = metadata.getString("name") ?? "";
        globals.schedulesStopModes = json.decode(metadata.getString("modes") ?? "");
        if (mounted) {
          setState(() {
            //_panel = 'schedules';
            isPanned = true;
          });
        }
        GeoCoordinatesUpdate geoCoords = GeoCoordinatesUpdate(metadata.getDouble("lat") ?? 0, metadata.getDouble("lon") ?? 0);
        _controller?.zoomTo(geoCoords);
        panelController.animatePanelToSnapPoint( );
        RouteStateScope.of(context).go('/stops');
        return;
      }
    });
  }

  void _addLocationIndicator(gps.LocationData locationData) {
    _controller?.addLocationIndicator(locationData, LocationIndicatorIndicatorStyle.pedestrian, globals.compassHeading);
  }
  
  void _updateLocationIndicator(gps.LocationData locationData) {
      _controller?.updateLocationIndicator(locationData, globals.compassHeading);
  }

  void _updateCompass(CompassEvent compassEvent){
    var heading = compassEvent.heading ?? 0;
    if (mounted) {
      setState(() {
        compassHeading = heading;
      });
    }
    globals.compassHeading = heading;

    if (is3dMap){
      if (!isPanned){ // si on a touché l'écran
        _controller?.zoomOnLocationIndicator(is3dMap);
      }
    } 
    _controller?.updateLocationIndicator(globals.locationData, heading);
  }

  void _zoomTo() {
    var isOverLocation = _controller?.isOverLocation() ?? false;
    if (isOverLocation) {
      setState(() {
        is3dMap = !is3dMap;
        isPanned = false;
      });
    }
    _controller?.zoomOnLocationIndicator(is3dMap);
  }

  void _zoomOn() {
    var isOverLocation = _controller?.isOverLocation() ?? false;
    if (isOverLocation) {
      setState(() {
        is3dMap = !is3dMap;
        isPanned = false;
      });
    }
    _controller?.zoomOnLocationIndicator(is3dMap);
  }

  void onPanelSlide(position) {
    setState(() {
      panelButtonBottomOffset = panelButtonBottomOffsetClosed + ((MediaQuery.of(context).size.height - 200) * position);
      _position = position;
    });
  }

  void tooglePanel() {
    if (panelController.isPanelOpen){
      panelController.close();
    } else {
      panelController.open();
    }
  }

  void closePanel() {
    panelController.close();
  }
}