#import "SelectModelController.h"
#import "CircularView.h"
#import "PlayerJet.h"
#import "PlayerBullet.h"
#import "PlayScene.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

#define ORIGINAL_MODEL_INDEX 0
#define HIGH_DAMAGE_INDEX 1
#define HIGH_HEALTH_INDEX 2
#define NUM_MODELS 3

#define kSelectLevelSegueIdentifier @"selectLevel"
#define kFuturaFontName @"Futura (Light)"
#define kModelTypeKey @"modelType"

@implementation SelectModelController{
    // The view for background image
    UIImageView *backgroundImageView;
    // The view for the artwork board
    UIImageView *artworkBoardView;
    // The view for tech pattern
    UIImageView *techPatternView;
    // Current selected model
    NSInteger selectedIndex;
    // Picker view
    UIPickerView *modelPicker;
}

-(void) viewDidLoad{
    // MODIFIES: self
    // EFFECTS: Setup the view when it is first loaded
    
    [super viewDidLoad];
    
    selectedIndex = 0;
    // Setup buttons
    self.upButton.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    self.downButton.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
    
    // Setup notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) applicationWillEnterForeground:(NSNotification *)notfication{
    if(!techPatternView.isAnimating){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
        });
    }
}

-(void) viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Setup the select model screen for every time it appears
    
    [super viewWillAppear:animated];
    
    // Check fo the current selected index to hide unnecessary buttons
    if(selectedIndex == ORIGINAL_MODEL_INDEX){
        [self.upButton setHidden:YES];
    } else if(selectedIndex == NUM_MODELS - 1){
        [self.downButton setHidden:YES];
    }
    
    // Setup buttons in the screen
    UIImage *navigateButtonImage = [Utilities loadImageWithName:@"navigateButton"];
    UIImage *nextButtonImage = [Utilities loadImageWithName:@"nextButton"];
    UIImage *homeButtonImage = [Utilities loadImageWithName:@"homeButton"];
    [self.upButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.downButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.nextButton setImage:nextButtonImage forState:UIControlStateNormal];
    [self.backButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.homeButton setImage:homeButtonImage forState:UIControlStateNormal];
    
    // Setup artwork board view
    UIImage *artworkBoard = [Utilities loadImageWithName:@"artworkBoard"];
    artworkBoardView = [[UIImageView alloc] initWithImage:artworkBoard];
    
    [artworkBoardView setFrame:CGRectMake(0, 355, 768, 243)];
    [self.view addSubview:artworkBoardView];
    [self.view sendSubviewToBack:artworkBoardView];
    
    // Setup tech pattern view
    UIImage *techPattern = [Utilities loadImageWithName:@"modelTechPattern"];
    techPatternView = [[UIImageView alloc] initWithImage:techPattern];
    [techPatternView setFrame:CGRectMake(-115, 180, 531, 622)];
    [self.view addSubview:techPatternView];
    [self.view sendSubviewToBack:techPatternView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [Utilities spinImageView:techPatternView withOptions:UIViewAnimationOptionCurveEaseIn withDelay:0.0];
    });
    
    // Setup background
    UIImage *background = [Utilities loadImageWithName:@"selectModel"];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup level picker
    modelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 365, 700, 216)];
    modelPicker.dataSource = self;
    modelPicker.delegate = self;
    modelPicker.userInteractionEnabled = NO;
    [modelPicker selectRow:selectedIndex inComponent:0 animated:NO];
    [self.view addSubview:modelPicker];
}

-(void) viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Remove unncessary things when the select model screen disappears
    
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
    [self.nextButton setImage:nil forState:UIControlStateNormal];
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.homeButton setImage:nil forState:UIControlStateNormal];
    
    [modelPicker removeFromSuperview];
    modelPicker = nil;
}

#pragma mark - Picker View Data Source Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    // EFFECTS: Return the number of components in the picker view
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    // EFFECTS: Return the number of rows in each specific componenet
    // In this case, it will return the total number of rows since there is only 1 component
    
    return NUM_MODELS;
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
        // Load corresponding artwork image
        UIImage *image;
        switch (row) {
            case ORIGINAL_MODEL_INDEX:
                image = [Utilities loadImageWithName:@"model1-artwork"];
                break;
            case HIGH_DAMAGE_INDEX:
                image = [Utilities loadImageWithName:@"model2-artwork"];
                break;
            case HIGH_HEALTH_INDEX:
                image = [Utilities loadImageWithName:@"model3-artwork"];
                break;
            default:
                break;
        }
        // Setup the image view
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setFrame:CGRectMake(0, 0, 256, 256)];
        [borderView addSubview:imageView];
        [view addSubview:borderView];
        
        // Setup the label for info about the model
        UILabel *modelLabel = [[UILabel alloc] init];
        [modelLabel setTextAlignment:NSTextAlignmentLeft];
        modelLabel.text = [Constant getNameOfPlayerJetWithType:row];
        modelLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [modelLabel setFrame:CGRectMake(300, 50, 300, 50)];
        [modelLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:modelLabel];
        
        /* Display strength */
        NSArray *strengths = [Constant getStrength:row];
        UIImage *strengthImageIndicator = [Utilities loadImageWithName:@"note1-5"];
        // Health rate
        UILabel *healthLabel = [[UILabel alloc] init];
        [healthLabel setTextAlignment:NSTextAlignmentLeft];
        healthLabel.text = @"Health:";
        healthLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [healthLabel setFrame:CGRectMake(300, 100, 200, 50)];
        [healthLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:healthLabel];
        for(int i = 0; i < [strengths[0] integerValue]; i++){
            UIImageView *indicator = [[UIImageView alloc] initWithFrame:CGRectMake(430 + i * 30, 90, 50, 50)];
            [indicator setImage:strengthImageIndicator];
            [view addSubview:indicator];
        }
        
        // Damage rate
        UILabel *damageLabel = [[UILabel alloc] init];
        [damageLabel setTextAlignment:NSTextAlignmentLeft];
        damageLabel.text = @"Damage:";
        damageLabel.font = [UIFont fontWithName:kFuturaFontName size:30];
        [damageLabel setFrame:CGRectMake(300, 150, 200, 50)];
        [damageLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:damageLabel];
        for(int i = 0; i < [strengths[1] integerValue]; i++){
            UIImageView *indicator = [[UIImageView alloc] initWithFrame:CGRectMake(430 + i * 30, 140,  50, 50)];
            [indicator setImage:strengthImageIndicator];
            [view addSubview:indicator];
        }
    }
    
    return view;
}

-(IBAction) upButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the up button is pressed. It will scroll up the list of models by 1
    
    self.downButton.hidden = NO;
    NSInteger currentRow = [modelPicker selectedRowInComponent:0];
    if(currentRow == HIGH_DAMAGE_INDEX){
        self.upButton.hidden = YES;
    }
    [modelPicker selectRow:currentRow - 1 inComponent:0 animated:YES];
    selectedIndex = currentRow - 1;
}

- (IBAction) downButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the down button is pressed. It will scroll down the list of models by 1
    
    self.upButton.hidden = NO;
    NSInteger currentRow = [modelPicker selectedRowInComponent:0];
    if(currentRow == HIGH_DAMAGE_INDEX){
        self.downButton.hidden = YES;
    }
    [modelPicker selectRow:currentRow + 1 inComponent:0 animated:YES];
    selectedIndex = currentRow + 1;
}

-(IBAction)unwindToSelectModelScreen:(UIStoryboardSegue *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method to enable other view controllers to unwind back to this view controller
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqual:kSelectLevelSegueIdentifier]){
        if([PlayerJet modelType] != selectedIndex){
            [PlayerJet setModelType:selectedIndex];
            [PlayScene releaseModelSharedAssets];
        }
    }
}

#pragma mark - State Preservation and Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    [coder encodeInt:(int)selectedIndex forKey:kModelTypeKey];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes retorable state information of this view controller
    
    selectedIndex = (NSUInteger)[coder decodeIntForKey:kModelTypeKey];
    [super decodeRestorableStateWithCoder:coder];
}

@end
