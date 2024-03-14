import 'package:flutter/material.dart';

class RawImageProvider with ChangeNotifier {
  int width = 0;
  int height = 0;
  int curidx = 0;
  int maxidx = 1;

  void setIdx(int idx){
    curidx = idx;
  }

  void setImageSize(int wid, int hit) {
    width = wid;
    height = hit;
  }
}
