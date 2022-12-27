// Fill out your copyright notice in the Description page of Project Settings.


#include "NimForUEEngineSubsystem.h"
#if WITH_EDITOR
#include "Editor.h"
#include "EditorUtils.h"
#include "FNimReload.h"
#endif

#include "NimForUEFFI.h"
#include "ReinstanceBindings.h"


void UNimForUEEngineSubsystem::LoadNimGuest(FString NimError) {
	//Notice this function is static because it needs to be used in a FFI function.
	UNimForUEEngineSubsystem* THIS = GEngine->GetEngineSubsystem<UNimForUEEngineSubsystem>();
	// onNimForUELoaded(THIS->GetReloadTimesFor(THIS->NimPluginModule));
	// 	//The return value is not longer needed since the reinstance call now happens on nim
	// return;
	// // FNimHotReload* NimHotReload = static_cast<FNimHotReload*>(onNimForUELoaded(THIS->GetReloadTimesFor(THIS->NimPluginModule)));
	// ReinstanceBindings::ReinstanceNueTypes(THIS->NimPluginModule, NimHotReload, NimError);
}





void UNimForUEEngineSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{

	auto logger = [](NCSTRING msg) {
		UE_LOG(LogTemp, Log, TEXT("From NimForUEHost: %s"), *FString(msg));
	};
	registerLogger(logger);
	ensureGuestIsCompiled();
	checkReload();
	// FTransform::Identity
	TickDelegateHandle = FTSTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateUObject(this, &UNimForUEEngineSubsystem::Tick), 0.1);
}

void UNimForUEEngineSubsystem::Deinitialize()
{
	FTSTicker::GetCoreTicker().RemoveTicker(TickDelegateHandle);
}

int UNimForUEEngineSubsystem::GetReloadTimesFor(FString ModuleName) {
	if(ReloadCounter.Contains(ModuleName)) {
		return ReloadCounter[ModuleName];
	}
	return 0;
}

bool UNimForUEEngineSubsystem::Tick(float DeltaTime)
{
	
	checkReload();
	return true;
}
