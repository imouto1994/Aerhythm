#import <UIKit/UIKit.h>

@interface SelectLevelController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>
// OVERVIEW: This is the controller for the select level screen

// Outlet button to choose the level
@property (strong, nonatomic) IBOutlet UIButton *chooseLevelButton;
// Outlet button to scroll down the list of levels
@property (strong, nonatomic) IBOutlet UIButton *downButton;
// Outlet button to scroll up the list of levels
@property (strong, nonatomic) IBOutlet UIButton *upButton;
// Outlet button to navigate back to the previous screen
@property (strong, nonatomic) IBOutlet UIButton *backButton;
// Outlet button to navigate back to the menu screen
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
// Outlet for the "Reject" button used to remove a level in the list of custom levels
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *customListButton;

- (IBAction)customListButtonPressed:(id)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to switch between choosing pre-defined or custom levels

- (IBAction)upButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when the up button is pressed. It will scroll up by 1 in the list of levels

- (IBAction)downButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when the down button is pressed. It will scroll down by 1 in the list of levels

- (IBAction)rejectButtonPressed:(id)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to remove a selected level in the list of custom levels

-(IBAction)unwindToSelectLevelScreen:(UIStoryboardSegue *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method to enable other view controllers to unwind back to this view controller

@end
