#import "SelectSongController.h"
#import "OnsetDetector.h"
#import "CircularView.h"
#import "Onset.h"
#import "GameController.h"
#import "FadeUnwindSegue.h"
#import "Utilities.h"
#import "LocalGiftSongs.h"
#import <QuartzCore/QuartzCore.h>

@interface SelectSongController ()<UIPickerViewDataSource, UIPickerViewDelegate>

// The selected media item
@property (strong, nonatomic) MPMediaItem *selectedMediaItem;
// The list of shared songs
@property (strong, nonatomic) NSMutableArray *sharedSongs;

@end

@implementation SelectSongController{
    // The view for the background image
    UIImageView *backgroundImageView;
    // The view for the artwork board
    UIImageView *artworkBoardView;
    // The view for tech pattern
    UIImageView *techPatternView;
    // Current level choice
    NSInteger selectedIndex;
    // Picker view
    UIPickerView *songPicker;
    // Artwork borderview
    CircularView *artworkBorderView;
    // Artwork view
    UIImageView *artworkView;
    // Indicator whether the player is choosing personal song or not
    BOOL choosingPersonalSong;
}

-(void) viewDidLoad{
    // MODIFIES: self
    // EFFECTS: Setup the select song screen when it is loaded for the first time
    
    [super viewDidLoad];
    
    // Set initial selected media item
    self.selectedMediaItem = nil;
    self.startButton.hidden= YES;
    selectedIndex = 0;
    choosingPersonalSong = YES;
    
    // Set artwork circular view
    artworkBorderView = [[CircularView alloc] initWithFrame:CGRectMake(0, 340, 275, 275)];
    [self.view addSubview:artworkBorderView];
    
    // Setup navigate buttons in list of shared songs
    self.upButton.transform = CGAffineTransformMakeRotation(M_PI/ 2.0);
    self.downButton.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
    self.upButton.hidden = YES;
    self.downButton.hidden = YES;
    self.rejectButton.hidden = YES;
    
    // Setup notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) applicationWillEnterForeground:(NSNotification *)notification{
    if(!techPatternView.isAnimating){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
        });
    }
}

-(void) viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Setup the select song screen for every time it appears
    
    [super viewWillAppear:animated];
    
    // Setup buttons
    UIImage *navigateButtonImage = [Utilities loadImageWithName:@"navigateButton"];
    UIImage *browseButtonImage = [Utilities loadImageWithName:@"browseButton"];
    UIImage *startButtonImage = [Utilities loadImageWithName:@"playButton"];
    UIImage *homeButtonImage = [Utilities loadImageWithName:@"homeButton"];
    UIImage *listButtonImage;
    if(choosingPersonalSong){
        listButtonImage   = [Utilities loadImageWithName:@"personalButton"];
    } else {
        listButtonImage = [Utilities loadImageWithName:@"sharedButton"];
    }
    UIImage *rejectButtonImage = [Utilities loadImageWithName:@"rejectIcon"];
    
    [self.selectButton setImage:browseButtonImage forState:UIControlStateNormal];
    [self.startButton setImage:startButtonImage forState:UIControlStateNormal];
    [self.backButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.upButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.downButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    [self.listButton setImage:listButtonImage forState:UIControlStateNormal];
    [self.rejectButton setImage:rejectButtonImage forState:UIControlStateNormal];
    
    // Setup artwork board view
    UIImage *artworkBoard = [Utilities loadImageWithName:@"artworkBoard"];
    artworkBoardView = [[UIImageView alloc] initWithImage:artworkBoard];
    
    [artworkBoardView setFrame:CGRectMake(0, 355, 768, 243)];
    [self.view addSubview:artworkBoardView];
    [self.view sendSubviewToBack:artworkBoardView];
    
    // Setup tech pattern view
    UIImage *techPattern = [Utilities loadImageWithName:@"songTechPattern"];
    techPatternView = [[UIImageView alloc] initWithImage:techPattern];
    [techPatternView setFrame:CGRectMake(-140, 165, 592, 622)];
    [self.view addSubview:techPatternView];
    [self.view sendSubviewToBack:techPatternView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
    });
    // Setup background image view
    UIImage *backgroundImage = [Utilities loadImageWithName:@"selectMusicLevel"];
    backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup model picker
    songPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 365, 700, 216)];
    songPicker.dataSource = self;
    songPicker.delegate = self;
    songPicker.userInteractionEnabled = NO;
    [songPicker selectRow:selectedIndex inComponent:0 animated:NO];
    [self.view addSubview:songPicker];
    
    // Setup artwork view
    if(artworkView == nil){
        artworkView = [[UIImageView alloc] init];
        [artworkBorderView addSubview:artworkView];
        [artworkView setFrame:CGRectMake(0, 0, 275, 275)];
        if(self.selectedMediaItem != nil){
            [self setArtwork];
        }
    }
    
    self.sharedSongs = [[NSMutableArray alloc] initWithArray:[LocalGiftSongs getLocalGiftSongList]] ;
}

-(void) viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Remove unnecessary things when the select song scren disappears
    
    [super viewDidDisappear:animated];
    // Remove background
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    [artworkBoardView removeFromSuperview];
    artworkBoardView = nil;
    
    [techPatternView.layer removeAllAnimations];
    [techPatternView removeFromSuperview];
    techPatternView = nil;
    
    // Remove images in buttons
    [self.selectButton setImage:nil forState:UIControlStateNormal];
    [self.startButton setImage:nil forState:UIControlStateNormal];
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.homeButton setImage:nil forState:UIControlStateNormal];
    [self.listButton setImage:nil forState:UIControlStateNormal];
    [self.upButton setImage:nil forState:UIControlStateNormal];
    [self.downButton setImage:nil forState:UIControlStateNormal];
    [self.rejectButton setImage:nil forState:UIControlStateNormal];
    
    self.sharedSongs = nil;
    
    [songPicker removeFromSuperview];
    songPicker = nil;
}


-(IBAction) selectButtonTapped:(UIButton *)sender {
    // MODIFIES: self
    // EFFECTS: Method handler when the "Select New Song" button is tapped. It will create a new view controller for the user to choose song
    
    MPMediaPickerController *mediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPickerController.delegate = self;
    mediaPickerController.allowsPickingMultipleItems = NO;
    mediaPickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:mediaPickerController animated:YES completion:nil];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // EFFECTS: Setup the game controller and releasing assets before navigating to it
    
    if([segue.identifier isEqual:@"playGame"]){
        GameController *gameController = (GameController *)segue.destinationViewController;
        if(choosingPersonalSong){
            NSURL *assetURL = [self.selectedMediaItem valueForProperty:MPMediaItemPropertyAssetURL];
            [gameController setSelectedFilePath:[assetURL absoluteString]];
            [gameController setSelectedSongName:[self.selectedMediaItem valueForProperty:MPMediaItemPropertyTitle]];
            [gameController setSelectedArtistName:[self.selectedMediaItem valueForProperty:MPMediaItemPropertyArtist]];
        } else {
            NSDictionary *chosenSong = [self.sharedSongs objectAtIndex:selectedIndex];
            NSLog(@"%@", [chosenSong objectForKey:@"dataPath"]);
            [gameController setSelectedFilePath:[chosenSong objectForKey:@"dataPath"]];
            [gameController setSelectedSongName:[chosenSong objectForKey:@"songName"]];
            [gameController setSelectedArtistName:[chosenSong objectForKey:@"songArtist"]];
        }
        [artworkView removeFromSuperview];
        artworkView = nil;
        [gameController setUsingPersonalSong:choosingPersonalSong];
        [self.startButton setHidden:YES];
    }
}

#pragma mark - MP Media Picker Controller Delegate
-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    // EFFECTS: Action when an item in the media table is picked. This is a required method from the delegate protocol
    
    self.selectedMediaItem =  [[mediaItemCollection items] objectAtIndex:0];
    [self.startButton setHidden:NO];
    [self setArtwork];
    // Dismiss the select media view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setArtwork{
    // REQUIRES: self != nil
    // MODIFIES: self.artworkView
    // EFFECTS: Set the artwork for chosen music song
    
    MPMediaItemArtwork *artwork = [self.selectedMediaItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(302, 302)];
    if(artworkImage != nil){
        [artworkView setImage:artworkImage];
    } else { // no artwork image from the current media item
        UIImage *defaultImage = [Utilities loadImageWithName:@"defaultArtwork"];
        [artworkView setImage:defaultImage];
    }
}


-(void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    // EFFECTS: Dismiss the media picker view controller. This is a required method from the delegate protocol
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)unwindToSelectSongScreen:(UIStoryboardSegue *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Method handler to enable other view controllers to unwind back to this view controller
    
}

#pragma mark - Picker View Data Source Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    // EFFECTS: Return the number of components in the picker view
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    // EFFECTS: Return the number of rows in each specific componenet
    // In this case, it will return the total number of rows since there is only 1 component
    
    if(choosingPersonalSong){
        return 1;
    } else {
        return [self.sharedSongs count];
    }
}

#pragma mark - Picker View Delegate Protocol
-(CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    // EFFECTS: Return the height of each row
    
    return 300;
}

-(CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    // EFFECTS: Return the width of each row
    
    return 700;
}

-(UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    // EFFECTS: Setup the view for each row in thwe picker view
    
    if(view == nil){
        /* Setup the view */
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 725, 256)];
        // Setup the label for info about the level
        UILabel *songNameLabel = [[UILabel alloc] init];
        [songNameLabel setTextAlignment:NSTextAlignmentCenter];
        songNameLabel.font = [UIFont fontWithName:@"Futura (Light)" size:32];
        [songNameLabel setFrame:CGRectMake(275, 60, 475, 50)];
        [songNameLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:songNameLabel];
        
        // Setup the label for difficulty about the level
        UILabel *artistNameLabel = [[UILabel alloc] init];
        [artistNameLabel setTextAlignment:NSTextAlignmentCenter];
        artistNameLabel.font = [UIFont fontWithName:@"Futura (Light)" size:32];
        [artistNameLabel setFrame:CGRectMake(275, 140, 475, 50)];
        [artistNameLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:artistNameLabel];
        
        if(choosingPersonalSong){
            if(self.selectedMediaItem != nil){
                songNameLabel.text = [self.selectedMediaItem valueForProperty:MPMediaItemPropertyTitle];
                artistNameLabel.text = [self.selectedMediaItem valueForProperty:MPMediaItemPropertyArtist];
            } else {
                songNameLabel.text = @"Song Name";
                artistNameLabel.text = @"Artist Name";
                
            }
        } else {
            NSDictionary *song = [self.sharedSongs objectAtIndex:row];
            songNameLabel.text = [song objectForKey:@"songName"];
            artistNameLabel.text = [song objectForKey:@"songArtist"];
        }
    }
    
    return view;
}


#pragma mark - State Preservation and Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes retorable state information of this view controller
    
    [super decodeRestorableStateWithCoder:coder];
}

- (IBAction)personalListButtonTapped:(UIButton *)sender {
    // MODIFIES: self
    // EFFECTS: Handler method when the list button is tapped
    //          Resetup the list everytime the button is tapped
    
    if(!choosingPersonalSong){
        [self setupForPersonalList];
    } else{
        [self setupForSharedList];
    }
}

-(void) setupForPersonalList{
    // MODIFIES: self
    // EFFECTS: Setup the screen for personal list of songs
    
    choosingPersonalSong = true;
    if(self.selectedMediaItem == nil){
        [self.startButton setHidden:YES];
        [artworkView setImage:nil];
    } else {
        [self setArtwork];
    }
    [songPicker selectRow:0 inComponent:0 animated:NO];
    [songPicker reloadAllComponents];
    selectedIndex = 0;
    [self.selectButton setHidden:NO];
    [self.upButton setHidden:YES];
    [self.downButton setHidden:YES];
    [self.rejectButton setHidden:YES];
    UIImage *personalButtonImage = [Utilities loadImageWithName:@"personalButton"];
    [self.listButton setImage:personalButtonImage forState:UIControlStateNormal];
    [self showListMessage:@"Personal Songs"];
    
}

-(void) setupForSharedList{
    // MODIFIES: self
    // EFFECTS: Setup the screen for shared list of songs
    
    if(self.sharedSongs == nil || (int)[self.sharedSongs count] == 0) {
        CGRect listButtonFrame = self.listButton.frame;
        CGRect originalFrame = CGRectMake(listButtonFrame.origin.x, listButtonFrame.origin.y + 25, 200, 30);
        [Utilities showMessage:@"No shared songs" withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:-180 andOffsetY:0 inView:self.view withDuration:0.75];
        return;
    }
    choosingPersonalSong = false;
    [self.startButton setHidden:NO];
    UIImage *defaultImage = [Utilities loadImageWithName:@"defaultArtwork"];
    [artworkView setImage:defaultImage];
    [songPicker selectRow:0 inComponent:0 animated:NO];
    [songPicker reloadAllComponents];
    selectedIndex = 0;
    [self.selectButton setHidden:YES];
    [self.upButton setHidden:YES];
    self.downButton.hidden = ([self.sharedSongs count] == 1) ? YES : NO;
    [self.rejectButton setHidden:NO];
    UIImage *sharedButtonImage = [Utilities loadImageWithName:@"sharedButton"];
    [self.listButton setImage:sharedButtonImage forState:UIControlStateNormal];
    [self showListMessage:@"Shared Songs"];
    
}

-(void) showListMessage:(NSString *)message{
    // EFFECTS: Show list message when the button is tapped
    
    CGRect listButtonFrame = self.listButton.frame;
    CGRect originalFrame = CGRectMake(listButtonFrame.origin.x - 225, listButtonFrame.origin.y + 110, 250, 40);
    [Utilities showMessage:message withColor:[UIColor whiteColor] andSize:30 fromOriginalFrame:originalFrame withOffsetX:0 andOffsetY:-80.0 inView:self.view withDuration:0.5];
}

- (IBAction)upButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // EFFECTS: Method handler to scroll up in the list of shared songs
    
    self.downButton.hidden = NO;
    NSInteger currentRow = [songPicker selectedRowInComponent:0];
    if(currentRow == 1){
        self.upButton.hidden = YES;
    }
    [songPicker selectRow:currentRow -  1 inComponent:0 animated:YES];
    selectedIndex = currentRow - 1;
}

- (IBAction)downButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // EFFECTS: Method handler to scroll down in the list of shared songs
    
    self.upButton.hidden = NO;
    NSInteger currentRow = [songPicker selectedRowInComponent:0];
    if(currentRow == (int)[self.sharedSongs count] - 2){
        self.downButton.hidden = YES;
    }
    [songPicker selectRow:currentRow + 1 inComponent:0 animated:YES];
    selectedIndex = currentRow + 1;
    
}
- (IBAction)rejectButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // EFFECTS: Method handler to remove a song in the shared list
    
    [LocalGiftSongs deleteGiftSong:[self.sharedSongs objectAtIndex:selectedIndex]];
    [self.sharedSongs removeObjectAtIndex:selectedIndex];
    if((int) [self.sharedSongs count] == 0){
        [self setupForPersonalList];
        return;
    }
    [songPicker reloadAllComponents];
    while(selectedIndex >= (int)[self.sharedSongs count]){
        selectedIndex--;
    }
    if(selectedIndex == 0){
        [self.upButton setHidden:YES];
    }
    if(selectedIndex == (int)[self.sharedSongs count] - 1){
        [self.downButton setHidden:YES];
    }
    [songPicker selectRow:selectedIndex inComponent:0 animated:YES];
}

@end
