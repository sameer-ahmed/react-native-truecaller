#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>
#import "TrueSDK/TrueSDK.h"

@interface RCTTruecaller : RCTEventEmitter <RCTBridgeModule,TCTrueSDKDelegate>

@property  RCTResponseSenderBlock globalCallback;
@property (retain,nonatomic)  NSString *appKey;
@property (retain,nonatomic)  NSString *appLink;

@end


