package;

import cpp.vm.Debugger;
import cpp.vm.Deque;
import cpp.vm.Mutex;
import cpp.vm.Thread;

import haxe.io.Input;
import haxe.io.Bytes;
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
/*import many.A25;
import many.A26;
import many.A27;
import many.A28;
import many.A29;
import many.A30;
import many.A31;
import many.A32;
import many.A33;*/


class Main {
  static function main() {

    var a001:A001 = new A001();
    var a002:A002 = new A002();
    var a3:A3 = new A3();
    var a4:A4 = new A4();


    serializer_test();

  }
  
    private static function filesToList(files:Array<String>) : StringList
    {
        trace("files returned by the debugger:");
        trace(files);
        var list : StringList = Terminator;

        // Preserve order
        for (f in 0...files.length) {
            list = Element(files[files.length-1-f], list);
        }
        trace("list:");
        trace(list);
        return list;
    }

    private static function files() : Message
    {
        // Preserve order to match filesFullPath
        return Files( filesToList( Debugger.getFiles() ) );
    }

  static function serializer_test() {
      var value = files();
      trace("value returned by files():");
      trace(value);
      var string = haxe.Serializer.run(value);
  }

}


/**
 * This enum defines all of the commands that can be sent to a debugger
 * thread.  For each command, a comment gives the set of response messages
 * that can be expected for that command.
 **/
enum Command
{
    Exit;
    // Response: Exited

    Detach;
    // Response: Detached

    Files;
    // Response: Files

    FilesFullPath;
    // Response: Files

    AllClasses;
    // Response: AllClasses

    Classes(continuation : Null<String>);
    // Response: Classes

    Mem;
    // Response: MemBytes

    Compact;
    // Response: Compacted

    Collect;
    // Response: Collected

    SetCurrentThread(number : Int);
    // Response: ThreadLocation, OK, ErrorNoSuchThread

    AddFileLineBreakpoint(fileName : String, lineNumber : Int);
    // Response: FileLineBreakpointNumber, ErrorNoSuchFile

    AddClassFunctionBreakpoint(className : String, functionName : String);
    // Response: ClassFunctionBreakpointNumber, ErrorBadClassNameRegex,
    // ErrorBadFunctionNameRegex, ErrorNoMatchingFunctions

    ListBreakpoints(enabled : Bool, disabled : Bool);
    // Response: Breakpoints

    DescribeBreakpoint(number : Int);
    // Response: BreakpointDescription, ErrorNoSuchBreakpoint

    DisableAllBreakpoints;
    // Response: BreakpointStatuses

    DisableBreakpointRange(first : Int, last: Int);
    // Response: BreakpointStatuses

    EnableAllBreakpoints;
    // Response: BreakpointStatuses

    EnableBreakpointRange(first : Int, last: Int);
    // Response: BreakpointStatuses

    DeleteAllBreakpoints;
    // Response: BreakpointStatuses

    DeleteBreakpointRange(first : Int, last: Int);
    // Response: BreakpointStatuses

    DeleteFileLineBreakpoint(fileName : String, lineNumber : Int);
    // Response: BreakpointStatuses

    BreakNow;
    // Response: OK

    Continue(count : Int);
    // Response: OK, ErrorBadCount

    Step(count : Int);
    // Response: OK, ErrorCurrentThreadNotStopped, ErrorBadCount

    Next(count : Int);
    // Response: OK, ErrorCurrentThreadNotStopped, ErrorBadCount

    Finish(count : Int);
    // Response: OK, ErrorCurrentThreadNotStopped, ErrorBadCount

    WhereCurrentThread(unsafe : Bool);
    // Response: ThreadsWhere, ErrorCurrentThreadNotStopped

    WhereAllThreads;
    // Response: ThreadsWhere

    Up(count : Int);
    // Response: ThreadLocation, ErrorCurrentThreadNotStopped, ErrorBadCount

    Down(count : Int);
    // Response: ThreadLocation, ErrorCurrentThreadNotStopped, ErrorBadCount

    SetFrame(number : Int);
    // Response: ThreadLocation, ErrorCurrentThreadNotStopped, ErrorBadCount

    Variables(unsafe : Bool);
    // Response: Variables, ErrorCurrentThreadNotStopped

    PrintExpression(unsafe : Bool, expression : String);
    // Response: Value, ErrorCurrentThreadNotStopped, ErrorEvaluatingExpression

    SetExpression(unsafe: Bool, lhs : String, rhs : String);
    // Response: Value, ErrorCurrentThreadNotStopped, ErrorEvaluatingExpression

    GetStructured(unsafe : Bool, expression : String);
    // Response: Structured, ErrorCurrentThreadNotStopped,
    // ErrorEvaluatingExpression
}


/**
 * A list of strings
 **/
enum StringList
{
    Terminator;
    Element(string : String, next : StringList);
}


/**
 * A list of class, possibly truncated so as not to be too large.
 * If truncated, a subsequent query for the remainder of the list can be done
 * using the continued expression.
 **/
enum ClassList
{
    Terminator;
    Continued(continuation : String);
    Element(className : String, hasStatics : Bool, next : ClassList);
}


/**
 * A list of breakpoints
 **/
enum BreakpointList
{
    Terminator;
    Breakpoint(number : Int, description : String, enabled : Bool,
               multi : Bool, next : BreakpointList);
}


/**
 * A list of locations at which a breakpoint breaks
 **/
enum BreakpointLocationList
{
    Terminator;
    FileLine(fileName : String, lineNumber : Int,
             next : BreakpointLocationList);
    ClassFunction(className : String, functionName : String,
                  next : BreakpointLocationList);
}


/**
 * A list of breakpoint status that results from disabling, enabling, or
 * deleting breakpoints
 **/
enum BreakpointStatusList
{
    Terminator;
    Nonexistent(number : Int, next : BreakpointStatusList);
    Disabled(number : Int, next : BreakpointStatusList);
    AlreadyDisabled(number : Int, next : BreakpointStatusList);
    Enabled(number : Int, next : BreakpointStatusList);
    AlreadyEnabled(number : Int, next : BreakpointStatusList);
    Deleted(number : Int, next : BreakpointStatusList);
}


/**
 * Status of a thread
 **/
enum ThreadStatus
{
    Running;
    StoppedImmediate;
    StoppedBreakpoint(number : Int);
    StoppedUncaughtException;
    StoppedCriticalError(description : String);
}


/**
 * A list of call stack frames of a thread
 **/
enum FrameList
{
    Terminator;
    Frame(isCurrent : Bool, number : Int, className : String,
          functionName : String, fileName : String, lineNumber : Int,
          next : FrameList);
}


/**
 * Information about why and where a thread has stopped
 **/
enum ThreadWhereList
{
    Terminator;
    Where(number : Int, status : ThreadStatus, frameList : FrameList,
          next : ThreadWhereList);
}


/**
 * The type of a value that can be included in a StructuredValue
 **/
enum StructuredValueType
{
    TypeNull;
    TypeBool;
    TypeInt;
    TypeFloat;
    TypeString;
    TypeInstance(className : String);
    TypeEnum(enumName : String);
    TypeAnonymous(elements : StructuredValueTypeList);
    TypeClass(className : String);
    TypeFunction;
    TypeArray;
}


/**
 * A list of structured value types
 **/
enum StructuredValueTypeList
{
    Terminator;
    _Type(type : StructuredValueType, next : StructuredValueTypeList);
}


/**
 * Types of value containers
 **/
enum StructuredValueListType
{
    Anonymous;
    Instance(className : String);
    _Array;
    Class;
}


/**
 * A list of structured values
 **/
enum StructuredValueList
{
    Terminator;
    Element(name : String, value : StructuredValue, next : StructuredValueList);
}


/**
 * A structured value, which includes both the type of the value, and a
 * structured representation of the value
 **/
enum StructuredValue
{
    // Elided means that the actual value is not presented; its type is
    // presented, but the value can only be obtained by issuing a
    // GetStructured command with the given getExpression.
    Elided(type : StructuredValueType, getExpression : String);
    // A single value.
    Single(type : StructuredValueType, value : String);
    // A list of values
    List(type : StructuredValueListType, list : StructuredValueList);
}


/**
 * Messages are delivered by the debugger thread in response to Commands and
 * also spuriously for thread events.
 **/
enum Message
{
    // Errors
    ErrorInternal(details : String);
    ErrorNoSuchThread(number : Int);
    ErrorNoSuchFile(fileName : String);
    ErrorNoSuchBreakpoint(number : Int);
    ErrorBadClassNameRegex(details : String);
    ErrorBadFunctionNameRegex(details : String);
    ErrorNoMatchingFunctions(className : String, functionName : String,
                             unresolvableClasses : StringList);
    ErrorBadCount(count : Int);
    ErrorCurrentThreadNotStopped(threadNumber : Int);
    ErrorEvaluatingExpression(details : String);

    // Normal messages
    OK;
    Exited;
    Detached;
    Files(list : StringList);
    AllClasses(list : StringList);
    Classes(list : ClassList);
    MemBytes(bytes : Int);
    Compacted(bytesBefore : Int, bytesAfter : Int);
    Collected(bytesBefore : Int, bytesAfter : Int);
    ThreadLocation(number : Int, stackFrame : Int, className : String,
                   functionName : String, fileName : String, lineNumber : Int);
    FileLineBreakpointNumber(number : Int);
    ClassFunctionBreakpointNumber(number : Int, 
                                  unresolvableClasses : StringList);
    Breakpoints(list : BreakpointList);
    BreakpointDescription(number : Int, list : BreakpointLocationList);
    BreakpointStatuses(list : BreakpointStatusList);
    ThreadsWhere(list : ThreadWhereList);
    Variables(list : StringList);
    Value(expression : String, type : String, value : String);
    Structured(structuredValue : StructuredValue);

    // Asynchronously delivered on thread events
    ThreadCreated(number : Int);
    ThreadTerminated(number : Int);
    ThreadStarted(number : Int);
    ThreadStopped(number : Int, stackFrame : Int,
                  className : String, functionName : String,
                  fileName : String, lineNumber : Int);
}