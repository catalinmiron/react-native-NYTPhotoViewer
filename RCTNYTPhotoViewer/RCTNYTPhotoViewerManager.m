#import "RCTNYTPhotoViewerManager.h"

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "RCTNYTPhoto.h"


@interface RCTNYTPhotoViewerManager() <NYTPhotosViewControllerDelegate>

@property (nonatomic) NSArray *photos;

@end


@implementation RCTNYTPhotoViewerManager

@synthesize bridge = _bridge;

- (id)init {
  self = [super init];
  if (self != nil) {
    RCTNYTPhoto *photo = [[RCTNYTPhoto alloc] init];
    self.photos = @[photo];
    self.photoViewer = [[NYTPhotosViewController alloc] initWithPhotos:self.photos initialPhoto:self.photos.firstObject delegate:self];
  }
  return self;
}

- (void) doHidePhotoViewer:(RCTResponseSenderBlock)callback {
  id delegate = [[UIApplication sharedApplication] delegate];
  [[[delegate window] rootViewController] dismissViewControllerAnimated:YES completion:^{
    callback(@[[NSNull null]]);
  }];
}

- (void) doShowPhotoViewer:(NSString *)source callback:(RCTResponseSenderBlock)callback {
  //NOTE BRN: The loading spinner only shows the first time. This issue will need to be resolved in NYTPhotoViewer
  RCTNYTPhoto *photo = [self.photos objectAtIndex:0];
  photo.imageData = nil;
  photo.image = nil;
  [self.photoViewer updateImageForPhoto:photo];

  id delegate = [[UIApplication sharedApplication] delegate];
  [[[delegate window] rootViewController] presentViewController:self.photoViewer animated:YES completion:^{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
      NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: source]];
      dispatch_async(dispatch_get_main_queue(), ^{
        if ( data == nil ) {

          // Craft a failure message
          NSDictionary *errorDict = @{
              @"success" : @NO,
              @"errMsg"  : [NSString stringWithFormat:@"Could not load image from %@", source]
          };
          return callback(@[errorDict]);
        }

        photo.imageData = data;
        photo.image = [UIImage imageWithData: data];
        [self.photoViewer updateImageForPhoto:photo];
        return callback(@[[NSNull null]]);
      });
    });
  }];
}

#pragma mark RCT_EXPORT

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(hidePhotoViewer:(RCTResponseSenderBlock)callback) {
  [self doHidePhotoViewer:callback];
}

RCT_EXPORT_METHOD(showPhotoViewer:(NSString *)source callback:(RCTResponseSenderBlock)callback) {
  [self doShowPhotoViewer:source callback:callback];
}


//- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
//  [self dismissViewControllerAnimated:animated userInitiated:NO completion:completion];
//}



#pragma mark - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id <NYTPhoto>)photo {
    //TODO BRN:
    return nil;
}

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController loadingViewForPhoto:(id <NYTPhoto>)photo {
    /*if ([photo isEqual:self.photos[NYTViewControllerPhotoIndexCustomEverything]]) {
        UILabel *loadingLabel = [[UILabel alloc] init];
        loadingLabel.text = @"Custom Loading...";
        loadingLabel.textColor = [UIColor greenColor];
        return loadingLabel;
    }*/

    return nil;
}

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController captionViewForPhoto:(id <NYTPhoto>)photo {
    /*if ([photo isEqual:self.photos[NYTViewControllerPhotoIndexCustomEverything]]) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Custom Caption View";
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        return label;
    }*/

    return nil;
}

- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {
    /*if ([photo isEqual:self.photos[NYTViewControllerPhotoIndexCustomMaxZoomScale]]) {
        return 10.0f;
    }*/

    return 2.0f;
}

- (NSDictionary *)photosViewController:(NYTPhotosViewController *)photosViewController overlayTitleTextAttributesForPhoto:(id <NYTPhoto>)photo {
    /*if ([photo isEqual:self.photos[NYTViewControllerPhotoIndexCustomEverything]]) {
        return @{NSForegroundColorAttributeName: [UIColor grayColor]};
    }*/

    return nil;
}

- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex totalPhotoCount:(NSUInteger)totalPhotoCount {
    return nil;
}

- (void)photosViewController:(NYTPhotosViewController *)photosViewController didNavigateToPhoto:(id <NYTPhoto>)photo atIndex:(NSUInteger)photoIndex {
    NSLog(@"Did Navigate To Photo: %@ identifier: %lu", photo, (unsigned long)photoIndex);
}

- (void)photosViewController:(NYTPhotosViewController *)photosViewController actionCompletedWithActivityType:(NSString *)activityType {
    NSLog(@"Action Completed With Activity Type: %@", activityType);
}

- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController {
    NSLog(@"Did Dismiss Photo Viewer: %@", photosViewController);
    NSDictionary *event = @{};
    [_bridge.eventDispatcher sendDeviceEventWithName:@"NYTPhotoViewer:Dismissed" body:event];
}

@end
