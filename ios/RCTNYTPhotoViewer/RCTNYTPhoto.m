#import "RCTNYTPhoto.h"

@implementation RCTNYTPhoto

-(id) init
{
  self = [super init];
  if (self) {
    self.loadFailed = NO;
  }
  return self;
}

- (id)initWithSource:(NSString *)source
{
  self = [self init];
  if (self) {
    self.source = source;
  }
  return self;
}


@end
