import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Tutor%20Side/location_provider.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<LocationProvider>(context, listen: false).fetchLocations();
      }
    });
    getCurrentLocation(context);
  }

  Future<void> getCurrentLocation(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppToast.error(context: context, msg: "Enable location services.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppToast.error(context: context, msg: "Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppToast.error(
          context: context, msg: "Location permission denied forever.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final provider = Provider.of<LocationProvider>(context, listen: false);
    provider.setUserLocation(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/Background.png",
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              CustomAppBar1(
                title: "Add Location",
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppTextField(
                        height: 50,
                        width: ScreenSize(context).width,
                        texthint: "Add location",
                        controller: _controller,
                        border: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            "assets/images/search.png",
                            color: Color(0xffA6ADBF),
                          ),
                        ),
                        suffix: _isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  "assets/images/loaderGif.gif",
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  final value = _controller.text.trim();
                                  if (value.isNotEmpty) {
                                    setState(() =>
                                        _isLoading = true); // start loading
                                    await provider.addLocation(value);
                                    setState(() =>
                                        _isLoading = false); // stop loading
                                    _controller.clear();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 1.0, horizontal: 5),
                                  child: Card(
                                    color: AppTheme.white,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Image.asset(
                                          "assets/images/addSharp.png",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Expanded(
                        child: provider.locations.isEmpty
                            ? const Center(child: Text("No locations found."))
                            : ListView.builder(
                                itemCount: provider.locations.length,
                                itemBuilder: (context, index) {
                                  final loc = provider.locations[index];
                                  return Container(
                                      height: 100,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border(
                                            left: BorderSide(
                                                color: AppTheme.primaryCOlor,
                                                width: 4)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 48,
                                              width: 48,
                                              color: AppTheme.grey,
                                              child: Image.asset(
                                                  "assets/images/map.png"),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AppText.appText(
                                                  capitalizeEachWord(
                                                    toBeginningOfSentenceCase(
                                                            loc.address) ??
                                                        '',
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                                // AppText.appText(
                                                //   "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
                                                //   fontSize: 12,
                                                //   fontWeight: FontWeight.w400,
                                                //   textColor: Colors.grey,
                                                // ),
                                                AppText.appText(
                                                  "${loc.distanceFromUser?.toStringAsFixed(2) ?? '0.0'} miles away",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  textColor: Colors.grey,
                                                ),
                                                GestureDetector(
                                                  onTap: () => provider
                                                      .deleteLocation(loc.id),
                                                  child: AppText.appText(
                                                    "Remove",
                                                    underLine: true,
                                                    decorationColor: Colors.red,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    textColor: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ));
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
