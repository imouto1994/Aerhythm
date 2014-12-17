#import <UIKit/UIKit.h>
#import "DesignLevelLayout.h"
#import "DesignLevelCell.h"

@interface DesignLevelController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, DesignLevelCellDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *cellsCollectionView;
@property (strong, nonatomic) IBOutlet DesignLevelLayout *cellsLayout;
@property (strong, nonatomic) IBOutlet UIView *controllerPanel;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIView *selectPanel;
@property (strong, nonatomic) NSMutableArray *map;

@end
