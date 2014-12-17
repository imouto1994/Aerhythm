#import "SelectLevelController.h"
#import "CircularView.h"
#import "PlayScene.h"
#import "GameStatistics.h"
#import "Utilities.h"
#import "GameStatisticsManager.h"
#import <QuartzCore/QuartzCore.h>

#define LEVEL_1_INDEX 0
#define LEVEL_2_INDEX 1
#define LEVEL_3_INDEX 2
#define LEVEL_4_INDEX 3
#define NUM_PREDEFINED_LEVELS 4

#define  kSelectedLevelIndexKey @"selectedLevelIndKey"
#define kFuturaFontName @"Futura (Light)"
#define kSelectSongSegueIdentifierKey @"selectSong"

@interface SelectLevelController()

// The list of custom levels
@property (nonatomic, strong) NSMutableArray* customLevels;

@end

@implementation SelectLevelController{
    // The view for background image
    UIImageView *backgroundImageView;
    // The view for the artwork board
    UIImageView *artworkBoardView;
    // The view for tech pattern
    UIImageView *techPatternView;
    // Current level choice
    NSInteger selectedIndex;
    // Highscore
    NSMutableArray *highScores;
    // Picker view
    UIPickerView *levelPicker;
    // Indicator whether user is choosing custom level
    BOOL choosingCustomLevel;
    // Level Limit
    NSInteger levelLimit;
}

-(void) viewDidLoad{
    // MODIFIES: selectChoices
    // EFFECTS: Setup the view when it is first loaded
    
    [super viewDidLoad];
    
    // Set initial selected level
    selectedIndex = 0;
    choosingCustomLevel = NO;
    
    // Setup navigate buttons in list of levels
    self.upButton.transform = CGAffineTransformMakeRotation(M_PI/ 2.0);
    self.downButton.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
    self.rejectButton.hidden = YES;
    
    // Setup notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) applicationWillEnterForeground:(NSNotification *)notification{
    if(!techPatternView.isAnimating){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
        });
    }}

-(void) viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Setup the end game screen for every time it appears
    
    [super viewWillAppear:animated];
    
    // Check the current selected index to hide unnecessary buttons
    [self showHideUpDownButton];
    
    // Setup buttons in the screen
    UIImage *navigateButtonImage = [Utilities loadImageWithName:@"navigateButton"];
    UIImage *nextButtonImage = [Utilities loadImageWithName:@"nextButton"];
    UIImage *homeButtonImage = [Utilities loadImageWithName:@"homeButton"];
    UIImage *listButtonImage;
    if(choosingCustomLevel){
        listButtonImage   = [Utilities loadImageWithName:@"personalButton"];
    } else {
        listButtonImage = [Utilities loadImageWithName:@"sharedButton"];
    }
    UIImage *rejectButtonImage = [Utilities loadImageWithName:@"rejectIcon"];

    
    [self.upButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.downButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.backButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.chooseLevelButton setImage:nextButtonImage forState:UIControlStateNormal];
    [self.homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    [self.customListButton setImage:listButtonImage forState:UIControlStateNormal];
    [self.rejectButton setImage:rejectButtonImage forState:UIControlStateNormal];
   
    // Setup artwork board view
    UIImage *artworkBoard = [Utilities loadImageWithName:@"artworkBoard"];
    artworkBoardView = [[UIImageView alloc] initWithImage:artworkBoard];
    
    [artworkBoardView setFrame:CGRectMake(0, 355, 768, 243)];
    [self.view addSubview:artworkBoardView];
    [self.view sendSubviewToBack:artworkBoardView];
    
    // Setup tech pattern view
    UIImage *techPattern = [Utilities loadImageWithName:@"levelTechPattern"];
    techPatternView = [[UIImageView alloc] initWithImage:techPattern];
    [techPatternView setFrame:CGRectMake(-140, 165, 621, 622)];
    [self.view addSubview:techPatternView];
    [self.view sendSubviewToBack:techPatternView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
    });
   
    
    // Setup background
    UIImage *background = [Utilities loadImageWithName:@"selectLevel"];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    highScores = [NSMutableArray array];
    for (int i = 1; i <= 4; i++){
        GameStatistics * offlineStat = [GameStatisticsManager getStatisticsForLevel:i];
        
        if (offlineStat){
            [highScores addObject:[NSNumber numberWithFloat:offlineStat.score]];
        } else {
            [highScores addObject:[NSNumber numberWithFloat:0]];
        }
    }
    
    // Setup level picker
    levelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 365, 700, 216)];
    levelPicker.dataSource = self;
    levelPicker.delegate = self;
    levelPicker.userInteractionEnabled = NO;
    [levelPicker selectRow:selectedIndex inComponent:0 animated:NO];
    [self.view addSubview:levelPicker];
    
    // Get the local custom levels
    // TODO: get custom level array
    self.customLevels = [[NSMutableArray alloc] init];
    
    levelLimit = [GameStatisticsManager getHighestWonLevel];
}

-(void) viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Remove unnecessary things when the end game screen disappears
    
    [super viewDidDisappear:animated];
    
    // Release the background image view
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    [artworkBoardView removeFromSuperview];
    artworkBoardView = nil;
    
    [techPatternView.layer removeAllAnimations];
    [techPatternView removeFromSuperview];
    techPatternView = nil;
    
    
    // Release the image representation for the button
    [self.upButton setImage:nil forState:UIControlStateNormal];
    [self.downButton setImage:nil forState:UIControlStateNormal];
    [self.chooseLevelButton setImage:nil forState:UIControlStateNormal];
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.homeButton setImage:nil forState:UIControlStateNormal];
    [self.customListButton setImage:nil forState:UIControlStateNormal];
    [self.rejectButton setImage:nil forState:UIControlStateNormal];
    
    [levelPicker removeFromSuperview];
    levelPicker = nil;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // EFFECTS: Handler method for corresponding segues to setup for the next view controllers
    
    if([segue.identifier isEqual:kSelectSongSegueIdentifierKey]){
        NSUInteger pastLevelId = [PlayScene sLevelId];
        NSUInteger selectedLevelId = selectedIndex + 1;
        if (pastLevelId != selectedLevelId) { // release old assets if not the same previous level
            [PlayScene releaseLevelSharedAssets];
        }
        // Setup the new level in the in-game play scene
        [PlayScene setLevelId:selectedLevelId];
    }
    
    // TODO: is custom level id == selectedIndex + 1?
}

-(void) showHideUpDownButton{
    // EFFECTS: Show or hide up button and down button according to selected index
    
    if(selectedIndex == 0){
        [self.upButton setHidden:YES];
    }
    if(selectedIndex == [self getNumLevels] - 1){
        [self.downButton setHidden:YES];
    }
}

#pragma mark - Picker View Data Source Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    // EFFECTS: Return the number of components in the picker view
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    // EFFECTS: Return the number of rows in each specific componenet
    // In this case, it will return the total number of rows since there is only 1 component
    
    return [self getNumLevels];
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
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 700, 256)];
        CircularView *borderView = [[CircularView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];

        // Setup the image view for level artwork
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self getLevelArtwork:row]];
        [imageView setFrame:CGRectMake(0, 0, 256, 256)];
        [borderView addSubview:imageView];
        [view addSubview:borderView];
        
        // Setup the label for info about the level
        UILabel *descriptionLabel = [[UILabel alloc] init];
        [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
        descriptionLabel.text = [self getLevelDescription:row];
        descriptionLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [descriptionLabel setFrame:CGRectMake(300, 40, 350, 50)];
        [descriptionLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:descriptionLabel];
        
        // Setup the highscore label for each level
        UILabel *highscoreLabel = [[UILabel alloc] init];
        [highscoreLabel setTextAlignment:NSTextAlignmentLeft];
        if(row < [highScores count]){
            highscoreLabel.text = [NSString stringWithFormat:@"Highscore: %.0f", [highScores[row] doubleValue]];
        }
        highscoreLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [highscoreLabel setFrame:CGRectMake(300, 100, 350, 50)];
        [highscoreLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:highscoreLabel];
        
        // Setup the label for difficulty about the level
        UILabel *difficultyLabel = [[UILabel alloc] init];
        [difficultyLabel setTextAlignment:NSTextAlignmentLeft];
        difficultyLabel.text = [self getLevelDifficulty:row];
        difficultyLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [difficultyLabel setFrame:CGRectMake(300, 160, 350, 50)];
        [difficultyLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:difficultyLabel];
    }
    
    return view;
}

-(int) getNumLevels{
    if (choosingCustomLevel){
        return (self.customLevels == nil ? 0 : (int)[self.customLevels count]);
    }
    else{
        return NUM_PREDEFINED_LEVELS;
    }
}

-(UIImage*) getLevelArtwork:(NSInteger) levelIndex{
    if (choosingCustomLevel){
        // TODO: get custom level artwork
        return [self getPredefinedLevelArtwork:LEVEL_1_INDEX];
    }
    else{
        return [self getPredefinedLevelArtwork:levelIndex];
    }
}

-(NSString *) getLevelDescription:(NSInteger) levelIndex{
    if (choosingCustomLevel){
        // TODO: get custom level decription
        return @"";
    }
    else{
        return [SelectLevelController getPredefinedLevelDescription:levelIndex];
    }
}

-(NSString *) getLevelDifficulty:(NSInteger) levelIndex{
    if (choosingCustomLevel){
        // TODO: get custom level difficulty
        return @"";
    }
    else{
        return [SelectLevelController getPredefinedLevelDifficulty:levelIndex];
    }
}

-(UIImage*) getPredefinedLevelArtwork:(NSInteger) levelIndex{
    // EFFECTS: Get the level artwork according to the given level index
    
    switch (levelIndex) {
        case LEVEL_1_INDEX:
            return [Utilities loadImageWithName:@"level1-artwork"];
            break;
        case LEVEL_2_INDEX:
            if(levelLimit < LEVEL_2_INDEX){
                return [Utilities loadImageWithName:@"level2-lock"];
            }
            return [Utilities loadImageWithName:@"level2-artwork"];
            break;
        case LEVEL_3_INDEX:
            if(levelLimit < LEVEL_3_INDEX){
                return [Utilities loadImageWithName:@"level3-lock"];
            }
            return [Utilities loadImageWithName:@"level3-artwork"];
            break;
        case LEVEL_4_INDEX:
            if(levelLimit < LEVEL_4_INDEX){
                return [Utilities loadImageWithName:@"level4-lock"];
            }
            return [Utilities loadImageWithName:@"level4-artwork"];
            break;
        default:
            return nil;
            break;
    }
}

+(NSString *) getPredefinedLevelDescription:(NSInteger) levelIndex{
    // EFFECTS: Get the level description according to the given level index
    
    switch (levelIndex) {
        case LEVEL_1_INDEX:
            return @"Level 1: Hell Fire";
            break;
        case LEVEL_2_INDEX:
            return @"Level 2: Ice World";
            break;
        case LEVEL_3_INDEX:
            return @"Level 3: Hidden Gem";
            break;
        case LEVEL_4_INDEX:
            return @"Level 4: Lightning Shock";
            break;
        default:
            return nil;
            break;
    }
}

+(NSString *) getPredefinedLevelDifficulty:(NSInteger) levelIndex{
    // EFFECTS: Get the level difficulty accordng to the given level index
    
    switch (levelIndex) {
        case LEVEL_1_INDEX:
            return @"Difficulty: Easy";
            break;
        case LEVEL_2_INDEX:
            return @"Difficulty: Medium";
            break;
        case LEVEL_3_INDEX:
            return @"Difficulty: Hard";
            break;
        case LEVEL_4_INDEX:
            return @"Difficulty: Extreme";
            break;
        default:
            return nil;
            break;
    }
}

- (IBAction)customListButtonPressed:(id)sender {
    // MODIFIES: self
    // EFFECTS: Handler method when the custom list button is tapped
    //          Resetup the list everytime the button is tapped
    
    if (choosingCustomLevel){
        [self setupForPredefinedLevelList];
    }
    else{
        [self setupForCustomLevelList];
    }
}

- (void)setupForPredefinedLevelList{
    // MODIFIES: self
    // EFFECTS: Setup the screen for pre-defined level list
    
    choosingCustomLevel = NO;
    
    [levelPicker selectRow:0 inComponent:0 animated:NO];
    [levelPicker reloadAllComponents];
    selectedIndex = 0;
    [self showHideUpDownButton];
    [self.rejectButton setHidden:YES];
    UIImage *personalButtonImage = [Utilities loadImageWithName:@"personalButton"];
    [self.customListButton setImage:personalButtonImage forState:UIControlStateNormal];
    [self showListMessage:@"Game levels"];
}

- (void)setupForCustomLevelList{
    // MODIFIES: self
    // EFFECTS: Setup the screen for custom level list

    if(self.customLevels == nil || (int)[self.customLevels count] == 0) {
        CGRect listButtonFrame = self.customListButton.frame;
        CGRect originalFrame = CGRectMake(listButtonFrame.origin.x, listButtonFrame.origin.y + 25, 200, 30);
        [Utilities showMessage:@"No custom levels" withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:-180 andOffsetY:0 inView:self.view withDuration:0.75];
        return;
    }
    
    choosingCustomLevel = YES;
    
    [levelPicker selectRow:0 inComponent:0 animated:NO];
    [levelPicker reloadAllComponents];
    selectedIndex = 0;
    [self showHideUpDownButton];
    [self.rejectButton setHidden:NO];
    UIImage *sharedButtonImage = [Utilities loadImageWithName:@"sharedButton"];
    [self.customListButton setImage:sharedButtonImage forState:UIControlStateNormal];
    [self showListMessage:@"Custom levels"];
}

-(void) showListMessage:(NSString *)message{
    // EFFECTS: Show list message when the button is tapped
    
    CGRect listButtonFrame = self.customListButton.frame;
    CGRect originalFrame = CGRectMake(listButtonFrame.origin.x - 225, listButtonFrame.origin.y + 110, 250, 40);
    [Utilities showMessage:message withColor:[UIColor whiteColor] andSize:30 fromOriginalFrame:originalFrame withOffsetX:0 andOffsetY:-80.0 inView:self.view withDuration:0.5];
}

- (IBAction)upButtonPressed:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the up button is pressed. It will scroll up by 1 in the list of levels
    
    self.downButton.hidden = NO;
    NSInteger currentRow = [levelPicker selectedRowInComponent:0];
    if(currentRow == 1){
        self.upButton.hidden = YES;
    }
    [levelPicker selectRow:currentRow -  1 inComponent:0 animated:YES];
    selectedIndex = currentRow - 1;
    if(selectedIndex <= levelLimit){
        [self.chooseLevelButton setHidden:NO];
    } else {
        [self.chooseLevelButton setHidden:YES];
    }
}

- (IBAction)downButtonPressed:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the down button is pressed. It will scroll down by 1 in the list of levels
    
    self.upButton.hidden = NO;
    NSInteger currentRow = [levelPicker selectedRowInComponent:0];
    if(currentRow == [self getNumLevels] - 2){
        self.downButton.hidden = YES;
    }
    [levelPicker selectRow:currentRow + 1 inComponent:0 animated:YES];
    selectedIndex = currentRow + 1;
    if(selectedIndex <= levelLimit){
        [self.chooseLevelButton setHidden:NO];
    } else {
        [self.chooseLevelButton setHidden:YES];
    }

}

- (IBAction)rejectButtonPressed:(id)sender {
    // REQUIRES: self != nil
    // EFFECTS: Method handler to remove a level in the custom level list
    
    // TODO: delete custom level
   
    [self.customLevels removeObjectAtIndex:selectedIndex];
    if((int) [self.customLevels count] == 0){
        [self setupForPredefinedLevelList];
        return;
    }
    [levelPicker reloadAllComponents];
    while(selectedIndex >= (int)[self.customLevels count]){
        selectedIndex--;
    }
    [self showHideUpDownButton];
    [levelPicker selectRow:selectedIndex inComponent:0 animated:YES];
}

-(IBAction)unwindToSelectLevelScreen:(UIStoryboardSegue *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method to enable other view controllers to unwind back to this view controller
    
}

#pragma mark - State Preservation and Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    [coder encodeInt:(int)selectedIndex forKey:kSelectedLevelIndexKey];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes retorable state information of this view controller
    
    selectedIndex = (NSInteger)[coder decodeIntForKey:kSelectedLevelIndexKey];
    [super decodeRestorableStateWithCoder:coder];
}

@end
