#import "DesignLevelCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DesignLevelCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
        [self addSubview:self.imageView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)tapHandler:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(setEnemyTypeAtRow:AndColumn:)]) {
        [self.delegate performSelector:@selector(setEnemyTypeAtRow:AndColumn:) withObject:[NSNumber numberWithInteger:self.row] withObject:[NSNumber numberWithInteger:self.column]];
    }
}

@end
