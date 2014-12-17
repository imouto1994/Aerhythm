#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SongRequest.h"

@interface MenuController : UIViewController<SongRequestProgressProtocol>
// OVERVIEW: This is the controller for the menu screen in the game

// The IBOutlet for the "Start" button to start the game
@property (strong, nonatomic) IBOutlet UIButton *startButton;
// The IBOutlet for the "Design Level" button to start the game
@property (weak, nonatomic) IBOutlet UIButton * designLevelButton;
// The IBOutlet for the "Upgrade" button to go to upgrade screen
@property (strong, nonatomic) IBOutlet UIButton *upgradeButton;
// The IBOutlet for the "Login" button to login using FB account
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
// The IBOutlet for the "Mail" button to show list of notifications
@property (strong, nonatomic) IBOutlet UIButton *mailButton;
// The IBOutlet for the "Info" button to show info about enemies and bullets in the game
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

-(IBAction)unwindToMenuScreen:(UIStoryboardSegue *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method to enable other view controllers to unwind back to this view controller

- (IBAction)socialButtonTouchHandler:(id)sender;
// REQUIRES: self != nil;
// EFFECTS: Handler method for Facebook Login and Logout

- (IBAction)mailButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method to open the "Notification" modal popup screen

@end
