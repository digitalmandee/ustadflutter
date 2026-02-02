// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class ConnectivityProvider with ChangeNotifier {
//   bool _isOnline = true;
//   bool get isOnline => _isOnline;

//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription _subscription;

//   ConnectivityProvider() {
//     _subscription = _connectivity.onConnectivityChanged.listen((results) async {
//       // results ek List<ConnectivityResult> hai
//       if (results.isNotEmpty) {
//         await _checkInternet();
//       }
//     });
// // initial check
//   }

// //   Future<void> _updateStatus(ConnectivityResult result) async {
// //     await _checkInternet();
// //   }

// //   Future<void> _checkInternet() async {
// //     try {
// //       final result = await InternetAddress.lookup('google.com');
// //       _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
// //     } catch (_) {
// //       _isOnline = false;
// //     }
// //     notifyListeners();
// //   }

// //   @override
// //   void dispose() {
// //     _subscription.cancel();
// //     super.dispose();
// //   }
// // }
