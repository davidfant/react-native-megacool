
#import "RNMegacool.h"
#import "RNMegacool-Swift.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Megacool/Megacool.h>
@import Photos;

#define RNZ_REACT_TAG(name, ...) name: (nonnull NSNumber *) tag

@interface RNMegacoolView : UIView<MCLDelegate>

@property (nonatomic, copy) RCTDirectEventBlock onStartedRecording;
@property (nonatomic, copy) RCTDirectEventBlock onStoppedRecording;
@property (nonatomic, copy) RCTDirectEventBlock onStartedSharing;

@end

@implementation RNMegacoolView

-(void) megacoolDidCompleteShare {
    
}

-(void) megacoolDidDismissShareView {
    
}

@end


@implementation RNMegacoolManager

- (void) find: (nonnull NSNumber *) tag view: (void (^) (RNMegacoolView *view)) handler {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        id view = viewRegistry[tag];
        if (![view isKindOfClass: RNMegacoolView.class]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNMegacoolView, got: %@", view);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ handler(view); });
        }
    }];
}

RCT_EXPORT_MODULE();

- (UIView *)view {
    RNMegacoolView* view = [[RNMegacoolView alloc] init];
    [[Megacool sharedMegacool] setDelegate:view];
    return view;
}

RCT_EXPORT_VIEW_PROPERTY(onStartedRecording, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStoppedRecording, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onStartedSharing, RCTBubblingEventBlock);

RCT_CUSTOM_VIEW_PROPERTY(sharingText, NSString, UIView)         { [Megacool.sharedMegacool setSharingText:json]; }
RCT_CUSTOM_VIEW_PROPERTY(frameRate, NSNumber, UIView)           { [Megacool.sharedMegacool setFrameRate:[json floatValue]]; }
RCT_CUSTOM_VIEW_PROPERTY(playbackFrameRate, NSNumber, UIView)   { [Megacool.sharedMegacool setPlaybackFrameRate:[json floatValue]]; }
RCT_CUSTOM_VIEW_PROPERTY(maxFrames, NSNumber, UIView)           { [Megacool.sharedMegacool setMaxFrames:[json intValue]]; }

RCT_EXPORT_METHOD(RNZ_REACT_TAG(startRecording)) {
    [self find:tag view:^(RNMegacoolView *view) {
        [Megacool.sharedMegacool deleteRecording:RECORDING_ID];
        [[Megacool sharedMegacool] startRecording:view withConfig:^(MCLRecordingConfig * _Nonnull config) {
            config.recordingId = RECORDING_ID;
        }];
        if(view.onStartedRecording) view.onStartedRecording(@{});
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(stopRecording)) {
    [self find:tag view:^(RNMegacoolView *view) {
        [[Megacool sharedMegacool] stopRecording];
        if(view.onStoppedRecording) view.onStoppedRecording(@{});
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(videoUrl) resolver: (RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    MCLPreviewData* data = [[Megacool sharedMegacool] getPreviewDataForRecording:RECORDING_ID];
    [RNMegacoolVideoWriter createFrom:data.framePaths frameRate:(int32_t) data.playbackFrameRate callback:^(NSURL * _Nullable url) {
        if (url == nil) {
            return reject(@"100", @"Could not create video from Megacool", [[NSError alloc] init]);
        } else {
            resolve(url.path);
        }
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(saveVideoToCameraRoll) path: (NSString *) path resolver: (RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[[NSURL alloc] initFileURLWithPath:path]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != nil) {
            return reject([NSString stringWithFormat:@"%lu", error.code], error.domain, error);
        }
        
        resolve(@{});
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(saveImageToCameraRoll) path: (NSString *) path resolver: (RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject) {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:path]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != nil) {
            return reject([NSString stringWithFormat:@"%lu", error.code], error.domain, error);
        }
        
        resolve(@{});
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(presentTrackedShare)) {
    [self find:tag view:^(RNMegacoolView *view) {
        [Megacool.sharedMegacool presentShareWithConfig:^(MCLShareConfig * _Nonnull config) {
            config.recordingId = RECORDING_ID;
        }];
        if (view.onStartedSharing) view.onStartedSharing(@{});
    }];
}

RCT_EXPORT_METHOD(RNZ_REACT_TAG(presentShare) path: (NSString *) path) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // To share to Instagram, we can only send images or videos. Therefore we shouldn't sent text
        // (eg adding Megacool.sharedMegacool.sharingText to the activityItems array)
        UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path]] applicationActivities:nil];
        [UIApplication.sharedApplication.windows.firstObject.rootViewController presentViewController:vc animated:true completion:nil];
    });
}

RCT_EXPORT_METHOD(init: (NSString *) apiKey) {
    [Megacool startWithAppConfig:apiKey];
}

@end


