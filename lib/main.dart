import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    ));

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(30.009131, 31.288455);
const LatLng DEST_LOCATION = LatLng(30.0089321,31.291151);

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
    Completer<GoogleMapController> _controller = Completer();
    // this set will hold my markers
    Set<Marker> _markers = {};
    // this will hold the generated polylines
    Set<Polyline> _polylines = {};
    // this will hold each polyline coordinate as Lat and Lng pairs
    List<LatLng> polylineCoordinates = [];
    // this is the key object - the PolylinePoints
    // which generates every polyline between start and finish
    PolylinePoints polylinePoints = PolylinePoints();
    String googleAPIKey = "AIzaSyCRtivsBgvUare_z_4m9LqoKvXQ25humXE";
    // for my custom icons
    BitmapDescriptor pinIcon;
    BitmapDescriptor sourceIcon;
    BitmapDescriptor destinationIcon;

    @override
    void initState() {
      super.initState();
      setSourceAndDestinationIcons();
    }

    void setSourceAndDestinationIcons() async {

      pinIcon= await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio:100), 'assets/ic_pin.png');
      sourceIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
      destinationIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(devicePixelRatio: 2.5),
          'assets/destination_map_marker.png');
    }

    @override
    Widget build(BuildContext context) {
      CameraPosition initialLocation = CameraPosition(
          zoom: CAMERA_ZOOM,
          bearing: CAMERA_BEARING,
          tilt: CAMERA_TILT,
          target: SOURCE_LOCATION);
      return GoogleMap(
          myLocationEnabled: true,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          markers: _markers,
          polylines: _polylines,
          mapType: MapType.normal,
          initialCameraPosition: initialLocation,
          onMapCreated: onMapCreated);
    }

    void onMapCreated(GoogleMapController controller) {
      controller.setMapStyle(Utils.mapStyles);
      _controller.complete(controller);
      setMapPins();
      setPolylines();
    }

    void setMapPins() {
      setState(() {
        // source pin
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            position: SOURCE_LOCATION,
            icon: pinIcon));
        // destination pin
        _markers.add(Marker(
            markerId: MarkerId('destPin'),
            position: DEST_LOCATION,
            icon: pinIcon));
      });
    }

    setPolylines() async {

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            "AIzaSyCRtivsBgvUare_z_4m9LqoKvXQ25humXE",
            PointLatLng(
              SOURCE_LOCATION.latitude,
              SOURCE_LOCATION.longitude,
            ),
          PointLatLng(
              DEST_LOCATION.latitude,
              DEST_LOCATION.longitude
          ),

        );
        print("${result.status}");
        // loop through all PointLatLng points and convert them
          // to a list of LatLng, required by the Polyline
          result.points.forEach((PointLatLng point) {
            print("${point.latitude},${point.longitude}");
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });


      setState(() {
          // create a Polyline instance
          // with an id, an RGB color and the list of LatLng pairs
          Polyline polyline = Polyline(
              polylineId: PolylineId("poly"),
              width: 2,

              color: Color(0xff1ED761),
              points: [
                LatLng(30.009131, 31.288455),
                LatLng(30.0089321,31.291151),
                LatLng(30.0089321,31.291151),
                LatLng(30.0089321,31.291151),
              ]);

          // add the constructed polyline as a set of points
          // to the polyline set, which will eventually
          // end up showing up on the map
          _polylines.add(polyline);
      });
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
