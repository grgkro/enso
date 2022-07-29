import 'dart:collection';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ensobox/models/item.dart';
import 'package:flutter/material.dart';

import '../models/locations.dart' as locations;
import 'globals/image_util.dart';
import 'item_details_screen.dart';

class BoxList extends StatefulWidget {
  const BoxList({Key? key}) : super(key: key);

  @override
  State<BoxList> createState() => _BoxListState();
}

class _BoxListState extends State<BoxList> {
  final List<locations.Box> _boxes = [];
  final List<Item> _items = [];
  HashMap itemsBoxMap =
      HashMap<int, int>(); // _items[3] belongs to _boxes[1] -> <3,1>

  Future<void> _getBoxesFromAPI() async {
    var ensoBoxes = await locations.getBoxLocations();
    setState(() {
      int counterBoxes = 0;
      int counterItems = 0;
      for (final box in ensoBoxes.boxes) {
        _boxes.add(box);
        if (box.items != null) {
          for (final item in box.items!) {
            if (item != null) {
              _items.add(item);
              itemsBoxMap[counterItems] = counterBoxes;
              counterItems++;
            }
          }
        }
        counterBoxes++;

        log("Hello" + itemsBoxMap.toString());
      }
    });
  }

  void selectCategory(
      BuildContext ctx, locations.Box selectedBox, Item selectedItem) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return ItemDetailsScreen(_boxes, selectedBox, selectedItem);
    }));
  }

  @override
  void initState() {
    _getBoxesFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () => selectCategory(
                context, _boxes[itemsBoxMap[index]], _items[index]),
            splashColor: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * .1,
                    width: MediaQuery.of(context).size.width * 0.2,
                    // padding: const EdgeInsets.only(bottom: 30),
                    child: ImageUtil.ensoCachedImage(
                        _items[index].item_images!.first,
                        'assets/img/placeholder_item.png'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _items[index].name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _boxes[itemsBoxMap[index]].name,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _boxes[itemsBoxMap[index]].address,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //   return ListView(
  //     shrinkWrap: true,
  //     scrollDirection: Axis.vertical,
  //     children: _boxes
  //         .map(
  //           (box) => Card(
  //             child: InkWell(
  //               onTap: () => selectCategory(context, box),
  //               splashColor: Theme.of(context).primaryColor,
  //               borderRadius: BorderRadius.circular(15),
  //               child: Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.black, width: 1),
  //                 ),
  //                 padding: const EdgeInsets.all(10),
  //                 child: Row(
  //                   children: <Widget>[
  //                     Image.network(
  //                       box.image,
  //                       width: 100,
  //                       height: 100,
  //                       fit: BoxFit.contain,
  //                       frameBuilder: (_, image, loadingBuilder, __) {
  //                         if (loadingBuilder == null) {
  //                           return const SizedBox(
  //                             height: 100,
  //                             child: Center(child: CircularProgressIndicator()),
  //                           );
  //                         }
  //                         return image;
  //                       },
  //                       loadingBuilder: (BuildContext context, Widget image,
  //                           ImageChunkEvent? loadingProgress) {
  //                         if (loadingProgress == null) return image;
  //                         return SizedBox(
  //                           height: 100,
  //                           child: Center(
  //                             child: CircularProgressIndicator(
  //                               value: loadingProgress.expectedTotalBytes !=
  //                                       null
  //                                   ? loadingProgress.cumulativeBytesLoaded /
  //                                       loadingProgress.expectedTotalBytes!
  //                                   : null,
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                       // errorBuilder: (_, __, ___) => Image.asset(
  //                       //   AppImages.withoutPicture,
  //                       //   height: 300,
  //                       //   fit: BoxFit.fitHeight,
  //                       // ),
  //                     ),
  //                     SizedBox(
  //                       width: 10,
  //                     ),
  //                     Column(
  //                       children: [
  //                         Text(
  //                           box.name,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 15,
  //                           ),
  //                         ),
  //                         Text(
  //                           box.address,
  //                           style: TextStyle(
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )
  //         .toList(),
  //   );
  // }

  CachedNetworkImage buildBigCoverImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 100,
      height: 100,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
