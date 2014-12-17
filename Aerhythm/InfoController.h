#import <UIKit/UIKit.h>

@interface InfoController : UIViewController
// OVERVIEW: This is the info controller for the user to choose whether to see info about enemies or bullets

// Enemies Info Button
@property (strong, nonatomic) IBOutlet UIButton *enemiesButton;

// Bullets Info Button
@property (strong, nonatomic) IBOutlet UIButton *bulletsButton;

// Back Button
@property (strong, nonatomic) IBOutlet UIButton *backButton;

-(IBAction)unwindToInfoScreen:(UIStoryboardSegue *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method to enable other view controllers to unwind back to this view controller


@end
