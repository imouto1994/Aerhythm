#import "BulletsInfoController.h"
#import "Utilities.h"
#import "InfoCell.h"
#import "Constant.h"

#define Info_Identifier @"Info_Identifier"

#define FIRST_INDEX 0
#define FROZEN_BULLET_INDEX 0
#define SLOW_BULLET_INDEX 1
#define HOLLOW_BULLET_INDEX 2
#define WIND_BULLET_INDEX 3
#define LIGHTNING_BULLET_INDEX 4
#define FIRE_BULLET_INDEX 5
#define BOMB_BULLET_INDEX 6
#define NUM_BULLETS 7

#define kInfoScreenImageName @"infoScreen"
#define kNavigateButtonImageName @"blueBackButton"
#define kTableInfoBarImageName @"blueTableBar"
#define kFuturaFontName @"Futura (Light)"


@implementation BulletsInfoController{
    // The view for background image
    UIImageView *backgroundImageView;
    // The image view for top bar of the table view
    UIImageView *topTableBarView;
    // The image view for bottom bar of the table view
    UIImageView *bottomTableBarView;
    // Current selected model
    NSInteger selectedIndex;
}

static NSString * const kFrozenBulletInfo = @"This is info about frozen bullet.";
static NSString * const kSlowBulletInfo = @"This is info about slow bullet.";
static NSString * const kHollowBulletInfo = @"This is info about hollow bullet.";
static NSString * const kWindBulletInfo = @"This is info about wind bullet.";
static NSString * const kLightningBulletInfo = @"This is info about lightning bullet.";
static NSString * const kFireBulletInfo = @"This is info about fire bullet.";
static NSString * const kBombBulletInfo = @"This is info about bomb bullet.";

-(void) viewDidLoad{
    // MODIFIES: self
    // EFFECTS: Setup the view when it is first loaded
    
    [super viewDidLoad];
    self.infoTable.delegate = self;
    self.infoTable.dataSource = self;
    [self.infoTable registerClass:[InfoCell class] forCellReuseIdentifier:Info_Identifier];
    
    selectedIndex = 0;
    [self.infoTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    // Setup buttons
    self.upButton.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    self.downButton.transform = CGAffineTransformMakeRotation(-M_PI / 2.0);
}

-(void) viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Setup the enemies info screen for every time it appears
    
    [super viewWillAppear:animated];
    
    if(selectedIndex == FIRST_INDEX){
        [self.upButton setHidden:YES];
    } else if(selectedIndex == NUM_BULLETS - 1){
        [self.downButton setHidden:YES];
    }
    
    // Setup buttons in the screen
    UIImage *navigateButtonImage = [Utilities loadImageWithName:kNavigateButtonImageName];
    [self.backButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.upButton setImage:navigateButtonImage forState:UIControlStateNormal];
    [self.downButton setImage:navigateButtonImage forState:UIControlStateNormal];
    
    // Setup background
    UIImage *background = [Utilities loadImageWithName:kInfoScreenImageName];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup the table bar view
    UIImage *barImage = [Utilities loadImageWithName:kTableInfoBarImageName];
    topTableBarView = [[UIImageView alloc] initWithImage:barImage];
    [topTableBarView setFrame:CGRectMake(0, 180, 768, 30)];
    [self.view addSubview:topTableBarView];
    
    bottomTableBarView = [[UIImageView alloc] initWithImage:barImage];
    [bottomTableBarView setFrame:CGRectMake(0, 710, 768, 30)];
    [self.view addSubview:bottomTableBarView];
}

-(void) viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Remove unneccessary things when the info screen disappears
    
    [super viewDidDisappear:animated];
    
    // Release the background image view
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    // Release table bars image view
    [topTableBarView removeFromSuperview];
    topTableBarView = nil;
    [bottomTableBarView removeFromSuperview];
    bottomTableBarView = nil;
    
    // Release the image representation for the button
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.upButton setImage:nil forState:UIControlStateNormal];
    [self.downButton setImage:nil forState:UIControlStateNormal];
}

#pragma mark - Table View Data Source protocol
-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView{
    // EFFECTS: Return the number of sections in the table view
    
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // EFFECTS: Return the number of rows in a specific section
    
    return NUM_BULLETS;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // EFFECTS: Construct a cell according to the index path in the  table view
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Info_Identifier];
    if(cell == nil){
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Info_Identifier];
    }
    
    InfoCell *infoCell = (InfoCell *) cell;
    
    NSInteger row = indexPath.row;
    // Load corresponding data
    switch (row) {
        case FROZEN_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-frozen"];
            [infoCell setTitle:@"Frozen Bullet"];
            [infoCell setDetails:kFrozenBulletInfo];
            break;
        case SLOW_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-slow"];
            [infoCell setTitle:@"Slow Bullet"];
            [infoCell setDetails:kSlowBulletInfo];
            break;
        case HOLLOW_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-hollow"];
            [infoCell setTitle:@"Hollow Bullet"];
            [infoCell setDetails:kHollowBulletInfo];
            break;
        case WIND_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-wind"];
            [infoCell setTitle:@"Wind Bullet"];
            [infoCell setDetails:kWindBulletInfo];
            break;
        case LIGHTNING_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-lightning"];
            [infoCell setTitle:@"Lightning Bullet"];
            [infoCell setDetails:kLightningBulletInfo];
            break;
        case FIRE_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-fire"];
            [infoCell setTitle:@"Fire Bullet"];
            [infoCell setDetails:kFireBulletInfo];
            break;
        case BOMB_BULLET_INDEX:
            [infoCell setRepresentingImageName:@"bullet-bomb"];
            [infoCell setTitle:@"Bomb Bullet"];
            [infoCell setDetails:kBombBulletInfo];
            break;
        default:
            break;
    }
    
    
    return cell;
}

-(IBAction) upButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the up button is pressed. It will scroll up the list of bullets by 1
    
    self.downButton.hidden = NO;
    if(selectedIndex == FIRST_INDEX + 1){
        self.upButton.hidden = YES;
    }
    [self.infoTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex - 1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    selectedIndex--;
}

- (IBAction) downButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the down button is pressed. It will scroll down the list of bullets by 1
    
    self.upButton.hidden = NO;
    if(selectedIndex == NUM_BULLETS - 2){
        self.downButton.hidden = YES;
    }
    [self.infoTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex + 1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    selectedIndex++;
}

@end
