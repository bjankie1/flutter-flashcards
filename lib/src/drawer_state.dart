import 'package:flutter/foundation.dart';

class DrawerState extends ChangeNotifier {
  bool _isDrawerOpen = false;

  bool get isDrawerOpen => _isDrawerOpen;

  void openDrawer() {
    _isDrawerOpen = true;
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    notifyListeners();
  }
}