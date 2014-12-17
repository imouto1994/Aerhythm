#import <UIKit/UIKit.h>

@interface SelectModelController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
// OVERVIEW: This is the controller for the select model screen

// Outlet button to scroll up the list of models
@property (strong, nonatomic) IBOutlet UIButton *upButton;
// Outlet button to scroll down the list of models
@property (strong, nonatomic) IBOutlet UIButton *downButton;
// Outlet button to navigate to the select level screen
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
// Outlet button to navigate back to the main menu
@property (strong, nonatomic) IBOutlet UIButton *backButton;
// Outlet button to navigate back to the menu screen
@property (strong, nonatomic) IBOutlet UIButton *homeButton;

- (IBAction)upButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the up button is pressed. It will scroll up the list of models by 1

- (IBAction)downButtonPressed:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the down button is pressed. It will scroll down the list of models by 1

-(IBAction)unwindToSelectModelScreen:(UIStoryboardSegue *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method to enable other view controllers to unwind back to this view controller

@end
