# Java interop — fast collection recipes

BBj interoperates directly with Java classes; these one-liners avoid hand-rolled loops.

## Loading list controls (BBjListButton / BBjListEdit / BBjListBox)

These controls take a linefeed-delimited (`$0a$`) string of options.

From a BBjVector:
```bbj
options! = java.lang.String.join($0a$, java.util.Arrays.asList(myVector!))
myListEdit! = myWindow!.addListEdit(myWindow!.getAvailableControlID(), x, y, w, h, options!)

REM or, casting the vector directly:
myListButton! = win!.addListButton(String.join($0a$, cast(Iterable, myVector!)))
```

From a HashMap's keys or values:
```bbj
options! = java.lang.String.join($0a$, myHashMap!.keySet())    REM keys
options! = java.lang.String.join($0a$, myHashMap!.values())    REM values
```

## BBjVector ⇄ strings and Java collections

Fill a BBjVector with a map's keys:
```bbj
vect! = BBjAPI().makeVector()
vect!.addAll(hash!.keySet())
```

BBjVector → comma-delimited string:
```bbj
method protected BBjString getBBjVectorAsString(BBjVector vector!)
    methodret String.join(",", cast(Iterable, vector!))
methodend
```

Fill a BBjVector by splitting a string (comma or linefeed delimiter):
```bbj
declare BBjVector colorVector!
colorVector! = BBjAPI().makeVector()
colorVector!.addAll(java.util.Arrays.asList(p_colorString!.split(",")))

declare BBjVector textLines!
textLines! = BBjAPI().makeVector()
textLines!.addAll(java.util.Arrays.asList(text!.split($0a$)))
```

## HashMap / TreeMap patterns

LinkedHashMap keys in reverse order as a linefeed-delimited string (e.g. MRU list for a list control):
```bbj
method public BBjString getMruForListButton(LinkedHashMap mru!)
    list! = new java.util.ArrayList(mru!.keySet())
    java.util.Collections.reverse(list!)
    methodret java.lang.String.join($0a$, list!)
methodend
```

Last key from a Map:
```bbj
method private Object getLastMapKey(Map map!)
    stream! = map!.keySet().stream()
    lastIndex = new java.lang.Long(stream!.count() - 1)
    methodret stream!.skip(lastIndex).findFirst().get()
methodend
```

TreeMap for sorted maps (optionally case-insensitive):
```bbj
use java.util.TreeMap
use java.lang.String

treeMap! = new TreeMap()                            REM sorted by natural key order
treeMap! = new TreeMap(String.CASE_INSENSITIVE_ORDER)   REM case-insensitive sorting
```

Documentation links:
- BBjVector: https://documentation.basis.cloud/BASISHelp/WebHelp/gridctrl/bbjvector_bbj.htm
- Java Collection: https://docs.oracle.com/javase/8/docs/api/java/util/Collection.html
- Java List: https://docs.oracle.com/javase/8/docs/api/java/util/List.html
