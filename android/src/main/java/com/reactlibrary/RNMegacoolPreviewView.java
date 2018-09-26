package com.reactlibrary;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

import co.megacool.megacool.GifImageView;
import co.megacool.megacool.Megacool;

public class RNMegacoolPreviewView extends SimpleViewManager<GifImageView> {

    @Override
    protected GifImageView createViewInstance(ThemedReactContext reactContext) {
        GifImageView preview = Megacool.renderPreviewOfGif(RNMegacoolModule.recordingId);
        if (preview != null) preview.start();
        return preview;
    }

    @Override
    public String getName() {
        return "RNMegacoolPreview";
    }
}
