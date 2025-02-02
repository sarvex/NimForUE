import std/[sequtils, options, sugar, strutils, strformat, typetraits, macros]


type
  FieldKind* = enum
    Int, Float, String, Struct, Array
  
  RuntimeField* = object
    case kind*: FieldKind
    of Int:
      intVal*: int
    of Float:
      floatVal*: float
    of String:
      stringVal*: string
    of Struct:
      structVal*: RuntimeStruct
    of Array: 
      arrayVal*: seq[RuntimeField]
    
  RuntimeStruct* = seq[(string, RuntimeField)]
 
  UEFunc* = object #Light metadata we could ue UFunc but we dont want to pull all those types into the vm
    name* : string
    className* : string

   
  UECall* = object
    fn* : UEFunc 
    self* : int
    value* : RuntimeField #On uebind [name] = value #let's just do runtimeFields only for now and then we can put an object in here, although a field may contain an object
  
  #should args be here too?
  UEBorrowInfo* = object
    fnName*: string #nimName 
    className* : string
    ueActualName* : string #in case it has Received or some other prefix




# func toRuntimeField*[T](value : T) : RuntimeField 
func add*(rtField : var RuntimeField, name : string, value : RuntimeField) = 
  case rtField.kind:
  of Struct:
    rtField.structVal.add((name, value))
  else:
    raise newException(ValueError, "rtField is not a struct")

func getInt*(rtField : RuntimeField) : int = 
  case rtField.kind:
  of Int:
    return rtField.intVal
  else:
    raise newException(ValueError, "rtField is not an int")

func getFloat*(rtField : RuntimeField) : float =
  case rtField.kind:
  of Float:
    return rtField.floatVal
  else:
    raise newException(ValueError, "rtField is not a float")

func getStr*(rtField : RuntimeField) : string =
  case rtField.kind:
  of String:
    return rtField.stringVal
  else:
    raise newException(ValueError, "rtField is not a string")

func getStruct*(rtField : RuntimeField) : RuntimeStruct =
  case rtField.kind:
  of Struct:
    return rtField.structVal
  else:
    raise newException(ValueError, "rtField is not a struct")

func getArray*(rtField : RuntimeField) : seq[RuntimeField] =
  case rtField.kind:
  of Array:
    return rtField.arrayVal
  else:
    raise newException(ValueError, "rtField is not an array")

func setInt*(rtField : var RuntimeField, value : int) = 
  case rtField.kind:
  of Int:
    rtField.intVal = value
  else:
    raise newException(ValueError, "rtField is not an int")

func setFloat*(rtField : var RuntimeField, value : float) =
  case rtField.kind:
  of Float:
    rtField.floatVal = value
  else:
    raise newException(ValueError, "rtField is not a float")

func setStr*(rtField : var RuntimeField, value : string) =
  case rtField.kind:
  of String:
    rtField.stringVal = value
  else:
    raise newException(ValueError, "rtField is not a string")
func setStruct*(rtField : var RuntimeField, value : RuntimeStruct) =
  case rtField.kind:
  of Struct:
    rtField.structVal = value
  else:
    raise newException(ValueError, "rtField is not a struct")
func setArray*(rtField : var RuntimeField, value : seq[RuntimeField]) =
  case rtField.kind:
  of Array:
    rtField.arrayVal = value
  else:
    raise newException(ValueError, "rtField is not an array")


func `[]`*(rtField : RuntimeField, name : string) : RuntimeField = 
  case rtField.kind:
  of Struct:
    for (key, value) in rtField.structVal:
      if key == name:
        return value
    raise newException(ValueError, "Field " & name & " not found in struct")
  else:
    raise newException(ValueError, "rtField is not a struct")

func `[]`*(rtField : RuntimeField, idx : int) : RuntimeField = 
  case rtField.kind:
  of Array: #Support structs too? And what about the others only for 0?
    return rtField.arrayVal[idx]
  else:
    raise newException(ValueError, "rtField is not an array therefore not indexable ")

func contains*(rtField : RuntimeField, name : string) : bool = 
  case rtField.kind:
  of Struct:
    for (key, value) in rtField.structVal:
      if key == name:
        return true
  else:
    raise newException(ValueError, "rtField is not a struct")


macro getField(obj: object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))


# func toRuntimeFieldHook*[T](value : T) : RuntimeField = toRuntimeField*[T](value : T)
proc runtimeFieldTo*(rtField : RuntimeField, T : typedesc) : T 
proc fromRuntimeField*[T](value: var T, rtField: RuntimeField) = 
  when compiles(fromRuntimeFieldHook(val,rtField)): 
    fromRuntimeFieldHook(a, rtField)
  else:
    const typeName = typeof(T).name
    case rtField.kind:
    of Int:
      when T is int | int8 | int16 | int32 | int64 | uint | uint8 | uint16 | uint32 | uint64 :
        # a = cast[T](b.intVal) #No cast in the vm
        value = T(rtField.intVal)
    of Float:
      when T is float | float32 | float64:
        # a = cast[T](b.floatVal) #NO cast in the vm
        value = T(rtField.floatVal)
    of String:
      when T is string:
        value = (rtField.stringVal)
    of Struct:
      when T is object:
        for fieldName, v in fieldPairs(value):
          value.getField(fieldName) = rtField[fieldName].runtimeFieldTo(typeof(v))
    of Array:
      when T is seq:
        for i in 0 ..< rtField.arrayVal.len:
          value.add(rtField.arrayVal[i].runtimeFieldTo(typeof(value[0])))
        

proc runtimeFieldTo*(rtField : RuntimeField, T : typedesc) : T = 
  var obj = default(T)
  fromRuntimeField(obj, rtField)
  obj

proc toRuntimeField*[T](value : T) : RuntimeField = 
  when compiles(toRuntimeFieldHook(value)): 
    return toRuntimeFieldHook(value)
  else:
    const typeName = typeof(T).name
    const isPtr = typeName.endsWith("Ptr")

    when isPtr or (T is int | int8 | int16 | int32 | int64 | uint | uint8 | uint16 | uint32 | uint64) :
      result.kind = Int
      result.intVal = cast[int](value)
    elif T is float | float32 | float64:
      result.kind = Float
      result.floatVal = value
    elif T is string:
      result.kind = String
      result.stringVal = value
    elif T is (object | tuple):
      result.kind = Struct
      for name, val in fieldPairs(value):
        result.structVal.add((name, toRuntimeField(val)))
    elif T is (array | seq):
      result.kind = Array
      for val in value:
        result.arrayVal.add(toRuntimeField(val))
    else:
      when compiles(UE_Error ""):
        UE_Error &"Unsupported {typeName} type for RuntimeField "
      else:
        debugEcho &"ERROR: Unsupported {typeName} type for RuntimeField"
      RuntimeField()
    # raise newException(ValueError, &"Unsupported {typename} type for RuntimeField ")
func initRuntimeField*[T](value : T) : RuntimeField = toRuntimeField(value)
