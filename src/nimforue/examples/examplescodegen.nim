include ../unreal/prelude
import std/[strformat, tables, times, options, sugar, json, osproc, strutils, jsonutils,  sequtils, os]
import ../codegen/uemeta
import ../../buildscripts/nimforueconfig
import ../codegen/[codegentemplate,modulerules, genreflectiondata]
import ../codegen/genmodule #not sure if it's worth to process this file just for one function? 


#[
  NimForUEBindings: [examplescodegen.nim:58]: Func: PrintString Flags: FUNC_Final, FUNC_Native, FUNC_Static, FUNC_Public, FUNC_HasDefaults, FUNC_BlueprintCallable, FUNC_AllFlags 
  Metadata: {AdvancedDisplay: 2, CallableWithoutWorldContext: , Category: Development, 
  CPP_Default_bPrintToLog: true, CPP_Default_bPrintToScreen: true, CPP_Default_Duration: 2.000000, CPP_Default_InString: Hello, CPP_Default_Key: None, 
  CPP_Default_TextColor: (R=0.000000,G=0.660000,B=1.000000,A=1.000000), DevelopmentOnly: , 
  
  Keywords: log print, ModuleRelativePath: Classes/Kismet/KismetSystemLibrary.h, WorldContext: WorldCon
textObject}
  
  Params: 
    Prop: WorldContextObject CppType: UObject* Flags: CPF_ConstParm, CPF_Parm, CPF_ZeroConstructor, CPF_NoDestructor, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
    Prop: InString CppType: FString Flags: CPF_Parm, CPF_ZeroConstructor, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
    Prop: bPrintToScreen CppType: bool Flags: CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_AdvancedDisplay, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: bPrintToLog CppType: bool Flags: CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_AdvancedDisplay, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: TextColor CppType: FLinearColor Flags: CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_AdvancedDisplay, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: Duration CppType: float Flags: CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_AdvancedDisplay, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: Key CppType: FName Flags: CPF_ConstParm, CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_AdvancedDisplay, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
  
]#
#[
  NimForUEBindings: [examplescodegen.nim:58]: Func: InjectInputForAction Flags: FUNC_Native, FUNC_Public, FUNC_HasOutParms, FUNC_BlueprintCallable, FUNC_AllFlags 
  Metadata: {AutoCreateRefTerm: Modifiers,Triggers, Category: Input, ModuleRelativePath: Public/EnhancedInputSubsystemInterface.h}
  
  Params: 
    Prop: Action CppType: UInputAction* Flags: CPF_ConstParm, CPF_Parm, CPF_ZeroConstructor, CPF_NoDestructor, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
    Prop: RawValue CppType: FInputActionValue Flags: CPF_Parm, CPF_NoDestructor, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: Modifiers CppType: TArray Flags: CPF_ConstParm, CPF_Parm, CPF_OutParm, CPF_ZeroConstructor, CPF_ReferenceParm, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
    Prop: Triggers CppType: TArray Flags: CPF_ConstParm, CPF_Parm, CPF_OutParm, CPF_ZeroConstructor, CPF_ReferenceParm, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
  
]#
#[
  NimForUEBindings: [examplescodegen.nim:91]: Func: AddMappingContext Flags: FUNC_BlueprintCosmetic, FUNC_Native, FUNC_Public, FUNC_HasOutParms, FUNC_BlueprintCallable, FUNC_AllFlags 
  Metadata: {AutoCreateRefTerm: Options, Category: Input, CPP_Default_Options: (), ModuleRelativePath: Public/EnhancedInputSubsystemInterface.h}
  
  Params: 
    Prop: MappingContext CppType: UInputMappingContext* Flags: CPF_ConstParm, CPF_Parm, CPF_ZeroConstructor, CPF_NoDestructor, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
    Prop: Priority CppType: int32 Flags: CPF_Parm, CPF_ZeroConstructor, CPF_IsPlainOldData, CPF_NoDestructor, CPF_HasGetValueTypeHash, CPF_NativeAccessSpecifierPublic Metadata: {:}
    Prop: Options CppType: FModifyContextOptions Flags: CPF_ConstParm, CPF_Parm, CPF_OutParm, CPF_ReferenceParm, CPF_NoDestructor, CPF_NativeAccessSpecifierPublic Metadata: {NativeConst: }
  
]#
#[
   {"ECollisionChannel": "ECC_Visibility", 
   "FText": "INVTEXT(\"Hello\")", 
   "bool": "true", 
   "FName": "None", 
   "FRotator": "", "UForceFeedbackAttenuationPtr": "None", 
   "float32": "1.000000", "EBlendMode": "BLEND_Translucent", 
   "EDetachmentRule": "KeepRelative", "AActorPtr": "None", "UFontPtr": "None", 
   "FVector2D": "(X=1.000,Y=1.000)", "AControllerPtr": "None", "FVector": "", 
   "FString": "", "FLinearColor": "(R=1.000000,G=1.000000,B=1.000000,A=1.000000)", 
   "USoundConcurrencyPtr": "None", "ETextureRenderTargetFormat": 
   "RTF_RGBA16f", "EPSCPoolMethod": "None", "USoundAttenuationPtr": "None", "int32": "-1", 
   "EViewTargetBlendFunction": "VTBlend_Linear", 
   "EMontagePlayReturnType": "MontageLength", 
   "TSubclassOf[ULevelStreamingDynamic] ": "None", 
   "EAttachLocation::Type": "KeepRelativeOffset"}
]#
#[
  Doesnt include ref types so those will require an extra pass (they will be generating function overloads anyways)
  Mostly Enums. Hopefully they all start with E
  Lots of pointer, they will be just nil
  bool, floats and strings whould be direct
  FVector, Colors and so can be just a fn call

  FROTATOR
  U/A poitners
  DONE. 
  Expand functions containing const default params
  See first how many are and see it returning the new amount of funcitons in the code gen
  
  InjectInputVectorForAction
]#



proc NimMain() {.importc.} 

uEnum EInspectType: 
  (BlueprintType)
  Actor
  Class
  Name



proc getModules(moduleName:string, onlyBp : bool) : seq[UEModule] = 
      let pkg = tryGetPackageByName(moduleName)
      let rules = 
        if onlyBp:  
          @[makeImportedRuleModule(uerImportBlueprintOnly)]
        else: 
          @[]

      pkg.map((pkg:UPackagePtr) => pkg.toUEModule(rules, @[], @[])).get(@[])
#This is just for testing/exploring, it wont be an actor
uClass AActorCodegen of AActor:
  (BlueprintType)
  override:
    proc beginPlay() = 
      UE_Warn "Hello Begin play from actor codegen"
  uprops(EditAnywhere, BlueprintReadWrite, Category=CodegenInspect):
    inspect : EInspectType = Name
    inspectName : FString = "EnhancedInputSubsystemInterface"
    inspectClass : UClassPtr
    inspectActor : AActorPtr
    bOnlyBlueprint : bool 
    moduleName : FString
    test : FString
  
  ufuncs(): 
    proc getClassFromInspectedType() : UClassPtr = 
      case self.inspect:
        of EInspectType.Actor: 
          return self.inspectActor.getClass()
        of EInspectType.Class: 
          return self.inspectClass
        of EInspectType.Name: 
          return getClassByName(self.inspectName)
    

  
  ufuncs(BlueprintCallable, CallInEditor, Category=CodegenInspect):
    proc dumpClass() = 
      let cls = self.getClassFromInspectedType()
      if cls.isNil():
        UE_Error "Class is null"
        return
      UE_Log $cls
    proc dumpClassAsUEType() = 
      let cls = self.getClassFromInspectedType()
      if cls.isNil():
        UE_Error "Class is null"
        return
      let ueType = cls.toUEType(@[])
      UE_Log $ueType
    
  uprops(EditAnywhere, BlueprintReadWrite, Category=CodegenFunctionFinder):
    funcName : FString = "PrintString"
  ufuncs(BlueprintCallable, CallInEditor, Category=CodegenFunctionFinder):
    proc logFunction() = 
      let fn = getUTypeByName[UFunction](self.funcName)
      UE_Log $fn
    proc convertToUEField() = 
      let fn = getUTypeByName[UFunction](self.funcName)
      let fnFields = fn.toUEField(@[])
      UE_Log $fnFields


    proc showFunctionDefaultParams() = 
      let fn = getUTypeByName[UFunction](self.funcName)
      if fn.isNil():
        UE_Error "Function is null"
        return
      let fnField = fn.toUEField(@[]).head().get()
      let defaultParams = fnField.getAllParametersWithDefaultValuesFromFunc()
      for p in defaultParams:
        if p.uePropType == "bool":
          let value = fnField.getMetadataValueFromFunc[:bool](p.name)
          UE_Log $p.name & " = " & $value
        else:
          UE_Warn "Type not supported for default value: " & p.uePropType
          UE_Log $p
    
    proc traverseAllFunctionsWithDefParams() = 
      let modules = getModules(self.moduleName, self.bOnlyBlueprint)
      let fns : seq[UEField]= modules.mapIt(it.types.mapIt(it.fields)).flatten().flatten()
      let fnsWithDefaultParams = fns.filterIt(it.kind == uefFunction and it.getAllParametersWithDefaultValuesFromFunc().len() > 0)
      #I should get next a tuple with the param Type. Only type for now
      var params : Table[string, string] 
      for fn in fnsWithDefaultParams:
        for m in fn.metadata:
          if m.name.startsWith CPP_Default_MetadataKeyPrefix:
            let name = m.name.replace(CPP_Default_MetadataKeyPrefix, "")
            for p in fn.signature:
              if p.name == name:
                UE_Log $p.name & " " & $p.uePropType & " " & $m.value
                params[p.uePropType] = m.value
                break
  
      UE_Log "Found " & $fnsWithDefaultParams.len() & " functions with default parameters"
      UE_Log "Found " & $params.len() & " unique parameters type"
      UE_Log $params
    
    proc traverAllFunctionsWithAutoCreateRefTerm() = 
      let modules = getModules(self.moduleName, self.bOnlyBlueprint)
      let fns : seq[UEField]= modules.mapIt(it.types.mapIt(it.fields)).flatten().flatten()
      let fnsWithAutoCreateRefTerm = fns.filterIt(it.kind == uefFunction and it.hasUEMetadata(AutoCreateRefTermMetadataKey))
      for fn in fnsWithAutoCreateRefTerm:
        UE_Log $fn
      UE_Log "Found " & $fnsWithAutoCreateRefTerm.len() & " unique functions with AutoCreateRefTerm type"      

  uprops(EditAnywhere, BlueprintReadWrite):
    delTypeName : FString = "test5"
    structPtrName : FString 
  uprops(EditAnywhere, BlueprintReadWrite, Category = StructInspector):
    structToFind : FString
  
  ufuncs(BlueprintCallable, CallInEditor, Category=StructInspector):
    proc showStruct() = 
      let struct = getUTypeByName[UScriptStruct](self.structToFind)
      if struct.isNil():
        UE_Error "Struct is null"
        return
      let structField = struct.toUEType()
      UE_Log $structField
      UE_Log &"Module Name: {struct.getModuleName()}"


  ufuncs(BlueprintCallable, CallInEditor, Category=ActorCodegen):
    proc genReflectionDataOnly() = 
      try:
        let ueProject =  genReflectionData(getGameModules(), getAllInstalledPlugins())
       
      except:
        let e : ref Exception = getCurrentException()
        UE_Error &"Error: {e.msg}"
        UE_Error &"Error: {e.getStackTrace()}"
        UE_Error &"Failed to generate reflection data"
    
    proc genReflectionDataAndBindingsAsync() = 
        execBindingGeneration(shouldRunSync=false)    
    proc genReflectionDataAndBindingsSync() = 
      try:
        execBindingGeneration(shouldRunSync=true)                       
      except:
        let e : ref Exception = getCurrentException()
        UE_Error &"Error: {e.msg}"
        UE_Error &"Error: {e.getStackTrace()}"
        UE_Error &"Failed to generate reflection data"

    proc showType() = 
      let obj = getUTypeByName[UDelegateFunction]("UMG.ComboBoxKey:OnOpeningEvent"&DelegateFuncSuffix)
      let obj2 = getUTypeByName[UDelegateFunction]("OnOpeningEvent"&DelegateFuncSuffix)
      UE_Warn $obj
      UE_Warn $obj2
      UE_Warn $obj2

    proc showTypeModule() = 
      let obj = getUTypeByName[UField]("EFieldVectorType")

      UE_Log $obj
      if not obj.isNil():
        UE_Log $obj.getModuleName()

    proc searchDelByName() = 
      let obj = getUTypeByName[UDelegateFunction](self.delTypeName&DelegateFuncSuffix)
      if obj.isNil(): 
        UE_Error &"Error del is null. Provide a type name"
        return

      UE_Warn $obj
      UE_Warn $obj.getOuter()
    
    proc runFnInAnotherThread() = 
      proc ffiWraper(msg:int) {.cdecl.} = 
        # NimMain()   
        # UE_Log "Hello from another thread" & $msg #This cashes
        # let s = "test string"
        UE_Log "Hello from another thread" 
     
      executeTaskInTaskGraph(2, ffiWraper)   

    
    proc showUEModule() = 
      let pkg = tryGetPackageByName(self.moduleName)
      let rules = 
        if self.bOnlyBlueprint:  
          @[makeImportedRuleModule(uerImportBlueprintOnly),  makeImportedRuleType(uerForce, @["FNiagaraPosition"])]
        else: 
          @[]

      let modules = pkg.map((pkg:UPackagePtr) => pkg.toUEModule(rules, @[], @[])).get(@[])
      # UE_Log $modules.head().map(x=>x.types.mapIt(it.name))
      # UE_Log "Len " & $modules.len
      # UE_Log "Types " & $modules.head().map(x=>x.types).get(@[]).len
      let ueProject = UEProject(modules: modules)
      UE_Log "contans deproject to mouse pos: " & $ueProject.modules.filterIt(it.types.filterIt(it.fields.filterIt(it.name.contains("DeprojectMousePositionToWorld")).any()).any()).any()
      # writeFile(PluginDir/"engine.text", $ueProject)
      # UE_Log $ueProject

   