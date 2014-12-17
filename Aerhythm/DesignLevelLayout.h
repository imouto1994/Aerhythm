#import <UIKit/UIKit.h>

@interface DesignLevelLayout : UICollectionViewLayout

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingX;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numColumns;

@end
