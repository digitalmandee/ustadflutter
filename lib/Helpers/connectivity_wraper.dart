// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ustaad/Providers/conctivity_provider.dart';

// class ConnectivityWrapper extends StatefulWidget {
//   final Widget child;
//   final GlobalKey<ScaffoldMessengerState> messengerKey;

//   const ConnectivityWrapper({
//     required this.child,
//     required this.messengerKey,
//   });

//   @override
//   State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
// }

// class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
//   bool? _lastStatus;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ConnectivityProvider>(
//       builder: (context, provider, _) {
//         if (_lastStatus != provider.isOnline) {
//           _lastStatus = provider.isOnline;

//           final snackBar = SnackBar(
//             content: Text(
//               provider.isOnline
//                   ? "✅ Internet Connected"
//                   : "🚫 No Internet Connection",
//             ),
//             backgroundColor: provider.isOnline ? Colors.green : Colors.red,
//             duration: const Duration(seconds: 3),
//           );

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             widget.messengerKey.currentState?.showSnackBar(snackBar);
//           });
//         }

//         return widget.child;
//       },
//     );
//   }
// }
