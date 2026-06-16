import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_field.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Tutor%20Side/location_provider.dart';
import 'package:flutterustad/Screens/Teacher%20Screens/0nBoard%20Screens/submission_screen.dart';

class OnboardLocation extends StatefulWidget {
  final VoidCallback onBackTap;

  const OnboardLocation({super.key, required this.onBackTap});

  @override
  State<OnboardLocation> createState() => _OnboardLocationState();
}

class _OnboardLocationState extends State<OnboardLocation> {
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
        context: context,
        msg: "Location permission denied forever.",
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20),
                      CustomAppTextField(
                        height: 50,
                        width: ScreenSize(context).width,
                        texthint: "Add location",
                        controller: _controller,
                        border: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            "assets/images/addLocation.png",
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
                                    setState(
                                      () => _isLoading = true,
                                    ); // start loading
                                    await provider.addLocation(value);
                                    setState(
                                      () => _isLoading = false,
                                    ); // stop loading
                                    _controller.clear();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 1.0,
                                    horizontal: 5,
                                  ),
                                  child: Card(
                                    color: AppTheme.primaryCOlor,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Image.asset(
                                          "assets/images/addSharp.png",
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 20),
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
                                          width: 4,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
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
                                              "assets/images/map.png",
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AppText.appText(
                                                toBeginningOfSentenceCase(
                                                  loc.address,
                                                ).toUpperCase(),
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
                                                "${loc.distanceFromUser?.toStringAsFixed(2) ?? '0.0'} km away",
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      AppButton.appButton(
                        "Proceed",
                        context: context,
                        onTap: () {
                          if (provider.locations.isEmpty) {
                            AppToast.error(
                              context: context,
                              msg: "Please add at least one Location",
                            );
                            return;
                          } else {
                            pushUntil(
                              context,
                              const SubmissionCompleteScreen(tutor: true),
                            );
                          }
                        },
                        textColor: AppTheme.white,
                        border: false,
                        height: 52,
                        backgroundColor: AppTheme.primaryCOlor,
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

  Widget _buildHeader() {
    return Text.rich(
      TextSpan(
        text: 'Let Us know your ',
        style: TextStyle(
          fontSize: 35,
          color: AppTheme.black,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: 'Locations',
            style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 35,
            ),
          ),
          // TextSpan(text: ' For Your '),
          // TextSpan(
          //   text: 'Tutoring',
          //   style: TextStyle(
          //     color: AppTheme.appColor,
          //     fontWeight: FontWeight.w600,
          //     fontSize: 35,
          //   ),
          // ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
