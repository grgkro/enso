import 'dart:developer';

import 'package:ensobox/widgets/box_details_screen.dart';
import 'package:flutter/material.dart';

import '../models/locations.dart' as locations;

class BoxList extends StatefulWidget {
  const BoxList({Key? key}) : super(key: key);

  @override
  State<BoxList> createState() => _BoxListState();
}

class _BoxListState extends State<BoxList> {
  final List<locations.Box> _boxes = [];

  Future<void> _getBoxesFromAPI() async {
    var ensoBoxes = await locations.getBoxLocations();
    setState(() {
      for (final box in ensoBoxes.boxes) {
        _boxes.add(box);

        log("Hello" + box.id);
      }
    });
  }

  void selectCategory(BuildContext ctx, locations.Box selectedBox) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return BoxDetailsScreen(_boxes, selectedBox);
    }));
  }

  @override
  void initState() {
    _getBoxesFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: _boxes
          .map(
            (box) => Card(
              child: InkWell(
                onTap: () => selectCategory(context, box),
                splashColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Image.network(
                        box.image,
                        width: 100,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            box.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            box.address,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// Column(children: [

// Text(
// box.address,
// style: TextStyle(
// color: Colors.grey,
// ),
// ),
// ]
// ,
// ],
