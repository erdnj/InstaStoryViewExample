import 'package:flutter/foundation.dart';

class PageChangeNotifier extends ChangeNotifier{
  double value;
  PageChangeNotifier({required  this.value});

  void setValue(double newValue){
    value = newValue;
    notifyListeners();
  }

}