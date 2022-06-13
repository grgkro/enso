import 'package:ensobox/widgets/box_details_screen.dart';
import 'package:flutter/material.dart';

import '../models/locations.dart' as locations;

class BoxList extends StatefulWidget {
  const BoxList({Key? key}) : super(key: key);

  @override
  State<BoxList> createState() => _BoxListState();
}

class _BoxListState extends State<BoxList> {
  final List<locations.Box> _boxes = [
    locations.Box(
        address: "address",
        uuid: "uuid",
        image: "image",
        lat: 9.9,
        lng: 1.0,
        name: "name",
        owner_phone: "owner_phone",
        state: "state"),
    locations.Box(
        address: "address2",
        uuid: "uuid2",
        image: "image",
        lat: 9.9,
        lng: 2.0,
        name: "name2",
        owner_phone: "owner_phone",
        state: "state"),
    locations.Box(
        address: "address",
        uuid: "uuid",
        image: "image",
        lat: 9.9,
        lng: 1.0,
        name: "name",
        owner_phone: "owner_phone",
        state: "state"),
    locations.Box(
        address: "address2",
        uuid: "uuid2",
        image: "image",
        lat: 9.9,
        lng: 2.0,
        name: "name2",
        owner_phone: "owner_phone",
        state: "state"),
    locations.Box(
        address: "address",
        uuid: "uuid",
        image: "image",
        lat: 9.9,
        lng: 1.0,
        name: "name",
        owner_phone: "owner_phone",
        state: "state"),
    locations.Box(
        address: "address2",
        uuid: "uuid2",
        image: "image",
        lat: 9.9,
        lng: 2.0,
        name: "name2",
        owner_phone: "owner_phone",
        state: "state")
  ];

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return BoxDetailsScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: _boxes
          .map((box) => Card(
                  child: Row(children: <Widget>[
                InkWell(
                  onTap: () => selectCategory(context),
                  splashColor: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      box.image,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
                Column(children: [
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
                ]),
              ])))
          .toList(),
    );
  }
}
