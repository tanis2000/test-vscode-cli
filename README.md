## Steps to reproduce a crash:

```
# Compile hxcpp-debugger server
cd path/to/hxcpp-debugger
haxe -main debugger.HaxeServer -cpp ./Export -cp debugger

# Run hxcpp-debugger and let it emit "files" command once a program is connected
./Export/HaxeServer -host 127.0.0.1 -port 6972 <<< $'files\n'
```

In another terminal, build and run this repo's code:
```
haxe build.hxml
./export/Main-debug 
```

## Tested enviroment

```
$ sw_vers
ProductName:	Mac OS X
ProductVersion:	10.11.2
BuildVersion:	15C50
$ haxe -version
3.3.0 (git build development @ 8c3934e)
$ haxelib list | grep hxcpp
debugger: [dev:/Users/andy/Documents/workspace/hxcpp-debugger]
hxcpp: 3.1.39 3.1.68 3.2.37 3.2.94 [3.2.205]
$ g++ --version
Configured with: --prefix=/Applications/Xcode.app/Contents/Developer/usr --with-gxx-include-dir=/usr/include/c++/4.2.1
Apple LLVM version 7.0.2 (clang-700.1.81)
Target: x86_64-apple-darwin15.2.0
Thread model: posix
```