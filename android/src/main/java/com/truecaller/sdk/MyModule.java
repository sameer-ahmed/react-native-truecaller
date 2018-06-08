package com.truecaller.sdk;

import android.app.Activity;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.truecaller.android.sdk.ITrueCallback;
import com.truecaller.android.sdk.TrueClient;
import com.truecaller.android.sdk.TrueError;
import com.truecaller.android.sdk.TrueProfile;


public class MyModule extends ReactContextBaseJavaModule implements ITrueCallback{

    private Callback mErrorCall;
    private Callback mSuccessCall;
    private TrueClient mTrueClient;
    private String TAG="MyModule";
    private String mTruecallerRequestNonce;

    private  ReactContext reactContext;
    private ActivityEventListener mEventListener =new BaseActivityEventListener(){
        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
            if (null != mTrueClient && mTrueClient.onActivityResult(requestCode, resultCode, data)) {
                return;
            }
        }
    };


    public MyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext=reactContext;
        reactContext.addActivityEventListener(mEventListener);
    }

    @Override
    public String getName() {
        return "MyModule";
    }


    @ReactMethod
    public void initializeClient() {
        Activity activity = getCurrentActivity();
        mTrueClient = new TrueClient(activity, this);
        mTrueClient.setReqNonce(Utils.randomString(11));
        mTruecallerRequestNonce = mTrueClient.generateRequestNonce();
    }


    @ReactMethod
    public void click(
            String msg,
            Callback errorCallback,
            Callback successCallback) {
        try {
            this.mErrorCall=errorCallback;
            this.mSuccessCall=successCallback;
            getUserDetail();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    void getUserDetail(){
        Activity activity = getCurrentActivity();
        mTrueClient.getTruecallerUserProfile(activity);
    }





    @ReactMethod
    public void requestTrueProfile()
     {
         Activity activity = getCurrentActivity();
         mTrueClient.getTruecallerUserProfile(activity);
     }
    @Override
    public void onSuccesProfileShared(@NonNull TrueProfile trueProfile)
    {

        WritableMap params = Arguments.createMap();


        params.putString("firstName",trueProfile.firstName);

        params.putString("lastName",trueProfile.lastName);

        params.putString("phoneNumber",trueProfile.phoneNumber);

        params.putString("gender",trueProfile.gender);

        params.putString("street",trueProfile.street);

        params.putString("city",trueProfile.city);

        params.putString("zipcode",trueProfile.zipcode);

        params.putString("countryCode",trueProfile.countryCode);

        params.putString("facebookId",trueProfile.facebookId);

        params.putString("twitterId",trueProfile.twitterId);

        params.putString("email",trueProfile.email);

        params.putString("url",trueProfile.url);

        params.putString("avatarUrl",trueProfile.avatarUrl);

        params.putBoolean("isTrueName",trueProfile.isTrueName);

        params.putBoolean("isAmbassador",trueProfile.isAmbassador);

        params.putString("companyName",trueProfile.companyName);

        params.putString("jobTitle",trueProfile.jobTitle);

        params.putString("payload",trueProfile.payload);

        params.putString("signature",trueProfile.signature);

        params.putString("signatureAlgorithm",trueProfile.signatureAlgorithm);

        params.putString("requestNonce",trueProfile.requestNonce);

        params.putBoolean("isSimChanged",trueProfile.isSimChanged);

        params.putString("verificationMode",trueProfile.verificationMode);

        sendEvent(reactContext, "didReceiveTrueProfileResponse", params);

    }

    @Override
    public void onFailureProfileShared(@NonNull TrueError trueError) {
        WritableMap params = Arguments.createMap();
        params.putString("profile","error");

        sendEvent(reactContext, "didReceiveTrueProfileResponseError", params);

    }


    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
