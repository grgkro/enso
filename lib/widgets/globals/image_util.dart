import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'enso_circular_progress_indicator.dart';

class ImageUtil {
  static CachedNetworkImage ensoCachedImage(
      String imageUrl, String errorImagePath) {
    return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) {
          return const EnsoCircularProgressIndicator();
        },
        errorWidget: (context, url, error) {
          log('ERROR: could not load image, going to show placeholder instead. url: ${url}, error: ${error.toString()}');
          return Image.asset('assets/img/placeholder_item.png');
        });
  }

  // static String getItemImageUrl() {
  //   String url = "";
  //   if (widget.selectedBox.item_images != null &&
  //       widget.selectedBox.item_images!.isNotEmpty) {
  //     url = widget.selectedBox.item_images!.first;
  //   } else {
  //     url = 'https://enso-box.s3.eu-central-1.amazonaws.com/Allura+-+Park.png';
  //   }
  //   return url;
  // }
}
