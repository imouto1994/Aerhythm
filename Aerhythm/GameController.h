#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GameStatistics.h"

@interface GameController : UIViewController
// OVERVIEW: This is the view controller for in-game screen

// The selected path for media file in the previous song selection screen
@property (strong, nonatomic) NSString *selectedFilePath;
// The selected song name
@property (strong, nonatomic) NSString *selectedSongName;
// The selected artist name
@property (strong, nonatomic) NSString *selectedArtistName;
// Indicator whether use personal song or not
@property (nonatomic) BOOL usingPersonalSong;

// The loading view before entering game
@property (strong, nonatomic) IBOutlet UIView *loadingView;
// The pause view during playing game
@property (strong, nonatomic) IBOutlet UIView *pauseView;
// The pause button to triggering the pause view
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
// The blur background for pause view
@property (strong, nonatomic) IBOutlet UIImageView *pauseBackground;
// The resume button in pause view
@property (strong, nonatomic) IBOutlet UIButton *resumeButton;
// The retry button in pause view
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
// The song button in pause view
@property (strong, nonatomic) IBOutlet UIButton *songButton;
// The menu button in pause view
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
// Button to trigger player's special move
@property (strong, nonatomic) IBOutlet UIButton *specialButton;

@property (strong, nonatomic) GameStatistics* gameStatistics;

- (IBAction)pauseButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when pause button is tapped

- (IBAction)resumeButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when resume button is tapped

- (IBAction)retryButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when retry button is tapped

- (IBAction)specialButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handler method when special button is tapped

- (void) setupPauseView;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Setup the pause view to be about to be displayed

@end
