part of dart.core;

class Instrument {
  Instrument() {}
  static void doPrint() { 
    print("runtime_print_works"); 
  }

  static void printSomething(String str) {
    print("I AM PRINTING THE FOLLOWING: $str");
  }

  static int test() {
    return 0;
  }
}
