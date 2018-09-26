//
//  RNMegacoolPreview.m
//  RNMegacool
//
//  Created by  on 2018-09-26.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "RNMegacoolPreview.h"
#import "RNMegacool.h" // for RECORDING_ID macro
#import <Megacool/Megacool.h>

@implementation RNMegacoolPreviewManager

// almost copy pasted from RNMegacool
- (void) find: (nonnull NSNumber *) tag view: (void (^) (MCLPreview *view)) handler {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *,UIView *> *viewRegistry) {
        id view = viewRegistry[tag];
        if (![view isKindOfClass: MCLPreview.class]) {
            RCTLogError(@"Invalid view returned from registry, expecting RNMegacoolView, got: %@", view);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ handler(view); });
        }
    }];
}

RCT_EXPORT_MODULE();

- (UIView *)view {
    MCLPreview* preview = [Megacool.sharedMegacool getPreviewWithConfig:^(MCLPreviewConfig * _Nonnull config) {
        config.recordingId = RECORDING_ID;
    }];
    [preview startAnimating];
    return preview;
}

@end
