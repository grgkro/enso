import 'package:ensobox/models/locations.dart';
import 'package:flutter/widgets.dart';

class Boxes with ChangeNotifier {
  List<Box> _boxes = [];

  List<Box> get boxes {
    // if we directly returned _boxes, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return [..._boxes];
  }

  void addBox(Box box) {
    // _boxes.add(box);
    notifyListeners();
  }
}
