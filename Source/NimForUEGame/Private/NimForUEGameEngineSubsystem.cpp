﻿// Fill out your copyright notice in the Description page of Project Settings.


#include "NimForUEGameEngineSubsystem.h"

/*
*  NueLoadedFrom* {.size:sizeof(uint8), exportc .} = enum
nlfPreEngine = 0, #before the engine is loaded, when the plugin code is registered.
nlfPostDefault = 1, #after all modules are loaded (so all the types exists in the reflection system) this is also hot reloads. Should attempt to emit everything, layers before and after
nlfEditor = 2 # Dont act different as loaded. Just Livecoding
nlfCommandlet = 3 #while on the commandlet. Nothing special. Dont act different as loaded 

*/

// extern "C" void startNue(uint8 calledFrom);
// // void NimMain();
//
// void StartNue() {
// 	FCoreUObjectDelegates::ReloadCompleteDelegate.AddLambda([&](EReloadCompleteReason Reason) {
// 		// BeginReload(ActiveReloadType, IReload& Interface)
// 		UE_LOG(LogTemp, Log, TEXT("Reinstancing LC reason: $s"))
// 		startNue(2);
// 		
// 	});
// 	// #if !WITH_EDITOR
// 	// NimMain();
// 	startNue(1);
// 	// #endif
// }/

void UNimForUEGameEngineSubsystem::Initialize(FSubsystemCollectionBase& Collection) {

	Super::Initialize(Collection);
	// StartNue();
}
