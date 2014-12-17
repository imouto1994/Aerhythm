#import "GameController.h"
#import "PlayScene.h"
#import "FadeUnwindSegue.h"
#import "OnsetDetector.h"
#import "PlayerJet.h"
#import "Powerup.h"
#import "GameUpgrade.h"
#import "EndGameController.h"
#import "EndGameController+BackendData.h"
#import "MDRadialProgressView.h"
#import "Utilities.h"
#import "FacebookHelper+Aerhythm.h"

static NSString * const kEndGameSegueId = @"gameover";
static NSString * const kSelectedFilePathKey = @"selectedFilePath";
static NSString * const kSelectedSongNameKey = @"selectedSongName";
static NSString * const kSelectedArtistNameKey = @"selectedArtistName";
static NSString * const kIsUsingPersonalSong = @"isUsingPersonalSong";
static NSString * const kGameLevelIdKey = @"gameLevelId";
static NSString * const kPlayerJetModelKey = @"playerJetModel";

@interface GameController()<PlaySceneDelegate, OnsetDetectorDelegate>

@end

@implementation GameController{
    // The onset dectector
    OnsetDetector *onsetDetector;
    // Counter to check for the current loading progress
    NSInteger currentLoadingProgress;
    // The progress view representing the current amount of mana
    MDRadialProgressView *manaRadialView;
}

- (void)viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Override this method from superclass, setup the scene
    
    [super viewWillAppear:animated];
    [self setupForAppearing];
}

-(void) setupForAppearing{
    SKView *skView = (SKView *)self.view;
    [skView presentScene:[[SKScene alloc] init]]; // present an empty scene
    // Setup pause view
    [self.pauseView setHidden:YES];
    // Setup buttons
    UIImage *pauseImage = [Utilities loadImageWithName:@"pauseButton"];
    [self.pauseButton setImage:pauseImage forState:UIControlStateNormal];
    
    UIImage *specialImage = [Utilities loadImageWithName:@"specialButton"];
    [self.specialButton setImage:specialImage forState:UIControlStateNormal];
    [self.specialButton setUserInteractionEnabled:NO];
    
    // Setup mana bar
    manaRadialView = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(5, 930, 90, 90)];
	manaRadialView.progressTotal = 10;
    manaRadialView.progressCounter = 10;
    manaRadialView.backgroundColor = [UIColor clearColor];
    manaRadialView.theme.thickness = 90.0;
	manaRadialView.theme.incompletedColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.8];
    manaRadialView.theme.completedColor = [UIColor clearColor];
	manaRadialView.theme.centerColor = [UIColor clearColor];
    manaRadialView.theme.sliceDividerThickness = 1.0;
    manaRadialView.theme.sliceDividerColor = [UIColor clearColor];
	manaRadialView.theme.sliceDividerHidden = NO;
    [self.view addSubview:manaRadialView];
    [self.view sendSubviewToBack:manaRadialView];
    [self.view sendSubviewToBack:self.specialButton];
    [self.view setUserInteractionEnabled:YES];
    if(onsetDetector == nil){ // new song audio chosen by the player
        [self.loadingView setHidden:NO];
        [self setupLoadingView];
        // Start loading process
        currentLoadingProgress = 0;
        onsetDetector = [[OnsetDetector alloc] init];
        onsetDetector.delegate = self;
        if(self.usingPersonalSong){
            [onsetDetector importSongFromURL:[NSURL URLWithString:_selectedFilePath] andTitle:@"MusicLibrary"];
        } else{
            [onsetDetector getOnsetDataFromSongURL:_selectedFilePath];
        }
    } else { // no need for processing song
        [self finishProcessing];
    }
}

-(void) setSelectedFilePath:(NSString *)selectedFilePath{
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Reimplemented the SETTER method for property |selectedMediaItem|
    
    _selectedFilePath = selectedFilePath;
    onsetDetector = nil;
}

-(void) setupLoadingView{
    // REQUIRES: self != nil
    // MODIFIES: self.loadingView
    // EFFECTS: Setup the loading view every time the in-game screen appears
    
    UIImage *defaultImage = [Utilities loadImageWithName:@"note-loading"];
    for(int i = 0; i < 7; i++){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:defaultImage];
        [imageView setFrame:CGRectMake(10 + i * 100, 449, 128, 128)];
        [self.loadingView addSubview:imageView];
    }
}

-(void) viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Dealloc things when view disappears
    [super viewDidDisappear:animated];
    [self setupForDisappearing];
}

-(void) setupForDisappearing{
    for(UIGestureRecognizer *gesture in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:gesture];
    }
    self.view.userInteractionEnabled = NO;
    
    // Release image for buttons
    [self.pauseButton setImage:nil forState:UIControlStateNormal];
    [self.specialButton setImage:nil forState:UIControlStateNormal];
    
    [manaRadialView removeFromSuperview];
    manaRadialView = nil;
    
    // Release view game scene
    SKView *skView = (SKView *)self.view;
    skView.scene.paused = YES;
    [skView.scene removeAllActions];
    [skView.scene removeAllChildren];
    [skView.scene removeFromParent];
    [skView presentScene:nil];
}

-(void) displayCurrentProgressAt:(NSInteger)progress{
    // EFFECTS: Update the loading screen according to the notification of loading process from scene or onset detector
    
    NSString *fileName = [NSString stringWithFormat:@"note1-%ld", (long) progress + 1];
    UIImage *image = [Utilities loadImageWithName:fileName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(10 + 100 * progress, 449, 128, 128)];
    [self.loadingView addSubview:imageView];
}

#pragma mark - Onset Detector Delegate
-(void) showCurrentSongProcess:(NSInteger)musicProgress{
    // EFFECTS: Show the current song processing progres
    
    if(currentLoadingProgress == musicProgress){
        [self displayCurrentProgressAt:musicProgress];
        currentLoadingProgress++;
    }
}

-(void) finishProcessing{
    // EFFECTS: Handler method when the music processing has ended
    // Start loading game assets. After complete, the game scene will be presented.
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    // Initialize Scene
    PlayScene *scene = [PlayScene sceneWithSize:skView.bounds.size];
    scene.delegate = self;
    [scene loadSceneAssetsWithCompletionHandler:^{
        // Configure the scene.
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.musicPlayer = [[GameMusicPlayer alloc] initWithMusicData:[onsetDetector getOnsetData] andFilePath:[onsetDetector filePath]];
        // Build Game World
        [scene buildGameWorld];
        // Run animation for presenting scene
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.loadingView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             for(__strong UIView *subView in [self.loadingView subviews]){
                                 [subView removeFromSuperview];
                                 subView = nil;
                             }
                             [self.loadingView setHidden:YES];
                             [self.loadingView setAlpha:1.0];
                             // Present the scene with fade in transition
                             SKTransition *fadeIn = [SKTransition crossFadeWithDuration:1.0];
                             fadeIn.pausesIncomingScene = NO;
                             [skView presentScene:scene transition:fadeIn];
                             [scene.musicPlayer play];
                         }];
    }];
}

#pragma mark - Play Scene Delegate
-(void) showCurrentLoadingAssetProgressAt:(NSInteger)progress{
    // EFFECTS: Show the current loading asset progress
    
    [self displayCurrentProgressAt:progress];
}

-(void) gameDidEnd{
    // EFFECTS: Handler method when game did end
    
    SKView * skView = (SKView *)self.view;
    skView.paused = NO;
    PlayScene *currentScene = (PlayScene *)skView.scene;
  
    /* Update game statistics */
    if (self.gameStatistics == nil) {
        // Initialize game statistics
        self.gameStatistics = [[GameStatistics alloc] initWithLevelId:[PlayScene sLevelId]];
    }
    self.gameStatistics.songName = self.selectedSongName;
    self.gameStatistics.songArtist = self.selectedArtistName;
    self.gameStatistics.usedModelType = [PlayerJet modelType];
    self.gameStatistics.score = currentScene.gameScore;
    self.gameStatistics.isWon = currentScene.gameAchievement.didKillBoss;
    
    [GameStatistics updateOfflineStatisticsWithNewData:self.gameStatistics];
    
    /* Update game upgrade */
    GameUpgrade *newUpgrade = [GameUpgrade loadUpgradeData];
    newUpgrade.reviveStock = [Powerup reviveStock];
    [GameUpgrade updateUpgradeData:newUpgrade];
    
    [self performSegueWithIdentifier:kEndGameSegueId sender:self];
}

-(void) updateManaView:(NSInteger)counter{
    manaRadialView.progressCounter = counter;
    if(counter == 10.0){
        manaRadialView.hidden = YES;
        [self.specialButton setUserInteractionEnabled:YES];
    } else {
        manaRadialView.hidden = NO;
        [self.specialButton setUserInteractionEnabled:NO];
    }
}

- (IBAction)pauseButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the pause button is clicked
    
    SKView *skView = (SKView *)self.view;
    if(![skView.scene isKindOfClass:[PlayScene class]]){
        return;
    }
    PlayScene *currentScene = (PlayScene *)skView.scene;
    if(skView.isPaused){
        [self.pauseView setHidden:YES];
        [currentScene resumeGame];
        [self.pauseButton setUserInteractionEnabled:YES];
        [self releasePauseView];
    } else{
        [currentScene pauseGame];
        [self.pauseButton setUserInteractionEnabled:NO];
        [self setupPauseView];
        [self.pauseView setHidden:NO];
    }
}

- (IBAction)specialButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the user want to make a special move
    
    SKView *spriteView = (SKView *)self.view;
    PlayScene *currentScene = (PlayScene *)spriteView.scene;
    [currentScene performSpecialMove];
}

-(void) setupPauseView {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Setup the pause view to be about to be displayed
    
    // Setup background image
    UIImage *backgroundImage = [Utilities loadImageWithName:@"pauseBackground"];
    [self.pauseBackground setImage:backgroundImage];
    
    // Setup resume button
    UIImage *resumeButtonImage = [Utilities loadImageWithName:@"resumeButton"];
    [self.resumeButton setImage:resumeButtonImage forState:UIControlStateNormal];
    
    // Setup retry button
    UIImage *retryButtonImage = [Utilities loadImageWithName:@"retryButton"];
    [self.retryButton setImage:retryButtonImage forState:UIControlStateNormal];
    
    // Setup song button
    UIImage *songButtonImage = [Utilities loadImageWithName:@"songButton"];
    [self.songButton setImage:songButtonImage forState:UIControlStateNormal];
    
    // Setup menu button
    UIImage *menuButtonImage = [Utilities loadImageWithName:@"menuButton"];
    [self.menuButton setImage:menuButtonImage forState:UIControlStateNormal];
}

-(void) releasePauseView {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Release the pause view data
    
    // Release images
    [self.pauseBackground setImage:nil];
    [self.resumeButton setImage:nil forState:UIControlStateNormal];
    [self.retryButton setImage:nil forState:UIControlStateNormal];
    [self.songButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setImage:nil forState:UIControlStateNormal];
}

- (IBAction)resumeButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the resume button is tapped
    
    SKView *skView = (SKView *)self.view;
    PlayScene *currentScene = (PlayScene *)skView.scene;
    [self.pauseView setHidden:YES];
    [currentScene resumeGame];
    [self releasePauseView];
    [self.pauseButton setUserInteractionEnabled:YES];
}

- (IBAction)retryButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handler method when the retry button is tapped
    
    SKView * skView = (SKView *)self.view;
    skView.paused = NO;
    [self setupForDisappearing];
    [self setupForAppearing];
    [self.pauseButton setUserInteractionEnabled:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // EFFECTS: Handler method for corresponding segues to setup for the next view controllers
    
    if([segue.identifier isEqual:kEndGameSegueId]) {
        // Pass game statistics
        EndGameController * destController = (EndGameController *)[segue destinationViewController];
        destController.gameStatistics = self.gameStatistics;
        // Pass game achievements
        SKView *currentView = (SKView *)self.view;
        PlayScene *currentScene = (PlayScene *)currentView.scene;
        destController.gameAchievements = currentScene.gameAchievement;
        
        // Post activity to Facebook
        if (destController.gameAchievements.didKillBoss) {
            [FacebookHelper shareStoryCompletingLevel:self.gameStatistics.levelId
                                            withScore:self.gameStatistics.score
                                              andSong:self.gameStatistics.songName
                                             andModel:[Constant getNameOfPlayerJetWithType:self.gameStatistics.usedModelType]
                                 andCompletionHandler:^(FBRequestConnection * connection,
                                                        id result, NSError * error) {
                                     
                                 }];
        }
        
        // Update total score for game upgrade
        GameUpgrade *currentGameUpgrade = [GameUpgrade loadUpgradeData];
        currentGameUpgrade.score += self.gameStatistics.score;
        [GameUpgrade updateUpgradeData:currentGameUpgrade];
    }
}

#pragma mark - State Preservation and Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    // Encode the state of this controller
    [coder encodeObject:self.selectedFilePath forKey:kSelectedFilePathKey];
    [coder encodeObject:self.selectedSongName forKey:kSelectedSongNameKey];
    [coder encodeObject:self.selectedArtistName forKey:kSelectedArtistNameKey];
    [coder encodeBool:self.usingPersonalSong forKey:kIsUsingPersonalSong];
    [coder encodeInt:(int)[PlayerJet modelType] forKey:kPlayerJetModelKey];
    [coder encodeInt:(int)[PlayScene sLevelId] forKey:kGameLevelIdKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes retorable state information of this view controller
    
    self.selectedFilePath = [coder decodeObjectForKey:kSelectedFilePathKey];
    self.selectedSongName = [coder decodeObjectForKey:kSelectedSongNameKey];
    self.selectedArtistName = [coder decodeObjectForKey:kSelectedArtistNameKey];
    self.usingPersonalSong = [coder decodeBoolForKey:kIsUsingPersonalSong];
    [PlayerJet setModelType:(PlayerJetType)[coder decodeIntForKey:kPlayerJetModelKey]];
    [PlayScene setLevelId:(NSUInteger)[coder decodeIntForKey:kGameLevelIdKey]];
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
