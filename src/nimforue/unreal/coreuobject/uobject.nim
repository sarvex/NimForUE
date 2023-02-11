
include ../definitions
import ../Core/Containers/[unrealstring, array, map]
import ../Core/ftext
import nametypes
import std/[genasts, options, strformat, macros, sequtils]
import ../../utils/utils
import uobjectflags
import sugar
export uobjectflags


type 
    
    FField* {. importcpp, inheritable, pure .} = object 
        next*  {.importcpp:"Next".} : ptr FField
    FFieldPtr* = ptr FField 
    FProperty* {. importcpp, inheritable,  header:ueIncludes, pure.} = object of FField 
    FPropertyPtr* = ptr FProperty
    UObject* {.importcpp, inheritable, pure, header:ueIncludes .} = object #TODO Create a macro that takes the header path as parameter?
    UObjectPtr* = ptr UObject #This can be autogenerated by a macro

    UField* {.importcpp, inheritable, pure .} = object of UObject
        Next* : ptr UField #Next Field in the linked list 
    UFieldPtr* = ptr UField 

    UEnum* {.importcpp, inheritable, pure .} = object of UField
    UEnumPtr* = ptr UEnum
   

    UStruct* {.importcpp, inheritable, pure .} = object of UField
        Children* : UFieldPtr # Pointer to start of linked list of child fields */
        childProperties* {.importcpp:"ChildProperties".}: FFieldPtr #  /** Pointer to start of linked list of child fields */
        propertyLink* {.importcpp:"PropertyLink".}: FPropertyPtr #  /** 	/** In memory only: Linked list of properties from most-derived to base */

    UStructPtr* = ptr UStruct 

    FObjectInitializer* {.importcpp.} = object
    FReferenceCollector* {.importcpp.} = object

    #Notice this is not really the signature. It has const 
    UClassConstructor* = proc (objectInitializer:var FObjectInitializer) : void {.cdecl.}
    VTableConstructor* = proc (helper:var FVTableHelper) : UObjectPtr  {.cdecl.}
    UClassAddReferencedObjectsType* = proc (obj:UObjectPtr, collector:var FReferenceCollector) : void {.cdecl.}
    FImplementedInterface* {.importcpp.} = object
        class* {.importcpp:"Class".}: UClassPtr
        
    UClass* {.importcpp, inheritable, pure .} = object of UStruct
        classWithin* {.importcpp:"ClassWithin".}: UClassPtr #  The required type for the outer of instances of this class */
        classConfigName* {.importcpp:"ClassConfigName".}: FName 
        classFlags* {.importcpp:"ClassFlags".}: EClassFlags
        classCastFlags* {.importcpp:"ClassCastFlags".}: EClassCastFlags
        classConstructor* {.importcpp:"ClassConstructor".}: UClassConstructor
        classVTableHelperCtorCaller* {.importcpp:"ClassVTableHelperCtorCaller".}: VTableConstructor
        addReferencedObjects* {.importcpp:"AddReferencedObjects".}: UClassAddReferencedObjectsType
        interfaces* {.importcpp:"Interfaces".}: TArray[FImplementedInterface]

    UClassPtr* = ptr UClass
    UInterface* {.importcpp, inheritable, pure .} = object of UObject
    UInterfacePtr* = ptr UInterface

    UScriptStruct* {.importcpp, inheritable, pure .} = object of UStruct
        structFlags* {.importcpp:"StructFlags".}: EStructFlags
    UScriptStructPtr* = ptr UScriptStruct


    UFunction* {.importcpp, inheritable, pure .} = object of UStruct
        functionFlags* {.importcpp:"FunctionFlags".} : EFunctionFlags
        numParms* {.importcpp:"NumParms".}: uint8
        parmsSize* {.importcpp:"ParmsSize".}: uint16
    UFunctionPtr* = ptr UFunction
    UDelegateFunction* {.importcpp, inheritable, pure .} = object of UFunction
    UDelegateFunctionPtr* = ptr UDelegateFunction

    TObjectPtr*[out T ] {.importcpp.} = object 
    TLazyObjectPtr*[out T ] {.importcpp.} = object 
    TEnumAsByte*[T : enum] {.importcpp.} = object

    TWeakObjectPtr*[out T] {.importcpp.} = object
    TScriptInterface*[out T] {.importcpp.} = object

    UWorld* {.importcpp, pure, header:ueIncludes .} = object of UObject
    UWorldPtr* = ptr UWorld

    ConstructorHelpers* {.importcpp, pure .} = object
    FObjectFinder*[T] {.importcpp, pure .} = object
      obj* {.importcpp:"Object".} : ptr T

    FClassFinder*[T] {.importcpp:"ConstructorHelpers::FClassFinder<'0>", nodecl, pure .} = object
      class* {.importcpp:"Class".} : TSubclassOf[T]

    TSubclassOf*[out T]  {. importcpp: "TSubclassOf<'0>".} = object

    FVTableHelper* {.importcpp, pure.} = object


proc makeFImplementedInterface*(class: UClassPtr, offset:int32 = 0, implementedByK2:bool = true) : FImplementedInterface {.importcpp:"FImplementedInterface(@)", constructor.}


proc castField*[T : FField ](src:FFieldPtr) : ptr T {. importcpp:"CastField<'*0>(#)" .}
proc ueCast*[T : UObject ](src:UObjectPtr) : ptr T {. importcpp:"Cast<'*0>(#)" .}

proc createDefaultSubobject*[T : UObject ](obj:var FObjectInitializer, outer:UObjectPtr, subObjName:FName, bTransient=false) : ptr T {. importcpp:"#.CreateDefaultSubobject<'*0>(@)" .}
proc createDefaultSubobject*(obj:var FObjectInitializer, outer:UObjectPtr, subObjName:FName, returnCls, default: UClassPtr, bIsRequired, bTransient:bool) : UObjectPtr {. importcpp:"#.CreateDefaultSubobject(@)" .}

#todo change this for ActorComponent?
proc createDefaultSubobjectNim*[T:UObject](outer:UObjectPtr, name:FName) : ptr T {.importcpp:"UReflectionHelpers::CreateDefaultSubobjectNim<'*0>(@)" .}



proc getName*(prop:FFieldPtr) : FString {. importcpp:"#->GetName()" .}

proc initializeValue*(prop:FPropertyPtr, dest: pointer) {. importcpp:"#->InitializeValue(#)" .}

proc getOffsetForUFunction*(prop:FPropertyPtr) : int32 {. importcpp:"#->GetOffset_ForUFunction()".}
proc initializeValueInContainer*(prop:FPropertyPtr, container:pointer) : void {. importcpp:"#->InitializeValue_InContainer(#)".}

proc getSize*(prop:FPropertyPtr) : int32 {. importcpp:"#->GetSize()".}
proc getMinAlignment*(prop:FPropertyPtr) : int32 {. importcpp:"#->GetMinAlignment()".}
proc getOffset*(prop:FPropertyPtr) : int32 {. importcpp:"#->GetOffset_ForInternal()".}

proc setPropertyFlags*(prop:FPropertyPtr, flags:EPropertyFlags) : void {. importcpp:"#->SetPropertyFlags(#)".}
proc getPropertyFlags*(prop:FPropertyPtr) : EPropertyFlags {. importcpp:"#->GetPropertyFlags()".}
proc getNameCPP*(prop:FPropertyPtr) : FString {.importcpp: "#->GetNameCPP()".}
proc getCPPType*(prop:FPropertyPtr) : FString {.importcpp: "#->GetCPPType()".}
proc getTypeName*(prop:FPropertyPtr) : FString {.importcpp: "#->GetTypeName()".}
proc getOwnerStruct*(str:FPropertyPtr) : UStructPtr {.importcpp:"#->GetOwnerStruct()".}


type FFieldVariant* {.importcpp.} = object
# proc makeFieldVariant*(field:FFieldPtr) : FFieldVariant {. importcpp: "'0(#)", constructor.}
proc makeFieldVariant*(obj:UObjectPtr | FFieldPtr) : FFieldVariant {. importcpp: "'0(#)", constructor.}
proc toUObject*(field:FFieldVariant) : UObjectPtr {. importcpp: "#.ToUObject()".}
proc toField*(field:FFieldVariant) : FFieldPtr {. importcpp: "#.ToField()".}
proc isUObject*(field:FFieldVariant) : bool {. importcpp: "#.IsUObject()".}

macro bindFProperty(propNames : static openarray[string] ) : untyped = 
    proc bindProp(name:string) : NimNode = 
        let constructorName = ident "new"&name
        let constructorNameWithEqualityAndSerializer = ident "new"&name & "WithEqualityAndSerializer"
        let ptrName = ident name&"Ptr"

        genAst(name=ident name, ptrName, constructorName, constructorNameWithEqualityAndSerializer):
            type 
                name* {.inject, importcpp.} = object of FProperty
                ptrName* {.inject.} = ptr name

            proc constructorName*(fieldVariant:FFieldVariant, propName:FName, objFlags:EObjectFlags) : ptrName {. importcpp: "new '*0(@)", inject.}
            proc constructorName*(fieldVariant:FFieldVariant, propName:FName, objFlags:EObjectFlags, offset:int32, propFlags:EPropertyFlags) : ptrName {. importcpp: "new '*0(@)", inject.}
            proc constructorNameWithEqualityAndSerializer*(fieldVariant:FFieldVariant, propName:FName, objFlags:EObjectFlags) : ptrName {. importcpp: "new '*0(@)", inject.}
            proc constructorNameWithEqualityAndSerializer*(fieldVariant:FFieldVariant, propName:FName, objFlags:EObjectFlags, offset:int32, propFlags:EPropertyFlags) : ptrName {. importcpp: "new '*0(@)", inject.}

    
    nnkStmtList.newTree(propNames.map(bindProp))

bindFProperty([ 
        "FBoolProperty",
        "FInt8Property", "FInt16Property","FIntProperty", "FInt64Property",
        "FByteProperty", "FUInt16Property","FUInt32Property", "FUInt64Property",
        "FStrProperty", "FFloatProperty", "FDoubleProperty", "FNameProperty",
        "FArrayProperty", "FStructProperty", "FObjectPtrProperty", "FClassProperty",
        "FSoftObjectProperty", "FSoftClassProperty", "FEnumProperty", 
        "FMapProperty", "FDelegateProperty", "FSetProperty", "FInterfaceProperty",
        "FMulticastDelegateProperty", #It seems to be abstract. Review Sparse vs Inline
        "FMulticastInlineDelegateProperty",
        
        ])


#TypeClass
type DelegateProp* = FDelegatePropertyPtr | FMulticastInlineDelegatePropertyPtr | FMulticastDelegatePropertyPtr
proc containerPtrToValuePtr*(prop:FPropertyPtr, container: pointer) : pointer {. importcpp: "(#->ContainerPtrToValuePtr<void>(@))".}

#Concrete methods
proc setScriptStruct*(prop:FStructPropertyPtr, scriptStruct:UScriptStructPtr) : void {. importcpp: "(#->Struct=#)".}
proc setPropertyClass*(prop:FObjectPtrPropertyPtr | FSoftObjectPropertyPtr | FClassPropertyPtr, propClass:UClassPtr) : void {. importcpp: "(#->PropertyClass=#)".}
proc getPropertyClass*(prop:FObjectPtrPropertyPtr | FSoftObjectPropertyPtr | FClassPropertyPtr) : UClassPtr {. importcpp: "(#->PropertyClass)".}
# proc setPropertyMetaClass*(prop:FClassPropertyPtr | FSoftClassPropertyPtr, propClass:UClassPtr) : void {. importcpp: "(#->MetaClass=#)".}
proc setPropertyMetaClass*(prop:FClassPropertyPtr | FSoftClassPropertyPtr, propClass:UClassPtr) : void {. importcpp: "#->SetMetaClass(#)".}
proc setEnum*(prop:FEnumPropertyPtr, uenum:UEnumPtr) : void {. importcpp: "(#->SetEnum(#))".}

proc getElementProp*(setProp:FSetPropertyPtr) : FPropertyPtr {.importcpp:"(#->ElementProp)".}
proc getInnerProp*(arrProp:FArrayPropertyPtr) : FPropertyPtr {.importcpp:"(#->Inner)".}
proc setInnerProp*(arrProp:FArrayPropertyPtr, innerProp:FPropertyPtr) : void {.importcpp:"(#->Inner=#)".}
proc getInterfaceClass*(interfaceProp:FInterfacePropertyPtr) : UClassPtr {.importcpp:"(#->InterfaceClass)".}



proc addCppProperty*(arrProp:FArrayPropertyPtr | FSetPropertyPtr | FMapPropertyPtr | FEnumPropertyPtr, cppProp:FPropertyPtr) : void {. importcpp:"(#->AddCppProperty(#))".}

proc getKeyProp*(arrProp:FMapPropertyPtr) : FPropertyPtr {.importcpp:"(#->KeyProp)".}
proc getValueProp*(arrProp:FMapPropertyPtr) : FPropertyPtr {.importcpp:"(#->ValueProp)".}



proc getSignatureFunction*(delProp:DelegateProp) : UFunctionPtr {.importcpp:"(#->SignatureFunction)".}
proc setSignatureFunction*(delProp:DelegateProp, signature : UFunctionPtr) : void {.importcpp:"(#->SignatureFunction=#)".}

#	void SetBoolSize( const uint32 InSize, const bool bIsNativeBool = false, const uint32 InBitMask = 0 );
proc setBoolSize*(prop:FBoolPropertyPtr, size:uint32, isNativeBool:bool) : void {. importcpp: "(#->SetBoolSize(@))".}
proc setPropertyValue*(prop:FBoolPropertyPtr, container: pointer, value:bool) : void {. importcpp: "(#->SetPropertyValue(@))".}
proc getPropertyValue*(prop:FBoolPropertyPtr, container: pointer) : bool {. importcpp: "(#->GetPropertyValue(@))".}
#BoolReturn->GetPropertyValue(BoolReturn->ContainerPtrToValuePtr<void>(InBaseParamsAddr));
#[
    			
                    				uint8* CurrentPropAddr = It->ContainerPtrToValuePtr<uint8>(Buffer);

						((FBoolProperty*)*It)->SetPropertyValue( CurrentPropAddr, true );
]#
type


    FOutParmRec* {.importcpp.} = object
        property* {.importcpp:"Property".} : FPropertyPtr
        propAddr* {.importcpp:"PropAddr".}: pointer 
        nextOutParm* {.importcpp:"NextOutParm".}: ptr FOutParmRec
        mostRecentProperty* {.importcpp:"MostRecentProperty".}: FPropertyPtr
        
       
    FFrame* {.importcpp .} = object
        code* {.importcpp:"Code".} : ptr uint8
        node* {.importcpp:"Node".} : UFunctionPtr
        locals* {.importcpp:"Locals".} : ptr uint8
        outParms* {.importcpp:"OutParms".} : ptr FOutParmRec
        propertyChainForCompiledIn* {.importcpp:"PropertyChainForCompiledIn".}: FFieldPtr
        mostRecentPropertyAddress* {.importcpp:"MostRecentPropertyAddress".}: ptr uint8


#Notice T is not an UObject but the Cpp interface
proc getInterface*[T](scriptInterface:TScriptInterface[T]) : ptr T {. importcpp: "(#.GetInterface())".}
proc getUObject*(scriptInterface:TScriptInterface) : UObjectPtr {. importcpp: "(#.GetObject())".}
proc getUInterface*[T](scriptInterface:TScriptInterface) : ptr T =
    scriptInterface.getUObject().ueCast[:T]()

#UFIELD
proc setMetadata*(field:UFieldPtr|FFieldPtr, key, inValue:FString) : void {.importcpp:"#->SetMetaData(*#, *#)".}
# proc getMetadata*(field:UFieldPtr|FFieldPtr, key:FString) :var FString {.importcpp:"#->GetMetaData(*#)".}
proc findMetaData*(field:UFieldPtr|FFieldPtr, key:FString) : ptr FString {.importcpp:"const_cast<FString*>(#->FindMetaData(*#))".}
#notice it also checks for the ue value. It will return false on "false"
func hasMetadata*(field:UFieldPtr|FFieldPtr, key:FString) : bool = 
    when WithEditor:
        someNil(field.findMetaData(key)).isSome()
    else: false


func getMetaDataMapPtr(field:FFieldPtr) : ptr TMap[FName, FString] {.importcpp:"const_cast<'0>(#->GetMetaDataMap())".}
func getMetadataMap*(field:FFieldPtr) : TMap[FName, FString] =
    when WithEditor:
        let metadataMap = getMetadataMapPtr(field)
        if metadataMap.isNil: makeTMap[FName, FString]()
        else: metadataMap[]
    else: makeTMap[FName, FString]()

func getMetaDataMapPtr(field:UObjectPtr) : ptr TMap[FName, FString] {.importcpp:"(UMetaData::GetMapForObject(#))".}
func getMetadataMap*(field:UObjectPtr) : TMap[FName, FString] =
    when WithEditor:
        let metadataMap = getMetadataMapPtr(field)
        if metadataMap.isNil: makeTMap[FName, FString]()
        else: metadataMap[]
    else: makeTMap[FName, FString]()

func getMetadata*(field:UFieldPtr|FFieldPtr, key:FString) : Option[FString] = 
    let map = field.getMetadataMap()
    let nKey = n key
    if nkey in map:
        some map[nkey]
    else:
        none[FString]()
        
proc bindType*(field:UFieldPtr) : void {. importcpp:"#->Bind()" .} #notice bind is a reserverd keyword in nim
proc getPrefixCpp*(str:UFieldPtr | UStructPtr) : FString {.importcpp:"FString(#->GetPrefixCPP())".}




#USTRUCT
proc staticLink*(str:UStructPtr, bRelinkExistingProperties:bool) : void {.importcpp:"#->StaticLink(@)".}

#This belongs to this file due to nim not being able to forward declate types. We may end up merging this file into uobject
proc addCppProperty*(str:UStructPtr, prop:FPropertyPtr) : void {.importcpp:"#->AddCppProperty(@)".}
#     virtual const TCHAR* GetPrefixCPP() const { return TEXT("F"); }
proc setSuperStruct*(str, suprStruct :UStructPtr) : void {.importcpp:"#->SetSuperStruct(#)".}

#UCLASS
proc findFunctionByName*(cls : UClassPtr, name:FName) : UFunctionPtr {. importcpp: "#.FindFunctionByName(#)"}
proc addFunctionToFunctionMap*(cls : UClassPtr, fn : UFunctionPtr, name:FName) : void {. importcpp: "#.AddFunctionToFunctionMap(@)"}
proc removeFunctionFromFunctionMap*(cls : UClassPtr, fn : UFunctionPtr) : void {. importcpp: "#.RemoveFunctionFromFunctionMap(@)"}
proc getDefaultObject*(cls:UClassPtr) : UObjectPtr {. importcpp:"#->GetDefaultObject()" .}
proc getCDO*[T:UObject](cls:UClassPtr) : ptr T = ueCast[T](cls.getDefaultObject())
proc getSuperClass*(cls:UClassPtr) : UClassPtr {. importcpp:"#->GetSuperClass()" .}
proc assembleReferenceTokenStream*(cls:UClassPtr, bForce = false) : void {. importcpp:"#->AssembleReferenceTokenStream(@)" .}

#ScriptStruct

proc hasStructOps*(str:UScriptStructPtr) : bool {.importcpp:"(#->GetCppStructOps() != nullptr)".}
proc getAlignment*(str:UScriptStructPtr) : int32 {.importcpp:"#->GetCppStructOps()->GetAlignment()".}
proc getSize*(str:UScriptStructPtr) : int32 {.importcpp:"#->GetCppStructOps()->GetSize()".}
proc hasAddStructReferencedObjects*(str:UScriptStructPtr) : bool {.importcpp:"#->GetCppStructOps()->HasAddStructReferencedObjects()".}

# proc getCppStructOps*(str:UScriptStructPtr) : ICppStructOpsPtr {. importcpp:"#->GetCppStructOps()" .}

#TObjectPtr


proc get*[T : UObject](obj:TObjectPtr[T]) : ptr T {.importcpp:"#.Get()".}
converter toUObjectPtr*[T : UObject](obj:TObjectPtr[T]) : ptr T {.importcpp:"#.Get()".}
converter fromObjectPtr*[T : UObject](obj:ptr T) : TObjectPtr[T] {.importcpp:"TObjectPtr<'*0>(#)".}


#UOBJECT
proc getFName*(obj:UObjectPtr|FFieldPtr) : FName {. importcpp: "#->GetFName()" .}
proc getFlags*(obj:UObjectPtr|FFieldPtr) : EObjectFlags {. importcpp: "#->GetFlags()" .}
proc setFlags*(obj:UObjectPtr, inFlags : EObjectFlags) : void {. importcpp: "#->SetFlags(#)" .}
proc clearFlags*(obj:UObjectPtr, inFlags : EObjectFlags) : void {. importcpp: "#->ClearFlags(#)" .}

proc addToRoot*(obj:UObjectPtr) : void {. importcpp: "#->AddToRoot()" .}

proc getClass*(obj : UObjectPtr) : UClassPtr {. importcpp: "#->GetClass()" .}
proc getOuter*(obj : UObjectPtr) : UObjectPtr {. importcpp: "#->GetOuter()" .}
proc getWorld*(obj : UObjectPtr) : UWorldPtr {. importcpp: "#->GetWorld()" .}

proc getName*(obj : UObjectPtr) : FString {. importcpp:"#->GetName()" .}
proc conditionalBeginDestroy*(obj:UObjectPtr) : void {. importcpp:"#->ConditionalBeginDestroy()".}
proc processEvent*(obj : UObjectPtr, fn:UFunctionPtr, params:pointer) : void {. importcpp:"#->ProcessEvent(@)" .}



#bool UClass::Rename( const TCHAR* InName, UObject* NewOuter, ERenameFlags Flags )
#notice rename flags is not an enum in cpp we define it here adhoc
type ERenameFlag* = distinct uint32
const REN_None* = ERenameFlag(0x0000)
const REN_DontCreateRedirectors* = ERenameFlag(0x0010)
proc rename*(obj:UObjectPtr, InName:FString, newOuter:UObjectPtr, flags:ERenameFlag) : bool {. importcpp:"#->Rename(*#, #, #)" .}

#FUNC
proc initializeDerivedMembers*(fn:UFunctionPtr) : void {.importcpp:"#->InitializeDerivedMembers()".}
proc getReturnProperty*(fn:UFunctionPtr) : FPropertyPtr {.importcpp:"#->GetReturnProperty()".}



#UENUM
#virtual bool SetEnums(TArray<TPair<FName, int64>>& InNames, ECppForm InCppForm, EEnumFlags InFlags = EEnumFlags::None, bool bAddMaxKeyIfMissing = true) override;

proc setEnums*(uenum:UENumPtr, inName:TArray[TPair[FName, int64]]) : bool {. importcpp:"#->SetEnums(#, UEnum::ECppForm::Regular)" .}



#ITERATOR
type TFieldIterator* [T:UStruct] {.importcpp.} = object
proc makeTFieldIterator*[T](inStruct : UStructPtr, flag:EFieldIterationFlags) : TFieldIterator[T] {. importcpp:"'0(@)" constructor .}

proc next*[T](it:var TFieldIterator[T]) : void {. importcpp:"(++#)" .} 
proc isValid[T](it: TFieldIterator[T]): bool {.importcpp: "((bool)(#))", noSideEffect.}
proc get*[T](it:TFieldIterator[T]) : ptr T {. importcpp:"*#" .} 

iterator items*[T](it:var TFieldIterator[T]) : var TFieldIterator[T] =
    while it.isValid():
        yield it
        it.next()

type FRawObjectIterator* {.importcpp.} = object
proc makeFRawObjectIterator*() : FRawObjectIterator {. importcpp:"FRawObjectIterator()" constructor .}
proc next*(it:var FRawObjectIterator) : void {. importcpp:"(++#)" .}
proc isValid*(it: FRawObjectIterator): bool {.importcpp: "((bool)(#))", noSideEffect.}
proc get*(it:FRawObjectIterator) : UObjectPtr {. importcpp:"static_cast<UObject*>(#->Object)" .}

iterator items*(it:var FRawObjectIterator) : var FRawObjectIterator =
    while it.isValid():
        yield it
        it.next()


#StepExplicitProperty
proc stepExplicitProperty*(frame:var FFrame, result:pointer, prop:FPropertyPtr) {.importcpp:"#.StepExplicitProperty(@)".}
proc step*(frame:var FFrame, contex:UObjectPtr, result:pointer) {.importcpp:"#.Step(@)".}

#object initializer
proc getObj*(obj: var FObjectInitializer) : UObjectPtr {.importcpp:"#.GetObj()".}

iterator items*(ustr: UStructPtr): FFieldPtr =
    var currentProp = ustr.childProperties
    while not currentProp.isNil():
        yield currentProp
        currentProp = currentProp.next


#CONSTRUCTOR HELPERS
proc succeeded*(clsFinder : FClassFinder) : bool {.importcpp:"#.Succeeded()".}
proc makeClassFinder*[T](classToFind : FString) : FClassFinder[T]{.importcpp:"'0(*#)" .}
proc makeObjectFinder*[T](objectToFind : FString) : FObjectFinder[T]{.importcpp:"'0(*#)" .}


proc makeTSubclassOf*[T]() : TSubclassOf[T] {. importcpp: "TSubclassOf<'*0>()", constructor.}
proc makeTSubclassOf*[T](cls:UClassPtr) : TSubclassOf[T] {. importcpp: "TSubclassOf<'*0>(#)", constructor.}

proc get*(softObj : TSubclassOf) : UClassPtr {.importcpp:"#.Get()".}


