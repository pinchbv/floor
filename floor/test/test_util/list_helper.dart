import 'dart:typed_data';

class ListHelper{
  static bool deepEquals(final Uint8List l1,final Uint8List l2){
    if(identical(l1,l2)){
      return true;
    }
    if(l1 == null || l2 == null){
      return false;
    }
    if(l1.length!=l2.length) {
      return false;
    }
    for(int i=0; i < l1.length ; ++i) {
      if (l1.elementAt(i) != l2.elementAt(i)) {
        return false;
      }
    }
    return true;
  }
}

