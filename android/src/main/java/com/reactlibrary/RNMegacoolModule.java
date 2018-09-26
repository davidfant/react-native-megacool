
package com.reactlibrary;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.view.View;
import android.widget.RelativeLayout;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import co.megacool.megacool.Megacool;
import co.megacool.megacool.PreviewData;
import co.megacool.megacool.RecordingConfig;

public class RNMegacoolModule extends ReactContextBaseJavaModule {

    public static String recordingId = "RNMegacoolAndroidRecording";
    private static RecordingConfig config = new RecordingConfig().id(recordingId);

    private final ReactApplicationContext reactContext;

    private interface FindViewCallback<T> {
        void run(T view);
    }

    private <T extends View> void findView(final int reactTag, final Class<T> type, final FindViewCallback<T> callback) {
        getReactApplicationContext().getNativeModule(UIManagerModule.class).addUIBlock(new UIBlock() {
            @Override
            public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
                View view = nativeViewHierarchyManager.resolveView(reactTag);
                if (view.getClass() == type) {
                    callback.run(type.cast(view));
                }
            }
        });
    }

    public RNMegacoolModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNMegacoolManager";
    }

    @ReactMethod
    public void init(String apiKey) {
        Megacool.start(reactContext, apiKey);
    }

    @ReactMethod
    public void startRecording(final int reactTag) {
        findView(reactTag, RelativeLayout.class, new FindViewCallback<RelativeLayout>() {
            @Override
            public void run(RelativeLayout view) {
                // Clear previous recording before creating a new one with the same id
                Megacool.deleteRecording(recordingId);
                Megacool.startRecording(view, config);
                getReactApplicationContext()
                        .getJSModule(RCTEventEmitter.class)
                        .receiveEvent(view.getId(), "onStartedRecording", null);
            }
        });
    }

    @ReactMethod
    public void stopRecording(int reactTag) {
        findView(reactTag, RelativeLayout.class, new FindViewCallback<RelativeLayout>() {
            @Override
            public void run(RelativeLayout view) {
                Megacool.stopRecording();
                getReactApplicationContext()
                        .getJSModule(RCTEventEmitter.class)
                        .receiveEvent(view.getId(), "onStoppedRecording", null);
            }
        });
    }

    @ReactMethod
    public void presentTrackedShare(int reactTag) {
        findView(reactTag, RelativeLayout.class, new FindViewCallback<RelativeLayout>() {
            @Override
            public void run(RelativeLayout view) {
                Megacool.share();
                getReactApplicationContext()
                        .getJSModule(RCTEventEmitter.class)
                        .receiveEvent(view.getId(), "onStartedSharing", null);
            }
        });
    }

    @ReactMethod
    public void presentShare(int reactTag, final String imagePath) {
        // TODO(fant): once the path returned from this.videoUrl
        // is actually a video path (and not an image path), this
        // should share a video instead of image
        findView(reactTag, RelativeLayout.class, new FindViewCallback<RelativeLayout>() {
            @Override
            public void run(RelativeLayout view) {
                // https://stackoverflow.com/questions/16300959/android-share-image-from-url
                try {
                    Bitmap image = BitmapFactory.decodeFile(imagePath);

                    File file =  new File(getReactApplicationContext().getExternalFilesDir(Environment.DIRECTORY_PICTURES), "share_image_" + System.currentTimeMillis() + ".png");
                    FileOutputStream out = new FileOutputStream(file);
                    image.compress(Bitmap.CompressFormat.PNG, 90, out);
                    out.close();

                    Intent shareIntent = new Intent(Intent.ACTION_SEND);
                    shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
                    shareIntent.setType("image/png");

                    Intent chooserIntent = Intent.createChooser(shareIntent, "Share");
                    chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    getReactApplicationContext().startActivity(chooserIntent);

                    getReactApplicationContext()
                            .getJSModule(RCTEventEmitter.class)
                            .receiveEvent(view.getId(), "onStartedSharing", null);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    @ReactMethod
    public void saveVideoToCameraRoll(int reactTag, String videoPath) {
        saveImageToCameraRoll(reactTag, videoPath);
    }

    @ReactMethod
    public void saveImageToCameraRoll(int reactTag, String imagePath) {
        Bitmap image = BitmapFactory.decodeFile(imagePath);
        MediaStore.Images.Media.insertImage(getReactApplicationContext().getContentResolver(), image, "", "");
    }

    @ReactMethod
    public void videoUrl(int reactTag, Promise promise) {
        PreviewData data = Megacool.getPreviewDataForRecording(recordingId);
        promise.resolve(data.getFramePaths()[0]);
        // TODO(fant): actually return a video url here!
        // JCodec doesn't perform well enough to make this reasonable
        // (probably I'm doing something very wrong since it takes 5s
        // to encode every frame... Maybe running in release would
        // improve things. Other approaches can be found here:
        // https://stackoverflow.com/questions/40315349/how-to-create-a-video-from-an-array-of-images-in-android
    }
}