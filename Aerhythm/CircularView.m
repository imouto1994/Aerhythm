#import "CircularView.h"
#import <QuartzCore/QuartzCore.h>

#define HALF_TRANSPARENT_WHITE_COLOR [UIColor colorWithRed:(150/ 255.0) green:(150/ 255.0) blue:(150/ 255.0) alpha:0.8]

@implementation CircularView

- (id)initWithFrame:(CGRect)frame{
    // MODIFIES: self
    // EFFECTS: Override this method from super class, setup the border for the view
    
    self = [super initWithFrame:frame];
    if(self){
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.bounds.size.width / 2.0;
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    // MODIFIES: self
    // EFFECTS: Modify the way the view is drawn
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [HALF_TRANSPARENT_WHITE_COLOR CGColor]);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextFillPath(ctx);
}


@end