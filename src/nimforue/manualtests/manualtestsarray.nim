#this is temp until we have tests working (have to bind dyn delegates first)
include ../unreal/prelude
import std/[times,strformat, strutils, options, sugar, sequtils, random]
import ../uetypegen

when defined withNimScripter:
    import nimscripter, nimscripter/[variables,vmops]


proc saySomething(obj:UObjectPtr, msg:FString) : void {.uebind.}

proc testArrays(obj:UObjectPtr) : TArray[FString] {.uebind.}

proc testMultipleParams(obj:UObjectPtr, msg:FString,  num:int) : FString {.uebind.}

proc boolTestFromNimAreEquals(obj:UObjectPtr, numberStr:FString, number:cint, boolParam:bool) : bool {.uebind.}

proc setColorByStringInMesh(obj:UObjectPtr, color:FString): void  {.uebind.}

var returnString = ""


proc printArray(obj:UObjectPtr, arr:TArray[FString]) =
    for str in arr: #add posibility to iterate over
        obj.saySomething(str) 

proc testArrayEntryPoint*(executor:UObjectPtr) =
    let msg = testMultipleParams(executor, "hola", 10)

    executor.saySomething(msg)
    executor.setColorByStringInMesh("(R=0,G=1,B=1,A=1)")

    if executor.boolTestFromNimAreEquals("5", 5, true) == true:
        executor.saySomething("true")
    else:
        executor.saySomething("false" & $ sizeof(bool))

    let arr = testArrays(executor)
    let number = arr.num()



    # let str = $arr.num(


    arr.add("hola")
    arr.add("hola2")
    let arr2 = makeTArray[FString]()
    arr2.add("hola3")
    arr2[0] = "hola3-replaced"

    arr2.add($now() & " is it Nim TIME?")

    # printArray(executor, arr)
    let lastElement : FString = arr2[0]
    # let lastElement = makeFString("")
    returnString = "number of elements " & $arr.num() & "the element last element is " & lastElement

    # let nowDontCrash = 
    # let msgArr = "The length of the array is " & $ arr.num()
    executor.saySomething(returnString)
    executor.printArray arr2

    executor.saySomething("length of the array5 is " & $ arr2.num())
    arr2.removeAt(0)
    arr2.remove("hola5")
    executor.saySomething("length of the array2 is after removed yeah " & $ arr2.num())


proc K2_SetActorLocation(obj:UObjectPtr, newLocation: FVector, bSweep:bool, SweepHitResult: var FHitResult, bTeleport: bool) {.uebind.}

proc testVectorEntryPoint*(executor:UObjectPtr) = 
    let v : FVector = makeFVector(10, 80, 100)
    let v2 = v+v 
    let position = makeFVector(1100, 1000, 150)
    var hitResult = makeFHitResult()
    K2_SetActorLocation(executor, position, false, hitResult, true)
    executor.saySomething(v2.toString())
    # executor.saySomething(upVector.toString())

    

    # if "TEnumAsByte" in cppType: #Not sure if it would be better to just support it on the macro
    #     return cppType.replace("TEnumAsByte<","")
    #                   .replace(">", "")


    # let nimType = cppType.replace("<", "[")
    #                      .replace(">", "]")
    #                      .replace("*", "Ptr")


    # let delProp = castField[FDelegateProperty](prop)
    # if not delProp.isNil():
    #     let signature = delProp.getSignatureFunction()
    #     var signatureAsStr = "ScriptDelegate["
    #     for prop in getFPropsFromUStruct(signature):
    #         let nimType = prop.getNimTypeAsStr()
    #         signatureAsStr = signatureAsStr & nimType & ","
    #     signatureAsStr[^1] = ']'
    #     return signatureAsStr


var isScriptVMLoaded = false
when defined withNimScripter:
    var intr : Option[Interpreter]
    proc funcInterop() = 
        # if isScriptVMLoaded: return
        isScriptVMLoaded = true
        
        addCallable(test3):
            proc fancyStuff(a: int)
            proc hello(a:string) # Has checks for the nimscript to ensure it's definition doesnt change to something unexpected.
            proc byRefFn(a : var string)
        const
            addins = implNimscriptModule(test3)
            script = NimScriptFile"""
    proc fancyStuff*(a: int) = assert a in [10, 300]
    proc hello*(a: string) = echo a
    proc byRefFn*(a: var string) = 
        a = "adios"

    """ # Notice `fancyStuff` is exported
        if intr.isNone():
            intr = loadScript(script, addins) # This adds in out checks for the proc
        intr.invoke(fancyStuff, 10) # Calls `fancyStuff(10)` in vm
        intr.invoke(fancyStuff, 300) # Calls `fancyStuff(300)` in vm
        intr.invoke(hello, "Hello") # Calls `hello("Hello")` in vm
        var varRef = "hello cant believe this" & $rand(500)
        intr.invoke(byRefFn, varRef) # Calls `ref(varRef)` in vm
        UE_Log(varRef)
        # echo $ build()



proc scratchpad*(executor:UObjectPtr) = 
    # # UE_Log("here we test back")
    # let moduleName = FString("Engine")
    # # let classes = getAllClassesFromModule(moduleName)
    # # for cls in classes:
    # let cls = getClassByName("MyClassToTest")
    # let ueType = cls.toUEType()
    # #     # UE_Log("UEType" & $ueType)
    # UE_Log("Class name" & cls.getName())
    # UE_Log("Engine classes " & $len(classes))
    discard
    when defined withNimScripter:
        funcInterop()

    discard
   
