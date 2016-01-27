class Main {
    static function main() {
        for (k in 0...100) {
            var files = [for (i in 0...k) "foo"];
            var list : StringList = Terminator;
            for (f in 0...files.length) {
                list = Element("foo", list);
            }
            trace("Testing with " + k);
            trace(list);
        }
    }
}

enum StringList {
    Terminator;
    Element(string : String, next : StringList);
}