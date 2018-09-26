package com.reactlibrary;

import android.widget.RelativeLayout;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

import javax.annotation.Nullable;

import co.megacool.megacool.Megacool;

public class RNMegacoolView extends ViewGroupManager<RelativeLayout> {

    @Override
    protected RelativeLayout createViewInstance(ThemedReactContext reactContext) {
        return new RelativeLayout(reactContext);
    }

    @Nullable
    @Override
    public Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                "onStartedRecording", MapBuilder.of("registrationName", "onStartedRecording"),
                "onStoppedRecording", MapBuilder.of("registrationName", "onStoppedRecording"),
                "onStartedSharing", MapBuilder.of("registrationName", "onStartedSharing")
        );
    }

    @Override
    public String getName() {
        return "RNMegacool";
    }

    @ReactProp(name="frameRate", defaultInt=10)
    public void setFrameRate(RelativeLayout view, int frameRate) {
        Megacool.setFrameRate(frameRate);
    }

    @ReactProp(name="playbackFrameRate", defaultInt=10)
    public void setPlaybackFrameRate(RelativeLayout view, int playbackFrameRate) {
        Megacool.setPlaybackFrameRate(playbackFrameRate);
    }

    @ReactProp(name="maxFrames", defaultInt=50)
    public void setMaxFrames(RelativeLayout view, int maxFrames) {
        Megacool.setMaxFrames(maxFrames);
    }

    @ReactProp(name="lastFrameDelay", defaultInt=2000)
    public void setLastFrameDelay(RelativeLayout view, int lastFrameDelay) {
        Megacool.setLastFrameDelay(lastFrameDelay);
    }

    @ReactProp(name="sharingText")
    public void setSharingText(RelativeLayout view, String sharingText) {
        Megacool.setSharingText(sharingText);
    }
}
