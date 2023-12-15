import 'dart:convert';
import 'dart:math';

import 'package:GaSmart/models/distributore.dart';
import 'package:GaSmart/models/enums.dart';
import 'package:GaSmart/models/vehicle.dart';
import 'package:GaSmart/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final start = TextEditingController();
  final end = TextEditingController();
  bool isVisible = false;
  String api = "http://192.168.1.124:8000";
  List<LatLng> routpoints = [];
  Position? _currentPosition;
  LatLng _currentLatLng = const LatLng(0, 0);
  List<Distributore> distributori = [];
  String carburante = "Benzina";
  Vehicle? v;
  double raggio = 10;
  bool risparmio = false;
  bool inquinamento = true;

  Widget buildListTile(Distributore d, Function cb) {
    return ListTile(
      // dense: true,
      title: Text(
        "${d.nome} - ${d.brand}",
        style: TextStyle(color: Theme.of(context).colorScheme.background),
      ),
      subtitle: Text(
        "$carburante €${d.prezzi[carburante]}",
        style: TextStyle(color: Theme.of(context).colorScheme.background),
      ),
      leading: Icon(Icons.account_circle,
          color: Theme.of(context).colorScheme.background),
      trailing: IconButton(
          onPressed: () => cb(),
          icon: Icon(Icons.arrow_right,
              color: Theme.of(context).colorScheme.background)),
    );
  }

  // TODO: get percorso meno inquinamento/massimo risparmio

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      setState(() {
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _loadSettings();
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<void> _apiCall() async {
    String coordStr =
        "${_currentPosition!.latitude.toString()},${_currentPosition!.longitude.toString()}";
    print(coordStr);
    String url = "$api/get/$coordStr/${raggio.toStringAsFixed(0)}/10";
    url = Uri.encodeFull(url);
    print(url);
    var response = await http.get(Uri.parse(url));
    List<dynamic> jsonResp = jsonDecode(response.body) as List<dynamic>;
    for (var dist in jsonResp) {
      try {
        Map<String, double> tmp_prezzi = {};
        (dist["prezzi"] as Map<String, dynamic>).forEach((key, value) {
          String k = "";
          // Supreme Diesel, Hi-Q Diesel, Metano, HiQ Perform+, Blue Super, Blue Diesel
          switch (key) {
            case "Gasolio":
              k = "Diesel";
              break;
            default:
              k = key;
              break;
          }
          print(key);
          tmp_prezzi[k] = dist["prezzi"][key] as double;
        });
        dist["prezzi"] = tmp_prezzi;
        print(dist["prezzi"]);
        if (dist["prezzi"][carburante] != null) {
          distributori.add(Distributore.fromJson(dist));
        }
      } on Exception catch (_) {}
      setState(() {
        isVisible = true;
      });
    }
    // print();
  }

  Future<void> _startNavigation(Distributore d, LatLng p) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      content: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [buildListTile(d, () => openMap(d.lat, d.lng))]),
      showCloseIcon: true,
      duration: const Duration(seconds: 50),
    ));

    if (_currentPosition == null) return;
    Location start = Location(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        timestamp: _currentPosition!.timestamp);
    Location end = Location(
        latitude: p.latitude,
        longitude: p.longitude,
        timestamp: DateTime.now());

    var v1 = start.latitude;
    var v2 = start.longitude;
    var v3 = end.latitude;
    var v4 = end.longitude;

    var url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
    print(
        'http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
    var response = await http.get(url);
    // print(response.body);
    setState(() {
      routpoints = [];
      var ruter =
          jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
      for (int i = 0; i < (ruter.length as int); i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "");
        reep = reep.replaceAll("]", "");
        var lat1 = reep.split(',');
        var long1 = reep.split(",");
        routpoints.add(LatLng(double.parse(lat1[1]), double.parse(long1[0])));
      }
      // print(routpoints);
    });
  }

  double getZoomLevel(double mapLongSidePixel, double km) {
    double ratio = 100;
    double degree = 45;
    double distance;
    km = km * 1000; //Length is in Km
    var k = mapLongSidePixel *
        156543.03392 *
        cos(degree *
            pi /
            180); //k = circumference of the world at the Lat_level, for Z=0
    distance = log((ratio * k) / (km * 100)) / ln2;
    distance = distance - 1; // Z starts from 0 instead of 1
    return (distance);
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      // ScaffoldMessenger.of(context).showMaterialBanner(
      //     MaterialBanner(content: Text('sus'), actions: [Text('sas')]));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Future<void> _loadSettings() async {
    // await DB.deleteDatabase();
    var st = (await DB.getSettings())[0];
    var selV = await DB.getVehicle(st["veicolo"] as int);
    _apiCall();
    setState(() {
      v = selV;
      risparmio = (st["risparmio"] as int) == 1 ? true : false;
      inquinamento = (st["inquinamento"] as int) == 1 ? true : false;
      raggio = (st["raggio"] as int).toDouble();
      carburante = EnumConverter.stringFromTipoCarburante(v!.carburante);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.grey[500]),
              //     onPressed: () async {

              //     },
              //     child: Text('Press')),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: isVisible,
                // replacement: CircularProgressIndicator(),
                replacement: Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 20,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: SizedBox(
                    height: 500,
                    width: MediaQuery.of(context).size.width - 20,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentLatLng,
                        initialZoom: getZoomLevel(
                            MediaQuery.of(context).size.width - 20, raggio),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.gasmart.app',
                        ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                                points: routpoints,
                                color: Colors.deepPurple,
                                strokeWidth: 9)
                          ],
                        ),
                        MarkerLayer(markers: [
                          Marker(
                              point: _currentLatLng,
                              child: const Icon(Icons.person_pin_circle,
                                  color: Colors.redAccent, size: 45)),
                          ...distributori.map((e) => Marker(
                              // width: 100,
                              // height: 50,
                              point: LatLng(e.lat, e.lng),
                              child: Stack(
                                children: [
                                  // Container(
                                  //   margin:
                                  //       EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  //   width: 100,
                                  //   height: 50,
                                  //   decoration:
                                  //       BoxDecoration(color: Colors.blue),
                                  //   child: Text("sus"),
                                  // ),
                                  GestureDetector(
                                    onTap: () {
                                      _startNavigation(e, LatLng(e.lat, e.lng));
                                    },
                                    child: const Icon(Icons.location_on,
                                        color: Colors.redAccent, size: 45),
                                  ),
                                ],
                              )))
                        ])
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet<void>(
                    showDragHandle: true,
                    context: context,
                    backgroundColor: Theme.of(context).colorScheme.onBackground,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: distributori
                                  .map((e) => buildListTile(e, () {
                                        Navigator.pop(context);
                                        openMap(e.lat, e.lng);
                                      }))
                                  .toList(),
                            )),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.menu),
                label: const Text('Apri lista'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
