// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:ktp_scan/ktp_scan.dart';

// typedef OnKtpAvailable = void Function(Ktp data, String image);

// class CamScreen extends StatefulWidget {
//   final PreferredSizeWidget? appBar;
//   final OnKtpAvailable? onKtpAvailable;

//   const CamScreen({this.appBar, this.onKtpAvailable, super.key});

//   @override
//   State<CamScreen> createState() => _CamScreenState();
// }

// class _CamScreenState extends State<CamScreen> with WidgetsBindingObserver {
//   CameraController? _cameraController;
//   List<CameraDescription> _cameras = [];

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() async {
//       WidgetsBinding.instance.addObserver(this);
//       _cameras = await availableCameras();
//       onNewCameraSelected(_cameras.first);
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final controller = _cameraController;

//     // App state changed before we got the chance to initialize.
//     if (controller == null || !controller.value.isInitialized) {
//       return;
//     }

//     if (state == AppLifecycleState.inactive) {
//       controller.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       onNewCameraSelected(controller.description);
//     }
//   }

//   void onNewCameraSelected(CameraDescription cameraDescription) async {
//     await _cameraController?.dispose();

//     final controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     // If the controller is updated then update the UI.
//     controller.addListener(() {
//       if (mounted) setState(() {});
//       if (controller.value.hasError) {
//         showInSnackBar('Camera error ${controller.value.errorDescription}');
//       }
//     });

//     _cameraController = controller;

//     try {
//       await controller.initialize();
//     } on CameraException catch (e) {
//       switch (e.code) {
//         case 'CameraAccessDenied':
//           showInSnackBar('User denied camera access.');
//           break;
//         default:
//           showInSnackBar(e.description ?? 'error occured');
//           break;
//       }
//       return;
//     } catch (e) {
//       showInSnackBar('Other errors.');
//       return;
//     }
//   }

//   void showInSnackBar(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }

//   void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
//     final controller = _cameraController;
//     if (controller == null) return;

//     final Offset offset = Offset(
//       details.localPosition.dx / constraints.maxWidth,
//       details.localPosition.dy / constraints.maxHeight,
//     );

//     controller
//       ..setExposurePoint(offset)
//       ..setFocusPoint(offset);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.appBar,
//       body: Stack(
//         children: [
//           cam(),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.all(18),
//                 shape: const CircleBorder(),
//               ),
//               onPressed: () => capture(),
//               child: const Icon(Icons.cameraswitch_rounded),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void capture() async {
//     final controller = _cameraController;
//     if (controller == null) return;
//     final imageFile = await controller.takePicture();
//     showImage(controller, imageFile);
//   }

//   void showImage(CameraController controller, XFile imageFile) async {
//     await controller.pausePreview();
//     final ktp = await showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (ctx) {
//         return Dialog(
//           child: Container(
//             padding: const EdgeInsets.all(21),
//             child: Column(
//               children: [
//                 kIsWeb
//                     ? Image.network(imageFile.path)
//                     : Image.file(File(imageFile.path)),
//                 ElevatedButton(
//                   onPressed: () {
//                     // TODO: run KTP OCR
//                     final ktp = FakeKtp.create();
//                     Navigator.of(ctx).pop(ktp);
//                   },
//                   child: const Text('Select'),
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//     await controller.resumePreview();

//     if (ktp != null) widget.onKtpAvailable?.call(ktp, imageFile.path);
//   }

//   Widget cam() {
//     final controller = _cameraController;
//     return (controller == null || !controller.value.isInitialized)
//         ? const SizedBox()
//         : CameraPreview(
//             controller,
//             child: LayoutBuilder(
//               builder: (BuildContext context, BoxConstraints constraints) {
//                 return GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTapDown: (TapDownDetails details) => onViewFinderTap(
//                     details,
//                     constraints,
//                   ),
//                 );
//               },
//             ),
//           );
//   }
// }
