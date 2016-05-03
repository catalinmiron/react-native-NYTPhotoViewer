#import "RCTNYTPhotoViewerManager.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <NYTPhotoViewer/NYTPhoto.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "RCTNYTPhoto.h"


@interface RCTNYTPhotoViewerManager() <NYTPhotosViewControllerDelegate>

@property (nonatomic) NSMutableDictionary <NSString *, RCTNYTPhoto *>  *photoMap;
@property (nonatomic) UIBarButtonItem *actionButton;
@property (nonatomic) UIBarButtonItem *defaultActionButton;

@end


@implementation RCTNYTPhotoViewerManager

@synthesize bridge = _bridge;

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
  ALAssetRepresentation *rep = (__bridge id)info;

  NSError *error = nil;
  size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];

  if (countRead == 0 && error) {
    // We have no way of passing this info back to the caller, so we log it, at least.
    NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
  }

  return countRead;
}

static void releaseAssetCallback(void *info) {
  // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
  // This release balances that retain.
  CFRelease(info);
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
  static dispatch_once_t pred = 0;
  static ALAssetsLibrary *library = nil;
  dispatch_once(&pred, ^{
    library = [[ALAssetsLibrary alloc] init];
  });
  return library;
}

- (id)init {
  self = [super init];
  if (self != nil) {

    self.photoMap = [[NSMutableDictionary alloc] init];
    self.photoViewer = [[NYTPhotosViewController alloc] initWithPhotos:@[] initialPhoto:nil delegate:self];
    self.defaultActionButton = self.photoViewer.rightBarButtonItem;
    self.actionButton = self.photoViewer.rightBarButtonItem;
  }
  return self;
}

- (void) doHidePhotoViewer:(RCTResponseSenderBlock)callback {
  id delegate = [[UIApplication sharedApplication] delegate];
  dispatch_async(dispatch_get_main_queue(), ^{
    [[[delegate window] rootViewController] dismissViewControllerAnimated:YES completion:^{
      callback(@[]);
    }];
  });
}

- (void) doShowPhotoViewer:(RCTResponseSenderBlock)callback {
  id delegate = [[UIApplication sharedApplication] delegate];
  dispatch_async(dispatch_get_main_queue(), ^{
    [[[delegate window] rootViewController] presentViewController:self.photoViewer animated:YES completion:^{
      callback(@[]);
    }];
  });
}

- (void) doHideActionButton {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer setRightBarButtonItem:nil];
  });
}

- (void) doShowActionButton {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer setRightBarButtonItems:@[self.actionButton]];
  });
}

- (void) doShowActionButton:(NSDictionary *)options {
  NSString *title = [options objectForKey:@"title"];
  if (title) {
    self.actionButton = [[UIBarButtonItem alloc] initWithTitle:title
    style:UIBarButtonItemStylePlain
    target:self.defaultActionButton.target
    action:self.defaultActionButton.action];
  } else {
    self.actionButton = self.defaultActionButton;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer setRightBarButtonItems:@[self.actionButton]];
  });
}

- (void) doDisplayPhotoAtIndex:(NSInteger)index callback:(RCTResponseSenderBlock)callback {
  id photo = [self.photoViewer photoAtIndex:index];
  if (!photo) {
    NSDictionary *errorDict = @{
      @"success" : @NO,
      @"type" : @"NoPhotoAtIndex",
      @"message"  : [NSString stringWithFormat:@"No photo at index %@", index]
    };
    return callback(@[errorDict]);
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer displayPhoto:photo animated:YES];
    callback(@[]);
  });
}

- (void) doDisplayPhotoWithSource:(NSString *)source callback:(RCTResponseSenderBlock)callback {
  RCTNYTPhoto *photo = [self.photoMap objectForKey:source];
  if (!photo) {
    NSDictionary *errorDict = @{
      @"success" : @NO,
      @"type" : @"NoPhotoWithSource",
      @"message"  : [NSString stringWithFormat:@"No photo was found with source %@", source]
    };
    return callback(@[errorDict]);
  }

  NSUInteger index = [self.photoViewer indexOfPhoto:photo];
  if (index == NSNotFound) {
    NSDictionary *errorDict = @{
      @"success" : @NO,
      @"type" : @"NoPhotoWithSource",
      @"message"  : [NSString stringWithFormat:@"No photo was found with source %@", source]
    };
    return callback(@[errorDict]);
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer displayPhoto:photo animated:YES];
    callback(@[]);
  });
}

- (void) doAddPhotos:(NSArray <NSString *> *)sources callback:(RCTResponseSenderBlock)callback {
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  for (NSString *source in sources) {
    RCTNYTPhoto *photo = [self generatePhoto:source];
    if (photo) {
      NSUInteger index = [self.photoViewer indexOfPhoto:photo];
      if (index == NSNotFound) {
        [photos addObject:photo];
      }
    }
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer addPhotos:photos];
    callback(@[]);
  });
}

- (void) doClearPhotos:(RCTResponseSenderBlock)callback {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.photoViewer clearPhotos];
    callback(@[]);
  });
}

- (void) doIndexOfPhoto:(NSString *)source callback:(RCTResponseSenderBlock)callback {
  RCTNYTPhoto *photo = [self.photoMap objectForKey:source];
  if (photo) {
    NSUInteger index = [self.photoViewer indexOfPhoto:photo];
    if (index == NSNotFound) {
      return callback(@[[NSNull null], @-1]);
    }
    return callback(@[[NSNull null], @(index)]);
  }
  NSDictionary *errorDict = @{
    @"success" : @NO,
    @"type" : @"NoPhotoWithSource",
    @"message"  : [NSString stringWithFormat:@"No photo was found with source %@", source]
  };
  callback(@[errorDict]);
}

- (void) doPhotoAtIndex:(NSInteger)index callback:(RCTResponseSenderBlock)callback {
  RCTNYTPhoto *photo = (RCTNYTPhoto *)[self.photoViewer photoAtIndex:index];
  if (photo) {
    callback(@[[NSNull null], photo.source]);
  } else {
    NSDictionary *errorDict = @{
      @"success" : @NO,
      @"type" : @"NoPhotoAtIndex",
      @"message"  : [NSString stringWithFormat:@"No photo at index %@", index]
    };
    callback(@[errorDict]);
  }
}

- (void) doRemovePhotos:(NSArray *)sources callback:(RCTResponseSenderBlock)callback {

}

- (void) doUpdatePhotoAtIndex:(NSInteger)index source:(NSString *)source callback:(RCTResponseSenderBlock)callback {
  // RCTNYTPhoto *photo = [self.photoViewer objectAtIndex:0];
  // photo.imageData = nil;
  // photo.image = nil;
  // dispatch_async(dispatch_get_main_queue(), ^{
  //   [self.photoViewer updateImageForPhoto:photo];
  // });
}


#pragma mark HELPER_METHODS

- (RCTNYTPhoto *) generatePhoto:(NSString *)source {
  RCTNYTPhoto *photo = [self.photoMap objectForKey:source];
  if (!photo) {
    photo = [self makePhoto:source];
  }
  if (photo.isLoadFailed) {
    return nil;
  }
  return photo;
}

//callback:(void(^)(NSData *))handler
- (void) loadPhoto:(NSString *)source  {
  dispatch_async(dispatch_get_global_queue(0,0), ^{
    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: source]];
    dispatch_async(dispatch_get_main_queue(), ^{
      RCTNYTPhoto *photo = [self.photoMap objectForKey:source];
      if ( data == nil ) {
        NSLog(@"Could not load photo from source %@", source);
        photo.loadFailed = YES;
        //TODO BRN: Perhaps the best thing to do would be show a load error icon in the photo viewer instead of removing the photo?
        [self.photoViewer removePhotos:@[photo]];
        return;
      }
      photo.imageData = data;
      //photo.image = [UIImage imageWithData: data];
      [self.photoViewer updateImageForPhoto:photo];
    });
  });
}

- (void) loadAsset:(NSString *)source  {
  dispatch_async(dispatch_get_global_queue(0,0), ^{
    NSURL *assetUrl = [NSURL URLWithString: source];
    RCTNYTPhoto *photo = [self.photoMap objectForKey:source];
    ALAssetsLibrary *library = [RCTNYTPhotoViewerManager defaultAssetsLibrary];
    [library assetForURL:assetUrl
      resultBlock:^(ALAsset *asset) {

        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSString* MIMEType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
                ((__bridge CFStringRef)[rep UTI], kUTTagClassMIMEType);

        if ([MIMEType isEqualToString:@"image/gif"]) {
          Byte *buffer = (Byte*)malloc(rep.size);
          NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
          NSData *imageData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
          if (imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
              photo.imageData = imageData;
              [self.photoViewer updateImageForPhoto:photo];
            });
          } else {
            NSLog(@"Could not load photo from source %@", source);
            photo.loadFailed = YES;
            //TODO BRN: Perhaps the best thing to do would be show a load error icon in the photo viewer instead of removing the photo?
            [self.photoViewer removePhotos:@[photo]];
          }
        } else {
          uint size = 1080 * 1920;
          UIImage *image = [self thumbnailForAsset:asset maxPixelSize:size];

          if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
              photo.image = image;
              [self.photoViewer updateImageForPhoto:photo];
            });
          } else {
            NSLog(@"Could not load photo from source %@", source);
            photo.loadFailed = YES;
            //TODO BRN: Perhaps the best thing to do would be show a load error icon in the photo viewer instead of removing the photo?
            [self.photoViewer removePhotos:@[photo]];
          }
        }
      }
      failureBlock:^(NSError *myerror) {
        NSLog(@"Could not load photo from source %@", source);
        photo.loadFailed = YES;
        //TODO BRN: Perhaps the best thing to do would be show a load error icon in the photo viewer instead of removing the photo?
        [self.photoViewer removePhotos:@[photo]];
      }];
  });
}

- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
  NSParameterAssert(asset != nil);
  NSParameterAssert(size > 0);

  ALAssetRepresentation *rep = [asset defaultRepresentation];

  CGDataProviderDirectCallbacks callbacks = {
    .version = 0,
    .getBytePointer = NULL,
    .releaseBytePointer = NULL,
    .getBytesAtPosition = getAssetBytesCallback,
    .releaseInfo = releaseAssetCallback,
  };

  CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
  CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);

  CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
    (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
    (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:size],
    (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
  });
  CFRelease(source);
  CFRelease(provider);

  if (!imageRef) {
    return nil;
  }

  UIImage *toReturn = [UIImage imageWithCGImage:imageRef];

  CFRelease(imageRef);

  return toReturn;
}

- (RCTNYTPhoto *) makePhoto:(NSString *)source {
  RCTNYTPhoto *photo = [[RCTNYTPhoto alloc] initWithSource:source];
  [self.photoMap setObject:photo forKey:source];
  if ([source hasPrefix:@"assets-library:"]) {
    [self loadAsset:source];
  } else {
    [self loadPhoto:source];
  }
  return photo;
}


#pragma mark RCT_EXPORT

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(hidePhotoViewer:(RCTResponseSenderBlock)callback) {
  [self doHidePhotoViewer:callback];
}

RCT_EXPORT_METHOD(showPhotoViewer:(RCTResponseSenderBlock)callback) {
  [self doShowPhotoViewer:callback];
}

RCT_EXPORT_METHOD(hideActionButton) {
  [self doHideActionButton];
}

RCT_EXPORT_METHOD(showActionButton:(NSDictionary *)options) {
  [self doShowActionButton:options];
}

RCT_EXPORT_METHOD(displayPhotoAtIndex:(NSInteger)index callback:(RCTResponseSenderBlock)callback) {
  [self doDisplayPhotoAtIndex:index callback:callback];
}

RCT_EXPORT_METHOD(displayPhotoWithSource:(NSString *)source callback:(RCTResponseSenderBlock)callback) {
  [self doDisplayPhotoWithSource:source callback:callback];
}

RCT_EXPORT_METHOD(addPhotos:(NSArray *)sources callback:(RCTResponseSenderBlock)callback) {
  [self doAddPhotos:sources callback:callback];
}

RCT_EXPORT_METHOD(clearPhotos:(RCTResponseSenderBlock)callback) {
  [self doClearPhotos:callback];
}

RCT_EXPORT_METHOD(indexOfPhoto:(NSString *)source callback:(RCTResponseSenderBlock)callback) {
  [self doIndexOfPhoto:source callback:callback];
}

RCT_EXPORT_METHOD(photoAtIndex:(NSInteger)index callback:(RCTResponseSenderBlock)callback) {
  [self doPhotoAtIndex:index callback:callback];
}

RCT_EXPORT_METHOD(removePhotos:(NSArray *)sources callback:(RCTResponseSenderBlock)callback) {
  [self doRemovePhotos:sources callback:callback];
}

RCT_EXPORT_METHOD(updatePhotoAtIndex:(NSInteger)index source:(NSString *)source callback:(RCTResponseSenderBlock)callback) {
  [self doUpdatePhotoAtIndex:index source:source callback:callback];
}


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

- (BOOL)photosViewController:(NYTPhotosViewController *)photosViewController handleActionButtonTappedForPhoto:(id <NYTPhoto>)photo atIndex:(NSUInteger)photoIndex {
  if (self.defaultActionButton != self.actionButton) {
    NSDictionary *event = @{
      @"index": @(photoIndex)
    };
    [_bridge.eventDispatcher sendDeviceEventWithName:@"NYTPhotoViewer:ActionButtonPress" body:event];
    return YES;
  }
  return NO;
}

- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController {
  NSDictionary *event = @{};
  [_bridge.eventDispatcher sendDeviceEventWithName:@"NYTPhotoViewer:Dismissed" body:event];
}

@end
