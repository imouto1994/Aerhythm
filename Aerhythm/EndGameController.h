#import <UIKit/UIKit.h>
#import "GameStatistics.h"
#import "GameAchievement.h"

@interface EndGameController : UIViewController <UITableViewDataSource,
                                                 UITableViewDelegate,
                                                 UIAlertViewDelegate>

// OVERVIEW: This is the controller for the end game screen which will give a summary of player's score, showing current online top scores and choices for player to choose such as retry the level, etc.

// Label displaying final score
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
// Button for replaying the previous level
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
// Button to return to main menu
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
// Button to return to select song
@property (strong, nonatomic) IBOutlet UIButton *songButton;
// Button to return to select level
@property (strong, nonatomic) IBOutlet UIButton *levelButton;
// Button to return to select model
@property (strong, nonatomic) IBOutlet UIButton *modelButton;
// Button to share on Facebook
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
// Button to share on Twitter
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
// Table for displaying highscores
@property (strong, nonatomic) IBOutlet UITableView *highscoreTable;
// Button to switch to global highscore table
@property (strong, nonatomic) IBOutlet UIButton *globalButton;
// Button to switch to friend highscore table
@property (strong, nonatomic) IBOutlet UIButton *friendButton;
// Label displaying number of enemies killed
@property (strong, nonatomic) IBOutlet UILabel *enemyLabel;
// Label displaying remaining health
@property (strong, nonatomic) IBOutlet UILabel *healthLabel;
// Label displaying played time
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
// Label displaying whether the player kill boss or not
@property (strong, nonatomic) IBOutlet UILabel *killBossLabel;
// Label displaying whether the player use revival or not
@property (strong, nonatomic) IBOutlet UILabel *noRevivalLabel;

// A property that contains statistics of the game the user has played
@property (strong, nonatomic) GameStatistics *gameStatistics;

// A property that contains achievements of the game the user has played
@property (strong, nonatomic) GameAchievement *gameAchievements;

// A property that contains data for highscore table
@property (strong, nonatomic) NSArray * highscorePlayerList;
// List of world players
@property (strong, nonatomic) NSArray * worldHighscorePlayerList;
// List of friend players
@property (strong, nonatomic) NSArray * friendHighscorePlayerList;

- (IBAction)postScoreToFB:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the Facebook button is tapped

- (IBAction)postScoreToTwitter:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the Twitter button is tapped

- (IBAction)retryButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the Retry button is tapped

- (IBAction)friendButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the friend button is tapped

- (IBAction)globalButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Handler method when the global button is tapped

@end
