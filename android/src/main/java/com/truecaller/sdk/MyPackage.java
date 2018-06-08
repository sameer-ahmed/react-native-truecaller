package com.truecaller.sdk;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.truecaller.sdk.MyModule;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MyPackage implements ReactPackage {

  MyModule myModule;
  ReactApplicationContext mReactContext;

  @Override
  public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
    mReactContext=reactContext;
    List<NativeModule> modules = new ArrayList<>();
    myModule=new MyModule(reactContext);
    modules.add(myModule);
    return modules;
  }

  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return Collections.emptyList();
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    return Collections.emptyList();
  }
}