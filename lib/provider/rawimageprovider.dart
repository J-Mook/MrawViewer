import 'package:flutter/material.dart';

class RawImageProvider with ChangeNotifier {
  int width = 0;
  int height = 0;
  int curidx = 0;
  int maxidx = 1;
  bool ishoverImage = true;

  void setHover(bool bbb){
    if(ishoverImage != bbb){
      notifyListeners();
    }
    ishoverImage = bbb;
    // notifyListeners();
  }

  void setIdx(int idx){
    // if(curidx != idx)
    //   notifyListeners();
    curidx = idx;
  }

  void setImageSize(int wid, int hit) {
    width = wid;
    height = hit;
  }
}
