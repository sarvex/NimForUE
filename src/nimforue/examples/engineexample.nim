include ../unreal/prelude
import ../unreal/bindings/[slate,slatecore]
import ../unreal/coreuobject/coreuobject


uClass AObjectEngineExample of AActor:
  (BlueprintType)
  uprops(EditAnywhere, BlueprintReadWrite, ExposeOnSpawn):
    stringProp : FString
    intProp : int32
    # intProp2 : int32

  ufuncs(CallInEditor):
    proc testSlateAssignment() = 
      let slateObj = newUObject[UTextBlockWidgetStyle]()
      #UE_Log $slateObj.textBlockStyle
      var tbs = FTextBlockStyle(shadowOffset: FVector2D(x:400f, y: 200f))
      slateObj.textBlockStyle = tbs
      UE_Log $slateObj.textBlockStyle.shadowOffset.x