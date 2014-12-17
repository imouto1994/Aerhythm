#import <UIKit/UIKit.h>

@interface UpgradeController : UIViewController<UITableViewDataSource, UITableViewDelegate>
// OVERVIEW: This is the controller for the upgrade screen

// The upgrade table
@property (strong, nonatomic) IBOutlet UITableView *upgradeTable;
// Back button
@property (strong, nonatomic) IBOutlet UIButton *backButton;
// Score label
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@end
