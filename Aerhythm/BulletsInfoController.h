#import <UIKit/UIKit.h>

@interface BulletsInfoController : UIViewController<UITableViewDataSource, UITableViewDelegate>
// OVERVIEW: This is the controller for the info screen about bullets

// The info table
@property (strong, nonatomic) IBOutlet UITableView *infoTable;
// Outlet button to scroll up the list of bullets
@property (strong, nonatomic) IBOutlet UIButton *upButton;
// Outlet button to scroll down the list of bullets
@property (strong, nonatomic) IBOutlet UIButton *downButton;
// Oulet button to navigate back to the info screen
@property (strong, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)upButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the up button is pressed. It will scroll up the list of bullets by 1

- (IBAction)downButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the down button is pressed. It will scroll down the list of bullets by 1


@end
