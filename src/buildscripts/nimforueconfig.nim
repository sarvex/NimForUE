import std/[json, jsonutils, os, strutils, genasts, sequtils, strformat, sugar, options]
import ../nimforue/utils/utils
import buildcommon

# codegen paths
const NimHeadersDir* = "NimHeaders"
const NimHeadersModulesDir* = NimHeadersDir / "Modules"
const BindingsDir* = "src"/"nimforue"/"unreal"/"bindings"
const BindingsExportedDir* = "src"/"nimforue"/"unreal"/"bindings"/"exported"
const ReflectionDataDir* = "src" / ".reflectiondata"
const ReflectionDataFilePath* = ReflectionDataDir / "ueproject.nim"

const GamePathError* = "Could not find the uproject file."



when defined(nue) and compiles(gorgeEx("")):

  when defined(windows):
    const ex  = gorgeEx("powershell.exe pwd") 
    const output = $ex[0]
    const PluginDir* = output.split("----")[1].strip().replace("\\src\\buildscripts", "")
  else:
    const ex  = gorgeEx("pwd") 
    const output = $ex[0]
    const PluginDir* = output.strip().replace("/src/buildscripts", "")

else:
  const PluginDir* {.strdefine.} = ""#Defined in switches. Available for all targets (Hots, Guest..)


proc getGamePathFromGameDir*(gameDir:string) : string = 
  (gameDir / "*.uproject").walkFiles.toSeq().head().get(GamePathError)

when defined windows:
  import std/registry
  proc getEnginePathFromRegistry*(association:string) : string =
    let registryPath = "SOFTWARE\\EpicGames\\Unreal Engine\\" & association
    getUnicodeValue(registryPath, "InstalledDirectory", HKEY_LOCAL_MACHINE)
  
  proc tryGetEngineAndGameDir*() : Option[(string, string)] =
    try:
      #We assume we are inside the game plugin folder when no json is available
      let gameDir = absolutePath(PluginDir/".."/"..")
      let uprojectFile = getGamePathFromGameDir(gameDir)
      let engineAssociation = readFile(uprojectFile).parseJson()["EngineAssociation"].getStr()
      let engineDir = getEnginePathFromRegistry(engineAssociation)
      some (engineDir / "Engine", gameDir)
    except:
      log "Could not find the game path. Please set the game path in the json file."
      log getCurrentExceptionMsg()
      none[(string, string)]()
else:
  proc tryGetEngineAndGameDir*() : Option[(string, string)] = 
     let gameDir = absolutePath(PluginDir/".."/"..")
     some ("", gameDir)

#Dll output paths for the uclasses the user generates
when defined(guest):
  const OutputHeader* = "Guest.h"
elif defined(game):
  const OutputHeader* = "Game.h"
else:
  const OutputHeader* = ""
#[
The file is created for first time in from this file during compilation
Since UBT has to set some values on it, it does so through the FFI 
and then Saves it back to the json file. That's why we try to load it first before creating it.
]#


type NimForUEConfig* = object 
  engineDir* : string #Set by UBT
  gameDir* : string
  targetConfiguration* : TargetConfiguration #Sets by UBT (Development, Build)
  targetPlatform* : TargetPlatform #Sets by UBT
  withEditor* : bool
  # currentCompilation* : int 
  #WithEditor? 
  #DEBUG?

func getConfigFileName() : string = 
  when defined macosx:
    return "NimForUE.mac.json"
  when defined windows:
    return "NimForUE.win.json"

#when saving outside of nim set the path to the project
proc saveConfig*(config:NimForUEConfig) =
  let ueConfigPath = PluginDir / getConfigFileName()
  var json = toJson(config)
  writeFile(ueConfigPath, json.pretty())



proc getOrCreateNUEConfig() : NimForUEConfig = 
  let ueConfigPath = PluginDir / getConfigFileName()
  if fileExists ueConfigPath:
    let json = parseFile(ueConfigPath)
    return json.to(NimForUEConfig)
  let defaultPlatform = when defined(windows): Win64 else: Mac
  let conf = 
    tryGetEngineAndGameDir()
      .map((dirs)=> NimForUEConfig(engineDir: dirs[0], gameDir: dirs[1], withEditor:true, targetConfiguration: Development, targetPlatform: defaultPlatform))
  
  if conf.isSome():
    conf.get().saveConfig()
    return conf.get()

  NimForUEConfig()


proc getNimForUEConfig*() : NimForUEConfig = 
  var config = getOrCreateNUEConfig()

  let configErrMsg = "Please check " & getConfigFileName() & " for missing: "
  doAssert(config.engineDir.dirExists(), configErrMsg & " engineDir")
  doAssert(config.gameDir.dirExists(), configErrMsg & " gameDir")
  config.engineDir = config.engineDir.normalizedPath().normalizePathEnd()
  config.gameDir = config.gameDir.normalizedPath().normalizePathEnd()

  #Rest of the fields are sets by UBT
  config.saveConfig()
  config


#PATHS. The can be set at compile time

#Make sure correct paths are set (Mac vs Wind)
#CREATE AND SAVE BEFORE RETURNING

# when defined(nue):
  # let config = getOrCreateNUEConfig("G:\\NimForUEDemov2\\NimForUEDemov2\\Plugins\\NimForUE")
# else:
#   const PluginDir* {.strdefine.} = ""#Defined in switches. Available for all targets (Hots, Guest..)

let config = getOrCreateNUEConfig()

let
  ueLibsDir = PluginDir/"Binaries"/"nim"/"ue" #THIS WILL CHANGE BASED ON THE CURRENT CONF
  NimForUELibDir* = ueLibsDir.normalizePathEnd()
  HostLibPath* =  ueLibsDir / getFullLibName("hostnimforue")
  GameLibPath* =  ueLibsDir / getFullLibName("game")
  GenFilePath* = PluginDir / "src" / "hostnimforue"/"ffigen.nim"
  NimGameDir* = config.gameDir / "NimForUE"
  GamePath* = getGamePathFromGameDir(config.gameDir)
#TODO we need to make it accesible from game/guest at compile time
when not defined(nue):
  const WithEditor* {.booldefine.} = true
else:
  let WithEditor* = config.withEditor 

doAssert(GamePath != GamePathError, &"Config file error: The uproject file could not be found in {config.gameDir}. Please check that 'gameDir' points to the directory containing your uproject in '{PluginDir / getConfigFileName()}'.")

template codegenDir(fname, constName: untyped): untyped =
  proc fname*(config: NimForUEConfig): string =
    PluginDir / constName

codegenDir(nimHeadersDir, NimHeadersDir)
codegenDir(nimHeadersModulesDir, NimHeadersModulesDir)
codegenDir(bindingsDir, BindingsDir)
codegenDir(bindingsExportedDir, BindingsExportedDir)
codegenDir(reflectionDataDir, ReflectionDataDir)
codegenDir(reflectionDataFilePath, ReflectionDataFilePath)




proc getUEHeadersIncludePaths*(conf:NimForUEConfig) : seq[string] =
  let platformDir = if conf.targetPlatform == Mac: "Mac/x86_64" else: $ conf.targetPlatform
  let confDir = $ conf.targetConfiguration
  let engineDir = conf.engineDir
  let pluginDir = PluginDir
  let enginePluginDir = engineDir/"Plugins"#\EnhancedInput\Source\EnhancedInput\Public\EnhancedPlayerInput.h

  let unrealFolder = if conf.withEditor: "UnrealEditor" else: "UnrealGame"

  let pluginDefinitionsPaths = pluginDir / "Intermediate" / "Build" / platformDir / unrealFolder / confDir  #Notice how it uses the TargetPlatform, The Editor?, and the TargetConfiguration
  let nimForUEIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / unrealFolder / "Inc" / "NimForUE"
  let nimForUEBindingsHeaders =  pluginDir / "Source/NimForUEBindings/Public/"
  let nimForUEBindingsIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / unrealFolder / "Inc" / "NimForUEBindings"
  let nimForUEEditorHeaders =  pluginDir / "Source/NimForUEEditor/Public/"
  let nimForUEEditorIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / unrealFolder / "Inc" / "NimForUEEditor"

  let essentialHeaders = @[
    pluginDefinitionsPaths / "NimForUE",
    pluginDefinitionsPaths / "NimForUEBindings",
    nimForUEIntermediateHeaders,
    nimForUEBindingsHeaders,
    nimForUEBindingsIntermediateHeaders,
    #notice this shouldn't be included when target <> Editor
    nimForUEEditorHeaders,
    nimForUEEditorIntermediateHeaders,

    pluginDir / "NimHeaders",
    engineDir / "Shaders",
    engineDir / "Shaders/Shared",
    engineDir / "Source",
    engineDir / "Source/Runtime",
    engineDir / "Source/Runtime/Engine",
    engineDir / "Source/Runtime/Engine/Public",
    engineDir / "Source/Runtime/Engine/Public/Rendering",
    engineDir / "Source/Runtime/Engine/Classes",
    engineDir / "Source/Runtime/Engine/Classes/Engine",
    engineDir / "Source/Runtime/Net/Core/Public",
    engineDir / "Source/Runtime/Net/Core/Classes",
    engineDir / "Source/Runtime/InputCore/Classes"
  ]

  let editorHeaders = @[
    engineDir / "Source/Editor",
    engineDir / "Source/Editor/UnrealEd",
    engineDir / "Source/Editor/UnrealEd/Classes",
    engineDir / "Source/Editor/UnrealEd/Classes/Settings"
    
  ]

  proc getEngineRuntimeIncludePathFor(engineFolder, moduleName: string) : string = engineDir / "Source" / engineFolder / moduleName / "Public"
  proc getEngineRuntimeIncludeClassesPathFor(engineFolder, moduleName: string) : string = engineDir / "Source" / engineFolder / moduleName / "Classes"
  proc getEngineIntermediateIncludePathFor(moduleName:string) : string = engineDir / "Intermediate/Build" / platformDir / unrealFolder / "Inc" / moduleName
  proc getEnginePluginModule(moduleName:string) : string = enginePluginDir / moduleName / "Source" / moduleName / "Public"


  let runtimeModules = @["CoreUObject", "Core", "TraceLog", "Launch", "ApplicationCore", 
      "Projects", "Json", "PakFile", "RSA", "RenderCore",
      "NetCore", "CoreOnline", "PhysicsCore", "Experimental/Chaos", 
      "SlateCore", "Slate", "TypedElementFramework", "Renderer", "AnimationCore",
      "ClothingSystemRuntimeInterface", "SandboxFile", "NetworkFileSystem",
      "Experimental/Interchange/Core",
      "Experimental/ChaosCore", "InputCore", "RHI", "AudioMixerCore", "AssetRegistry", "DeveloperSettings"]

  let developerModules = @["DesktopPlatform", 
  "ToolMenus", "TargetPlatform", "SourceControl", 
  "DeveloperToolSettings",
  "Localization"]
  let intermediateGenModules = @["NetCore", "Engine", "PhysicsCore", "AssetRegistry", 
    "UnrealEd", "ClothingSystemRuntimeInterface",  "EditorSubsystem", "InterchangeCore",
    "TypedElementFramework","Chaos", "ChaosCore", "EditorStyle", "EditorFramework",
    "Localization", "DeveloperToolSettings", "Slate",
    "InputCore", "DeveloperSettings", "SlateCore", "ToolMenus"]
  let editorModules = @["UnrealEd", "PropertyEditor", 
  "EditorStyle", "EditorSubsystem","EditorFramework",
  
  ]
  let enginePlugins = @["EnhancedInput"]

  let moduleHeaders = 
    runtimeModules.map(module=>getEngineRuntimeIncludePathFor("Runtime", module)) & 
    developerModules.map(module=>getEngineRuntimeIncludePathFor("Developer", module)) & 
    developerModules.map(module=>getEngineRuntimeIncludeClassesPathFor("Developer", module)) & #if it starts to complain about the lengh of the cmd line. Optimize here
    editorModules.map(module=>getEngineRuntimeIncludePathFor("Editor", module)) & 
    intermediateGenModules.map(module=>getEngineIntermediateIncludePathFor(module)) &
    enginePlugins.map(module=>getEnginePluginModule(module))

  (essentialHeaders & moduleHeaders & editorHeaders).map(path => path.normalizedPath().normalizePathEnd())



proc getUESymbols*(conf: NimForUEConfig): seq[string] =
  let platformDir = if conf.targetPlatform == Mac: "Mac/x86_64" else: $conf.targetPlatform
  let confDir = $conf.targetConfiguration
  let engineDir = conf.engineDir
  let pluginDir = PluginDir
  let unrealFolder = if conf.withEditor: "UnrealEditor" else: "UnrealGame"
  proc getObjFiles(dir: string, moduleName:string) : seq[string] = 
    #useful for non editor builds. Some modules are split
    # let objFiles = walkFiles(dir/ &"Module.{moduleName}*.cpp.obj").toSeq()
    when defined(windows):
      let objFiles = walkFiles(dir / &"*.obj").toSeq()
    else:
      let objFiles = walkFiles(dir / &"*.o").toSeq()
    echo &"objFiles for {moduleName} in {dir}: {objFiles}"
    
    objFiles

  proc getObjectFilesFromRootDir(dir : string) : seq[string] = 
    when defined(windows):
      let objFiles = walkFiles(dir / &"*.obj").toSeq()
    else:
      let objFiles = walkFiles(dir / "*" / &"*.o").toSeq()
    echo &"objFiles for {dir}: {objFiles}"
    
    objFiles

  #We only support Debug and Development for now and Debug is Windows only
  let suffix = if conf.targetConfiguration == Debug : "-Win64-Debug" else: "" 
  proc getEngineRuntimeSymbolPathFor(prefix, moduleName:string): seq[string] =  
    when defined windows:
      let dir =  engineDir / "Intermediate/Build" / platformDir / unrealFolder / confDir / moduleName 
      if conf.withEditor:
        @[dir / &"{prefix}-{moduleName}{suffix}.lib"]
      else:
        getObjFiles(dir, moduleName)
       
    elif defined macosx:
      if conf.withEditor:
        let platform = $conf.targetPlatform #notice the platform changed for the symbols (not sure how android/consoles/ios will work)
        @[engineDir / "Binaries" / platform / &"{prefix}-{moduleName}.dylib"]
      else:
        let dir = engineDir / "Intermediate/Build" / platformDir / unrealFolder / confDir / moduleName 
        getObjFiles(dir, moduleName)
      
#E:\unreal_sources\5.1Launcher\UE_5.1\Engine\Plugins\EnhancedInput\Intermediate\Build\Win64\UnrealEditor\Development\EnhancedInput
  proc getEnginePluginSymbolsPathFor(prefix, moduleName:string): seq[string] =  
    when defined windows:
      let dir = engineDir / "Plugins" / moduleName / "Intermediate/Build" / platformDir / unrealFolder / confDir / moduleName 
      if conf.withEditor:
        @[dir / &"{prefix}-{moduleName}{suffix}.lib"]
      else:
        getObjFiles(dir, moduleName)

    elif defined macosx:
      if conf.withEditor:
        let platform = $conf.targetPlatform #notice the platform changed for the symbols (not sure how android/consoles/ios will work)
        @[engineDir / "Plugins" / moduleName / "Binaries" / platform / &"{prefix}-{moduleName}.dylib"]
      else:
        let dir = engineDir / "Plugins" / moduleName / "Intermediate/Build" / platformDir / unrealFolder / confDir / moduleName 
        getObjFiles(dir, moduleName)

  proc getNimForUESymbols(): seq[string] = 
    when defined macosx:
      if conf.withEditor:
        let libpath = pluginDir / "Binaries" / $conf.targetPlatform / "UnrealEditor-NimForUE.dylib"
        let libpathBindings  = pluginDir / "Binaries" / $conf.targetPlatform / "UnrealEditor-NimForUEBindings.dylib"
        #notice this shouldnt be included when target <> Editor
        let libPathEditor  = pluginDir / "Binaries" / $conf.targetPlatform / "UnrealEditor-NimForUEEditor.dylib"
        return @[libPath,libpathBindings, libPathEditor]
      else:
        let dir = pluginDir / "Intermediate/Build" / platformDir / unrealFolder / confDir 
        let libPath = getObjFiles(dir / "NimForUE", "NimForUE")
        let libPathBindings = getObjFiles(dir / "NimForUEBindings", "NimForUEBindings")
        libPath & libpathBindings

    elif defined windows:
      if conf.withEditor:
        let libPath = pluginDir / "Intermediate/Build" / platformDir / unrealFolder / confDir / &"NimForUE/UnrealEditor-NimForUE{suffix}.lib"
        let libPathBindings = pluginDir / "Intermediate/Build" / platformDir / unrealFolder / confDir / &"NimForUEBindings/UnrealEditor-NimForUEBindings{suffix}.lib"
        let libPathEditor = pluginDir / "Intermediate/Build" / platformDir / unrealFolder / confDir / &"NimForUEEditor/UnrealEditor-NimForUEEditor{suffix}.lib"
        @[libPath,libpathBindings, libPathEditor]
      else:
        let dir = pluginDir / "Intermediate/Build" / platformDir / unrealFolder / confDir 
        let libPath = getObjFiles(dir / "NimForUE", "NimForUE")
        let libPathBindings = getObjFiles(dir / "NimForUEBindings", "NimForUEBindings")
        libPath & libPathBindings

  let engineObjDir = engineDir / "Intermediate/Build" / platformDir / unrealFolder / confDir  
  let engineObjFiles = getObjectFilesFromRootDir(engineObjDir)
  let enginePluginDir =  engineDir / "Plugins" / "*" / "Intermediate/Build" / platformDir / unrealFolder / confDir 
  let enginePluginObjFiles = getObjectFilesFromRootDir(enginePluginDir)
  let nimForUEobjFiles = getNimForUESymbols()

  # let ogbdLib = engineDir / "Binaries/ThirdParty/Ogg/Mac/liblogg.dylib"
  # let vorbis = "/Volumes/Store/UnrealSources/UE_5.1/Engine/Binaries/ThirdParty/Vorbis/Mac/liblvorbis.dylib"

  let ogbdLib = "-L/Volumes/Store/UnrealSources/UE_5.1/Engine/Binaries/ThirdParty/Ogg/Mac -logg"
  let vorbis = "-L/Volumes/Store/UnrealSources/UE_5.1/Engine/Binaries/ThirdParty/Vorbis/Mac -lvorbis"

  # quit()
  (engineObjFiles & enginePluginObjFiles & nimForUEobjFiles & ogbdLib & vorbis).map(path => path.normalizedPath())

  # let modules = @["Core", "CoreUObject", "Engine", "SlateCore","Slate", "UnrealEd", "InputCore"]
  # let engineSymbolsPaths  = modules.map(modName=>getEngineRuntimeSymbolPathFor("UnrealEditor", modName)).flatten()
  # let enginePluginSymbolsPaths = @["EnhancedInput"].map(modName=>getEnginePluginSymbolsPathFor("UnrealEditor", modName)).flatten()
  
  # (engineSymbolsPaths & enginePluginSymbolsPaths & getNimForUESymbols()).map(path => path.normalizedPath())

