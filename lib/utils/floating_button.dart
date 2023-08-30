

import 'dart:ui';

import 'package:flutter/material.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double xOffset;
  final double yOffset;

  const CustomFloatingActionButtonLocation({
    this.xOffset = 0,
    this.yOffset = 0,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width * 0.5 + xOffset;
    final double fabY = scaffoldGeometry.contentTop - yOffset;
    return Offset(fabX, fabY);
  }
}
