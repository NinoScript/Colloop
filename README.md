# Colloop
Simple co-routine like mechanism for Swift Collections

Imagine you have a large collection on your hands and you need to process all of the data in such collection. 
For example linear search on non sorted collection.

Colloop let's you process the collection in chunks. You can define if you want to process the collection in steps:
```
 ["1", "2", "3"].colloop(withStep: 2){ o in results.append("\(o)_") }
```
Or constrained by time:
```
 ["a", "b", "c"].colloop(withDeltaTime: 0.0000001){ o in results.append("\(o)_") }
```

The implementation is very simple. For usage please consult the unit tests.
