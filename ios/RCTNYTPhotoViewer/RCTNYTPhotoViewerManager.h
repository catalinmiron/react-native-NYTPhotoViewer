@import UIKit;

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>


@interface RCTNYTPhotoViewerManager : NSObject<RCTBridgeModule>

@property (nonatomic, retain) NYTPhotosViewController * photoViewer;
//
//- (void) hidePhotoViewer:(RCTResponseSenderBlock)callback;
//- (void) showPhotoViewer:(NSString*)source callback:(RCTResponseSenderBlock)callback;

@end
