package;

import many.A001;
import many.A002;
import many.A3;
import many.A4;
import many.A5;
import many.A6;
import many.A7;
import many.A8;
import many.A9;
import many.A10;
import many.A11;
import many.A12;
import many.A13;
import many.A14;
import many.A15;
import many.A16;
import many.A17;
import many.A18;
import many.A19;
import many.A20;
import many.A21;
import many.A22;
import many.A23;
import many.A24;
// import many.A25;
// import many.A26;
// import many.A27;
// import many.A28;
// import many.A29;
// import many.A30;
// import many.A31;
// import many.A32;
// import many.A33;


#if debug
import debugger.HaxeRemote;
#end

class Main {
  static function main() {
#if debug
    new debugger.HaxeRemote(true, "localhost");
    //new debugger.Local(true);
#end

    var a001:A001 = new A001();
  }
}
