import 'package:flutter/material.dart';
import 'package:video_list/models/base_model.dart';
import 'circular_utils.dart';

Widget getMarkContainer(MarkType markType) {
  switch (markType) {
    case MarkType.advance:
      return getTextContainer("预告", backgroundColor: Colors.redAccent);
    case MarkType.advanced_request:
      return getTextContainer("超前点播", backgroundColor: Colors.orangeAccent);

    case MarkType.hynna_bubble_pop:
      return getTextContainer("独播", backgroundColor: Colors.orangeAccent);

    case MarkType.vip:
      return getTextContainer("VIP", backgroundColor: Colors.orangeAccent);

    case MarkType.self_made:
      return getTextContainer("自制", backgroundColor: Colors.redAccent);
  }
}

Icon getSignIcon(VideoSign sign, {double size}) {
  switch (sign) {
    case VideoSign.lightning:
      return Icon(
        Icons.nightlight_round,
        size: size,
        color: Colors.orangeAccent,
      );
    case VideoSign.hot:
      return Icon(
        Icons.whatshot_outlined,
        size: size,
        color: Colors.red,
      );

    case VideoSign.star:
      return Icon(
        Icons.star,
        size: size,
        color: Colors.orangeAccent,
      );

    case VideoSign.favorite:
      return Icon(
        Icons.favorite,
        size: size,
        color: Colors.red,
      );

    case VideoSign.sun:
      return Icon(
        Icons.wb_sunny,
        size: size,
        color: Colors.orangeAccent,
      );
  }
}

