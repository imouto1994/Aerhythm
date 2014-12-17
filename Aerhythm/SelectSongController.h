#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SelectSongController : UIViewController <MPMediaPickerControllerDelegate>
// OVERVIEW: This view controller controls the view where the player gets to choose a song from his music library. Then, this controller will process the data of the song and pass the processed data to the main game controller

// "Start Game" Button
@property (strong, nonatomic) IBOutlet UIButton *startButton;
// "Select New Song" Button
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
// "Back" button to navigate back to the select level screen
@property (strong, nonatomic) IBOutlet UIButton *backButton;
// Outlet for home button to navigate back to the menu screen
@property (strong, nonatomic) IBOutlet UIButton *homeButton;
// Outlet for list button to switch between choosing personal songs or shared songs
@property (strong, nonatomic) IBOutlet UIButton *listButton;
// Outlet for the "Up" button used in list of shared songs
@property (strong, nonatomic) IBOutlet UIButton *upButton;
// Outlet for the "Down" button used in list of shared songs
@property (strong, nonatomic) IBOutlet UIButton *downButton;
// Outlet for the "Reject" button used to remove a song in the list of shared songs
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;

- (IBAction)selectButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Method handler when the "Select New Song" button is tapped

-(IBAction)unwindToSelectSongScreen:(UIStoryboardSegue *)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to enable other view controllers to unwind back to this view controller

- (IBAction)personalListButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to switch between choosing personal or shared songs

- (IBAction)upButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to scroll up in the list of shared songs

- (IBAction)downButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to scroll down in the list of shared songs

- (IBAction)rejectButtonTapped:(UIButton *)sender;
// REQUIRES: self != nil
// EFFECTS: Method handler to remove a selected song in the list of shared songs

@end
