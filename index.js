import {NativeModules,NativeEventEmitter,Platform} from 'react-native';
const EventEmitter = new NativeEventEmitter(Platform.OS=="ios" ? NativeModules.Truecaller : NativeModules.MyModule);
const RCTTruecaller =Platform.OS=="ios" ? NativeModules.Truecaller : NativeModules.MyModule;


const TRUECALLER = {};
export const TRUECALLEREvent = 
{
  TrueProfileResponse: 'didReceiveTrueProfileResponse',
  TrueProfileResponseError: 'didReceiveTrueProfileResponseError',
};

TRUECALLER.isTruecallerInstalled = () => {
    return RCTTruecaller.isTruecallerInstalled();
}

TRUECALLER.initializeClient = () => 
{
    return RCTTruecaller.initializeClient();
};
TRUECALLER.initializeClientIOS = (appKey,appLink) => 
{
    return RCTTruecaller.initializeClientIOS(appKey,appLink);
};
TRUECALLER.requestTrueProfile = () => 
{
    return RCTTruecaller.requestTrueProfile();
};

TRUECALLER.on = (event, callback) => 
{
    if (!Object.values(TRUECALLEREvent).includes(event)) {
      throw new Error(`Invalid TRUECALLEREvent event subscription, use import {TRUECALLEREvent} from 'react-native-truecaller' to avoid typo`);
    };
    return EventEmitter.addListener(event, callback);
};

export default TRUECALLER;