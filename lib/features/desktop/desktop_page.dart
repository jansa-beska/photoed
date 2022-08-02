import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum PhotoTypes {
  normal,
  bilateralFilter,
  dilate,
  filter2D,
  medianBlur,
  morphologyEx,
  pyrMeanShiftFiltering,
  scharr,
  threshold,
  adaptiveThreshold,
  cvtColor,
  applyColorMap,
}

final photoTypesStrings = [
  'bilateralFilter',
  'dilate',
  'filter2D',
  'medianBlur',
  'morphologyEx',
  'pyrMeanShiftFiltering',
  'scharr',
  'threshold',
  'adaptiveThreshold',
  'cvtColor',
  'applyColorMap',
];

class DesktopPage extends StatefulWidget {
  final File? image;
  final bool isPro;
  const DesktopPage({
    Key? key,
    this.image,
    required this.isPro,
  }) : super(key: key);

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  PhotoTypes currType = PhotoTypes.normal;
  Uint8List? byte;
  int currNum = 2;
  @override
  void initState() {
    if (widget.isPro) {
      currNum = 11;
    } else {
      currNum = 2;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF383838),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: SvgPicture.asset('assets/fi_arrow-left.svg'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoButton(
                  child: const Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (byte != null) {
                      final res = await sharePhoto(byte);
                    }
                  },
                ),
              ],
            ),
            FutureBuilder(
              future: getPhoto(widget.image!.path, currType),
              builder: (context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data!;
                } else {
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: CupertinoButton(
                      onPressed: () {
                        setState(() {
                          currType = PhotoTypes.normal;
                        });
                      },
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://raw.githubusercontent.com/fgsoruco/opencv_4/main/display/bilateralFilter.JPG',
                          height: 63,
                          width: 63,
                        ),
                      ),
                    ),
                  ),
                ] +
                List.generate(
                  currNum,
                  (index) => Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    child: CupertinoButton(
                      onPressed: () {
                        setState(() {
                          currType = PhotoTypes.values[index + 1];
                        });
                      },
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://raw.githubusercontent.com/fgsoruco/opencv_4/main/display/${photoTypesStrings[index]}.JPG',
                          height: 63,
                          width: 63,
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Future<bool> sharePhoto(Uint8List? byte) async {
    try {
      final String path =
          '${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().microsecondsSinceEpoch}.png';
      File file = await File(path).writeAsBytes(byte!.toList());
      await Share.shareFiles([file.path]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Image> getPhoto(final String path, PhotoTypes photoType) async {
    switch (photoType) {
      case PhotoTypes.normal:
        byte = await File(path).readAsBytes();
        return Image.file(File(path));
      case PhotoTypes.bilateralFilter:
        byte = await Cv2.bilateralFilter(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          diameter: 20,
          sigmaColor: 75,
          sigmaSpace: 75,
          borderType: Cv2.BORDER_DEFAULT,
        );
        return Image.memory(byte!);
      case PhotoTypes.dilate:
        byte = await Cv2.dilate(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          kernelSize: [3, 3],
        );
        return Image.memory(byte!);
      case PhotoTypes.filter2D:
        byte = await Cv2.filter2D(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          outputDepth: -1,
          kernelSize: [2, 2],
        );
        return Image.memory(byte!);
      case PhotoTypes.medianBlur:
        byte = await Cv2.medianBlur(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          kernelSize: 19,
        );
        return Image.memory(byte!);
      case PhotoTypes.morphologyEx:
        byte = await Cv2.morphologyEx(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          operation: Cv2.MORPH_TOPHAT,
          kernelSize: [5, 5],
        );
        return Image.memory(byte!);
      case PhotoTypes.pyrMeanShiftFiltering:
        byte = await Cv2.pyrMeanShiftFiltering(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          spatialWindowRadius: 20,
          colorWindowRadius: 20,
        );
        return Image.memory(byte!);
      case PhotoTypes.scharr:
        byte = await Cv2.scharr(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          depth: Cv2.CV_SCHARR,
          dx: 0,
          dy: 1,
        );
        return Image.memory(byte!);
      case PhotoTypes.threshold:
        byte = await Cv2.threshold(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          thresholdValue: 150,
          maxThresholdValue: 200,
          thresholdType: Cv2.THRESH_BINARY,
        );

        return Image.memory(byte!);
      case PhotoTypes.adaptiveThreshold:
        byte = await Cv2.adaptiveThreshold(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          maxValue: 125,
          adaptiveMethod: Cv2.ADAPTIVE_THRESH_MEAN_C,
          thresholdType: Cv2.THRESH_BINARY,
          blockSize: 11,
          constantValue: 12,
        );
        return Image.memory(byte!);
      case PhotoTypes.cvtColor:
        byte = await Cv2.cvtColor(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          outputType: Cv2.COLOR_BGR2GRAY,
        );
        return Image.memory(byte!);
      case PhotoTypes.applyColorMap:
        byte = await Cv2.applyColorMap(
          pathFrom: CVPathFrom.GALLERY_CAMERA,
          pathString: path,
          colorMap: Cv2.COLORMAP_JET,
        );
        return Image.memory(byte!);
    }
  }
}
