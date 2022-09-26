import std/[json, jsonutils, os, sequtils, strformat, sugar]
import buildcommon

#[
The file is created for first time in from this file during compilation
Since UBT has to set some values on it, it does so through the FFI 
and then Saves it back to the json file. That's why we try to load it first before creating it.
]#
type NimForUEConfig* = object 
  genFilePath* : string
  nimForUELibPath* : string #due to how hot reloading on mac this now sets the last compiled filed.
  hostLibPath* : string
  engineDir* : string #Sets by UBT
  pluginDir* : string
  targetConfiguration* : TargetConfiguration #Sets by UBT (Development, Build)
  targetPlatform* : TargetPlatform #Sets by UBT
  # currentCompilation* : int 
  #WithEditor? 
  #DEBUG?

func getConfigFileName() : string = 
  when defined macosx:
    return "NimForUE.mac.json"
  when defined windows:
    return "NimForUE.win.json"

#when saving outside of nim set the path to the project
proc saveConfig*(config:NimForUEConfig, pluginDirPath="") =
  let pluginDir = if pluginDirPath == "": getCurrentDir() else: pluginDirPath
  let ueConfigPath = pluginDir / getConfigFileName()
  var json = toJson(config)
  writeFile(ueConfigPath, json.pretty())

proc getOrCreateNUEConfig(pluginDirPath="") : NimForUEConfig = 
  let pluginDir = if pluginDirPath == "": getCurrentDir() else: pluginDirPath
  let ueConfigPath = pluginDir / getConfigFileName()
  if fileExists ueConfigPath:
    let json = readFile(ueConfigPath).parseJson()
    return jsonTo(json, NimForUEConfig)
  NimForUEConfig(pluginDir:pluginDir)

proc getNimForUEConfig*(pluginDirPath="") : NimForUEConfig = 
  let pluginDir = if pluginDirPath == "": getCurrentDir() else: pluginDirPath
  #Make sure correct paths are set (Mac vs Wind)
  let ueLibsDir = pluginDir/"Binaries"/"nim"/"ue"
  #CREATE AND SAVE BEFORE RETURNING
  let genFilePath = pluginDir / "src" / "hostnimforue"/"ffigen.nim"
  var config = getOrCreateNUEConfig(pluginDirPath)
  config.nimForUELibPath = ueLibsDir / getFullLibName("nimforue")
  config.hostLibPath =  ueLibsDir / getFullLibName("hostnimforue")
  config.genFilePath = genFilePath
  config.engineDir = config.engineDir.normalizedPath().normalizePathEnd()
  config.pluginDir = config.pluginDir.normalizedPath().normalizePathEnd()
  #Rest of the fields are sets by UBT
  config.saveConfig()
  config


proc getUEHeadersIncludePaths*(conf:NimForUEConfig) : seq[string] =
  let platformDir = if conf.targetPlatform == Mac: "Mac/x86_64" else: $ conf.targetPlatform
  let confDir = $ conf.targetConfiguration
  let engineDir = conf.engineDir
  let pluginDir = conf.pluginDir

  let pluginDefinitionsPaths = pluginDir / "Intermediate" / "Build" / platformDir / "UnrealEditor" / confDir  #Notice how it uses the TargetPlatform, The Editor?, and the TargetConfiguration
  let nimForUEIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / "UnrealEditor" / "Inc" / "NimForUE"
  let nimForUEBindingsHeaders =  pluginDir / "Source/NimForUEBindings/Public/"
  let nimForUEBindingsIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / "UnrealEditor" / "Inc" / "NimForUEBindings"
  let nimForUEEditorHeaders =  pluginDir / "Source/NimForUEEditor/Public/"
  let nimForUEEditorIntermediateHeaders = pluginDir / "Intermediate" / "Build" / platformDir / "UnrealEditor" / "Inc" / "NimForUEEditor"

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
  proc getEngineIntermediateIncludePathFor(moduleName:string) : string = engineDir / "Intermediate/Build" / platformDir / "UnrealEditor/Inc" / moduleName
# 
  let runtimeModules = @["AdvancedWidgets", "Advertising", "AIModule", "Analytics", "Android", "AnimationCore", "AnimGraphRuntime", "AppFramework", "Apple", "ApplicationCore", "AssetRegistry", "AudioAnalyzer", "AudioCaptureCore", "AudioCaptureImplementations", "AudioCodecEngine", "AudioExtensions", "AudioLink", "AudioMixer", "AudioMixerCore", "AudioPlatformConfiguration", "AugmentedReality", "AutomationMessages", "AutomationTest", "AutomationWorker", "AVEncoder", "AVIWriter", "BinkAudioDecoder", "BlueprintRuntime", "BuildSettings", "Cbor", "CEF3Utils", "CinematicCamera", "ClientPilot", "ClothingSystemRuntimeCommon", "ClothingSystemRuntimeInterface", "ClothingSystemRuntimeNv", "ColorManagement", "CookOnTheFly", "Core", "CoreOnline", "CoreUObject", "CrashReportCore", "CrunchCompression", "CUDA", "D3D12RHI", "Datasmith", "DeveloperSettings", "Engine", "EngineMessages", "EngineSettings", "Experimental", "ExternalRPCRegistry", "EyeTracker", "Foliage", "FriendsAndChat", "GameMenuBuilder", "GameplayMediaEncoder", "GameplayTags", "GameplayTasks", "GeometryCore", "GeometryFramework", "HardwareSurvey", "HeadMountedDisplay", "IESFile", "ImageCore", "ImageWrapper", "ImageWriteQueue", "InputCore", "InputDevice", "InstallBundleManager", "InteractiveToolsFramework", "IOS", "IPC", "Json", "JsonUtilities", "Landscape", "Launch", "LevelSequence", "Linux", "LiveLinkAnimationCore", "LiveLinkInterface", "LiveLinkMessageBusFramework", "MaterialShaderQualitySettings", "Media", "MediaAssets", "MediaUtils", "MeshConversion", "MeshConversionEngineTypes", "MeshDescription", "MeshUtilitiesCommon", "Messaging", "MessagingCommon", "MessagingRpc", "MoviePlayer", "MoviePlayerProxy", "MovieScene", "MovieSceneCapture", "MovieSceneTracks", "MRMesh", "NavigationSystem", "Navmesh", "Net", "NetworkFile", "NetworkFileSystem", "Networking", "NetworkReplayStreaming", "NonRealtimeAudioRenderer", "NullDrv", "NullInstallBundleManager", "NVidia", "Online", "OodleDataCompression", "OpenGLDrv", "Overlay", "PacketHandlers", "PakFile", "PerfCounters", "PhysicsCore", "PhysXCooking", "PlatformThirdPartyHelpers", "Portal", "PreLoadScreen", "Projects", "PropertyPath", "RawMesh", "RenderCore", "Renderer", "RHI", "RHICore", "RigVM", "RSA", "RuntimeAssetCache", "SandboxFile", "Serialization", "SessionMessages", "SessionServices", "SignalProcessing", "SkeletalMeshDescription", "Slate", "SlateCore", "SlateNullRenderer", "SlateRHIRenderer", "Sockets", "SoundFieldRendering", "StaticMeshDescription", "StorageServerClient", "StreamingFile", "StreamingPauseRendering", "SymsLib", "SynthBenchmark", "TextureUtilitiesCommon", "TimeManagement", "Toolbox", "TraceLog", "TypedElementFramework", "TypedElementRuntime", "UELibrary", "UMG", "Unix", "UnrealGame", "VectorVM", "VirtualProduction", "VulkanRHI", "WebBrowser", "WebBrowserTexture", "WidgetCarousel", "Windows", "XmlParser"]
  let developerModules = @["AITestSuite", "Android", "AnimationDataController", "AnimationWidgets", "Apple", "AssetTools", "AudioFormatADPCM", "AudioFormatBink", "AudioFormatOgg", "AudioFormatOpus", "AudioSettingsEditor", "AutomationController", "AutomationDriver", "AutomationWindow", "BlankModule", "BSPUtils", "CollectionManager", "CollisionAnalyzer", "CookedEditor", "CrashDebugHelper", "Datasmith", "DerivedDataCache", "DesktopPlatform", "DesktopWidgets", "DeveloperToolSettings", "DeviceManager", "DirectoryWatcher", "DistributedBuildInterface", "EditorAnalyticsSession", "ExternalImagePicker", "FileUtilities", "FunctionalTesting", "GameplayDebugger", "GeometryProcessingInterfaces", "GraphColor", "HierarchicalLODUtilities", "HoloLens", "HotReload", "IOS", "IoStoreUtilities", "LauncherServices", "Linux", "Localization", "LocalizationService", "LogVisualizer", "LowLevelTestsRunner", "Mac", "MaterialBaking", "MaterialUtilities", "Merge", "MeshBoneReduction", "MeshBuilder", "MeshBuilderCommon", "MeshDescriptionOperations", "MeshMergeUtilities", "MeshReductionInterface", "MeshSimplifier", "MeshUtilities", "MeshUtilitiesEngine", "MessageLog", "NaniteBuilder", "OutputLog", "PakFileUtilities", "PhysicsUtilities", "Profiler", "ProfilerClient", "ProfilerMessages", "ProfilerService", "ProjectLauncher", "RealtimeProfiler", "RigVMDeveloper", "ScreenShotComparison", "ScreenShotComparisonTools", "ScriptDisassembler", "SessionFrontend", "Settings", "SettingsEditor", "ShaderCompilerCommon", "ShaderFormatOpenGL", "ShaderFormatVectorVM", "ShaderPreprocessor", "SharedSettingsWidgets", "SkeletalMeshUtilitiesCommon", "SlackIntegrations", "SlateFileDialogs", "SlateFontDialog", "SlateReflector", "SourceCodeAccess", "SourceControl", "StandaloneRenderer", "TargetDeviceServices", "TargetPlatform", "TaskGraph", "TextureBuild", "TextureCompressor", "TextureFormat", "TextureFormatASTC", "TextureFormatDXT", "TextureFormatETC2", "TextureFormatIntelISPCTexComp", "TextureFormatUncompressed", "ToolMenus", "ToolWidgets", "TraceAnalysis", "TraceInsights", "TraceServices", "TreeMap", "TurnkeyIO", "UncontrolledChangelists", "Virtualization", "VisualGraphUtils", "VulkanShaderFormat", "Windows", "XGEController", "Zen"]
  let editorModules = @["ActorPickerMode", "AddContentDialog", "AdvancedPreviewScene", "AIGraph", "AnimationBlueprintEditor", "AnimationBlueprintLibrary", "AnimationEditor", "AnimationModifiers", "AnimGraph", "AssetTagsEditor", "AudioEditor", "BehaviorTreeEditor", "BlueprintEditorLibrary", "BlueprintGraph", "Blutility", "Cascade", "ClassViewer", "ClothingSystemEditor", "ClothingSystemEditorInterface", "ClothPainter", "CommonMenuExtensions", "ComponentVisualizers", "ConfigEditor", "ContentBrowser", "ContentBrowserData", "CSVtoSVG", "CurveAssetEditor", "CurveEditor", "CurveTableEditor", "DataLayerEditor", "DataTableEditor", "DerivedDataEditor", "DetailCustomizations", "DeviceProfileEditor", "DeviceProfileServices", "DistCurveEditor", "Documentation", "EditorConfig", "EditorFramework", "EditorSettingsViewer", "EditorStyle", "EditorSubsystem", "EditorWidgets", "EnvironmentLightingViewer", "Experimental", "FoliageEdit", "FontEditor", "GameplayTasksEditor", "GameProjectGeneration", "GraphEditor", "HardwareTargeting", "HierarchicalLODOutliner", "InputBindingEditor", "InternationalizationSettings", "IntroTutorials", "Kismet", "KismetCompiler", "KismetWidgets", "LandscapeEditor", "LandscapeEditorUtilities", "Layers", "LevelAssetEditor", "LevelEditor", "LevelInstanceEditor", "LocalizationCommandletExecution", "LocalizationDashboard", "MainFrame", "MaterialEditor", "MergeActors", "MeshPaint", "MovieSceneCaptureDialog", "MovieSceneTools", "NaniteTools", "NewLevelDialog", "OverlayEditor", "PackagesDialog", "Persona", "PhysicsAssetEditor", "PIEPreviewDeviceProfileSelector", "PIEPreviewDeviceSpecification", "PinnedCommandList", "PixelInspector", "PlacementMode", "PListEditor", "PluginWarden", "ProjectSettingsViewer", "ProjectTargetPlatformEditor", "PropertyEditor", "RewindDebuggerInterface", "SceneDepthPickerMode", "SceneOutliner", "Sequencer", "SequenceRecorder", "SequenceRecorderSections", "SequencerWidgets", "SerializedRecorderInterface", "SkeletalMeshEditor", "SkeletonEditor", "SourceControlWindows", "StaticMeshEditor", "StatsViewer", "StatusBar", "StringTableEditor", "StructViewer", "SubobjectDataInterface", "SubobjectEditor", "SwarmInterface", "TextureEditor", "ToolMenusEditor", "TranslationEditor", "TurnkeySupport", "UATHelper", "UMGEditor", "UndoHistory", "UnrealEd", "UnrealEdMessages", "ViewportInteraction", "ViewportSnapping", "VirtualTexturingEditor", "VREditor", "WorkspaceMenuStructure", "WorldBrowser", "WorldPartitionEditor"]
  
  let intermediateGenModules = @["AddContentDialog", "AdvancedPreviewScene", "AdvancedWidgets", "AIGraph", "AIModule", "AITestSuite", "AnalyticsVisualEditing", "Android", "AnimationBlueprintEditor", "AnimationBlueprintLibrary", "AnimationCore", "AnimationDataController", "AnimationModifiers", "AnimGraph", "AnimGraphRuntime", "AssetRegistry", "AssetTools", "AudioAnalyzer", "AudioEditor", "AudioExtensions", "AudioLinkCore", "AudioLinkEngine", "AudioMixer", "AudioPlatformConfiguration", "AugmentedReality", "AutomationController", "AutomationMessages", "AutomationTest", "AutomationWindow", "BehaviorTreeEditor", "BlueprintEditorLibrary", "BlueprintGraph", "BlueprintRuntime", "Blutility", "BuildPatchServices", "Cascade", "Chaos", "ChaosSolverEngine", "ChaosVehiclesEngine", "CinematicCamera", "ClassViewer", "ClientPilot", "ClothingSystemEditor", "ClothingSystemEditorInterface", "ClothingSystemRuntimeCommon", "ClothingSystemRuntimeInterface", "ClothingSystemRuntimeNv", "ClothPainter", "ComponentVisualizers", "ConfigEditor", "ContentBrowser", "ContentBrowserData", "CoreOnline", "CoreUObject", "CSVtoSVG", "CurveEditor", "DataLayerEditor", "DatasmithCore", "DetailCustomizations", "DeveloperSettings", "DeveloperToolSettings", "DeviceProfileServices", "DirectLink", "DynamicPlayRate", "EditorConfig", "EditorFramework", "EditorInteractiveToolsFramework", "EditorStyle", "EditorSubsystem", "Engine", "EngineMessages", "EngineSettings", "ExternalRpcRegistry", "EyeTracker", "FieldSystemEngine", "Foliage", "FoliageEdit", "FriendsAndChat", "FunctionalTesting", "GameMenuBuilder", "GameplayDebugger", "GameplayTags", "GameplayTasks", "GameplayTasksEditor", "GameProjectGeneration", "GeometryCollectionEngine", "GeometryFramework", "GraphEditor", "HardwareTargeting", "HeadMountedDisplay", "HierarchicalLODOutliner", "HoloLensPlatformEditor", "HordeExecutor", "ImageWriteQueue", "InputBindingEditor", "InputCore", "InteractiveToolsFramework", "InterchangeCore", "InterchangeEngine", "InternationalizationSettings", "IntroTutorials", "IOS", "JsonUtilities", "Kismet", "KismetWidgets", "Landscape", "LandscapeEditor", "LandscapeEditorUtilities", "LaunchDaemonMessages", "LevelAssetEditor", "LevelEditor", "LevelInstanceEditor", "LevelSequence", "LiveCoding", "LiveLinkAnimationCore", "LiveLinkInterface", "LiveLinkMessageBusFramework", "Localization", "LocalizationDashboard", "LogVisualizer", "MaterialBaking", "MaterialEditor", "MaterialShaderQualitySettings", "MaterialUtilities", "MediaAssets", "MediaUtils", "MergeActors", "MeshDescription", "MeshPaint", "MessagingRpc", "MoviePlayer", "MovieScene", "MovieSceneCapture", "MovieSceneTools", "MovieSceneTracks", "MRMesh", "NaniteTools", "NavigationSystem", "NetCore", "Overlay", "OverlayEditor", "PacketHandler", "Persona", "PhysicsAssetEditor", "PhysicsCore", "PhysicsUtilities", "PIEPreviewDeviceProfileSelector", "PIEPreviewDeviceSpecification", "PinnedCommandList", "PixelInspectorModule", "PortalMessages", "PortalRpc", "PortalServices", "ProfilerMessages", "PropertyEditor", "PropertyPath", "RemoteExecution", "RewindDebuggerInterface", "RigVM", "RigVMDeveloper", "RuntimeAssetCache", "SceneOutliner", "ScreenShotComparisonTools", "Sequencer", "SequenceRecorder", "SequenceRecorderSections", "Serialization", "SessionMessages", "SkeletalMeshEditor", "SkeletonEditor", "Slate", "SlateCore", "SlateReflector", "SourceCodeAccess", "SourceControl", "StageDataCore", "StaticMeshDescription", "StaticMeshEditor", "StatsViewer", "StatusBar", "StructViewer", "SubobjectDataInterface", "SubobjectEditor", "SwarmInterface", "TargetDeviceServices", "TextureEditor", "TextureUtilitiesCommon", "TimeManagement", "ToolMenus", "ToolMenusEditor", "TranslationEditor", "TypedElementFramework", "TypedElementRuntime", "UMG", "UMGEditor", "UndoHistory", "UnrealEd", "UnrealEdMessages", "VectorVM", "ViewportInteraction", "Virtualization", "VirtualTexturingEditor", "VisualGraphUtils", "VREditor", "WebBrowser", "WebBrowserTexture", "WidgetCarousel", "WindowsTargetPlatform", "WorldBrowser", "WorldPartitionEditor"]

  let moduleHeaders = 
    runtimeModules.map(module=>getEngineRuntimeIncludePathFor("Runtime", module)) & 
    developerModules.map(module=>getEngineRuntimeIncludePathFor("Developer", module)) & 
    editorModules.map(module=>getEngineRuntimeIncludePathFor("Editor", module)) & 
    intermediateGenModules.map(module=>getEngineIntermediateIncludePathFor(module))

  (essentialHeaders & moduleHeaders & editorHeaders).map(path => path.normalizedPath().normalizePathEnd())
  


proc getUESymbols*(conf: NimForUEConfig): seq[string] =
  let platformDir = if conf.targetPlatform == Mac: "Mac/x86_64" else: $conf.targetPlatform
  let confDir = $conf.targetConfiguration
  let engineDir = conf.engineDir
  let pluginDir = conf.pluginDir
  #We only support Debug and Development for now and Debug is Windows only
  let suffix = if conf.targetConfiguration == Debug : "-Win64-Debug" else: "" 
  proc getEngineRuntimeSymbolPathFor(prefix, moduleName:string): string =  
    when defined windows:
      engineDir / "Intermediate/Build" / platformDir / "UnrealEditor" / confDir / moduleName / &"{prefix}-{moduleName}{suffix}.lib"
    elif defined macosx:
      let platform = $conf.targetPlatform #notice the platform changed for the symbols (not sure how android/consoles/ios will work)
      engineDir / "Binaries" / platform / &"{prefix}-{moduleName}.dylib"

  proc getNimForUESymbols(): seq[string] = 
    when defined macosx:
      let libpath  = pluginDir / "Binaries" / $conf.targetPlatform / "UnrealEditor-NimForUEBindings.dylib"
      #notice this shouldnt be included when target <> Editor
      let libPathEditor  = pluginDir / "Binaries" / $conf.targetPlatform / "UnrealEditor-NimForUEEditor.dylib"
    elif defined windows:
      let libPath = pluginDir / "Intermediate/Build" / platformDir / "UnrealEditor" / confDir / &"NimForUEBindings/UnrealEditor-NimForUEBindings{suffix}.lib"
      let libPathEditor = pluginDir / "Intermediate/Build" / platformDir / "UnrealEditor" / confDir / &"NimForUEEditor/UnrealEditor-NimForUEEditor{suffix}.lib"

    @[libPath, libPathEditor]

  let modules = @["Core", "CoreUObject", "Engine"]
  let engineSymbolsPaths  = modules.map(modName=>getEngineRuntimeSymbolPathFor("UnrealEditor", modName))

  (engineSymbolsPaths & getNimForUESymbols()).map(path => path.normalizedPath())

