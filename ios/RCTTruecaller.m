#import "RCTTruecaller.h"
#import <React/RCTLog.h>

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

static NSString *payload = @"";
static NSString *signature = @"";
static NSString *signatureAlgorithm = @"";
static NSString *requestNonce = @"";

@implementation RCTTruecaller

RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(isTruecallerInstalled, resolver: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  BOOL result = [TCUtils isTruecallerInstalled];
  resolve([NSNumber numberWithBool:result]);
}

RCT_EXPORT_METHOD(initializeClientIOS:(NSString *)appKey appLink:(NSString *)appLink)
{
  NSLog(@"initializeClient");
  if ([[TCTrueSDK sharedManager] isSupported])
  {
    [TCTrueSDK sharedManager].delegate = self;
    [[TCTrueSDK sharedManager] setupWithAppKey:appKey appLink:appLink];
    _appLink=appLink;
    _appKey=appKey;
  }
  else
  {
    [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:[TCError errorWithCode:TCTrueSDKErrorCodeOSNotSupported]]];
    return;
  }

}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"didReceiveTrueProfileResponse",@"didReceiveTrueProfileResponseError"];
}


RCT_EXPORT_METHOD(requestTrueProfile)
{



  if (![TCUtils isOperatingSystemSupported])
  {

    [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:[TCError errorWithCode:TCTrueSDKErrorCodeOSNotSupported]]];
    return;
  }

  if (![TCUtils isTruecallerInstalled])
  {

    [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:[TCError errorWithCode:TCTrueSDKErrorCodeTruecallerNotInstalled]]];
    return;
  }

  if (_appKey == nil || _appKey.length == 0)
  {
    [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:[TCError errorWithCode:TCTrueSDKErrorCodeAppKeyMissing]]];
    return;
  }

  if (_appLink == nil || _appLink.length == 0)
  {
    [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:[TCError errorWithCode:TCTrueSDKErrorCodeAppLinkMissing]]];
    return;
  }
  if ([[TCTrueSDK sharedManager] isSupported])
  {
    [[TCTrueSDK sharedManager] setupWithAppKey:_appKey appLink:_appLink];
  }

  [TCTrueSDK sharedManager].delegate = self;
  TCTrueProfileRequest *profileRequest = [TCTrueProfileRequest new];
  profileRequest.appKey = _appKey;
  profileRequest.appLink = _appLink;
  profileRequest.appId = [[NSBundle mainBundle] bundleIdentifier];
  profileRequest.apiVersion = [TCUtils getAPIVersion];
  profileRequest.sdkVersion = [TCUtils getSDKVersion];
  profileRequest.appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
  profileRequest.requestNonce = [NSUUID UUID].UUIDString;
  NSURLComponents *urlComponents = [NSURLComponents componentsWithString:@"https://www.truecaller.com/userProfile"];
  NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:profileRequest];
  NSString *itemString = [itemData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:kTrueProfileRequestKey value:itemString];
  urlComponents.queryItems = @[queryItem];
  NSURL *url = urlComponents.URL;
  [TCUtils openUrl:url completionHandler:nil];
  NSLog(@"requestTrueProfile ");
};

- (void)willRequestProfileWithNonce:(nonnull NSString *)nonce;
{
  NSLog(@" nonce %@", nonce);
}

/*!
 * @brief Use this optional delegate method to get the whole response instance and implement additional security checks
 * @param profileResponse The profile response which contains the payload, signature and nonce
 */
- (void)didReceiveTrueProfileResponse:(nonnull TCTrueProfileResponse *)profileResponse;
{
  NSLog(@" profileResponse %@", profileResponse.payload);
  payload = profileResponse.payload;
  signature = profileResponse.signature;
  signatureAlgorithm = profileResponse.signatureAlgorithm;
  requestNonce = profileResponse.requestNonce;
}

- (void)didReceiveTrueProfile:(nonnull TCTrueProfile *)profile
{

  NSMutableDictionary *profileDetails=[[NSMutableDictionary alloc]init];

  [profileDetails setValue:profile.firstName forKey:@"firstName"];
  [profileDetails setValue:profile.lastName forKey:@"lastName"];
  [profileDetails setValue:profile.phoneNumber forKey:@"phoneNumber"];
  [profileDetails setValue:[NSNumber numberWithBool:profile.gender] forKey:@"gender"];
  [profileDetails setValue:profile.street forKey:@"street"];
  [profileDetails setValue:profile.city forKey:@"city"];
  [profileDetails setValue:profile.zipCode forKey:@"zipcode"];
  [profileDetails setValue:profile.countryCode forKey:@"countryCode"];
  [profileDetails setValue:profile.facebookID forKey:@"facebookId"];
  [profileDetails setValue:profile.twitterID forKey:@"twitterId"];
  [profileDetails setValue:profile.email forKey:@"email"];
  [profileDetails setValue:profile.avatarURL forKey:@"avatarUrl"];
  [profileDetails setValue:[NSNumber numberWithBool:profile.isVerified] forKey:@"isTrueName"];
  [profileDetails setValue:[NSNumber numberWithBool:profile.isAmbassador] forKey:@"isAmbassador"];
  [profileDetails setValue:profile.companyName forKey:@"companyName"];
  [profileDetails setValue:profile.jobTitle forKey:@"jobTitle"];
  [profileDetails setValue:payload forKey:@"payload"];
  [profileDetails setValue:signature forKey:@"signature"];
  [profileDetails setValue:signatureAlgorithm forKey:@"signatureAlgorithm"];
  [profileDetails setValue:requestNonce forKey:@"requestNonce"];


  [self sendEventWithName:@"didReceiveTrueProfileResponse" body:profileDetails];
}
- (void)didFailToReceiveTrueProfileWithError:(nonnull TCError *)error
{

  [self sendEventWithName:@"didReceiveTrueProfileResponseError" body:[RCTTruecaller getErrorInfo:error]];

}

+ (NSDictionary*)getErrorInfo:(nonnull TCError *)error {
  return @{
    @"code":[NSNumber numberWithInteger:[error getErrorCode]],
    @"description": [error localizedDescription] != nil ? [error localizedDescription] : @"",
    @"reason": [error localizedFailureReason] != nil ? [error localizedFailureReason] : @"",
    @"recoverySuggestion": [error localizedRecoverySuggestion] != nil ? [error localizedRecoverySuggestion] : @"",
  };
}
@end
