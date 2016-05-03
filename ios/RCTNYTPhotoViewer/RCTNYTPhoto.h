#import <Foundation/Foundation.h>
#import <NYTPhotoViewer/NYTPhoto.h>

@interface RCTNYTPhoto : NSObject <NYTPhoto>

@property (nonatomic) NSString *source;
@property (nonatomic, assign, getter=isLoadFailed) BOOL loadFailed;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

- (id)initWithSource:(NSString *)source;

@end
