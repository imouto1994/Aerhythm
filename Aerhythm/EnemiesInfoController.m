#import "EnemiesInfoController.h"
#import "Utilities.h"
#import "InfoCell.h"
#import "Constant.h"

#define Info_Identifier @"Info_Identifier"

#define FIRST_INDEX 0
#define DEFAULT_ENEMY_INDEX 0
#define FIRE_ENEMY_INDEX 1
#define ICE_ENEMY_INDEX 2
#define NINJA_ENEMY_INDEX 3
#define GEM_ENEMY_INDEX 4
#define BOMB_ENEMY_INDEX 5
#define LIGHTNING_ENEMY_INDEX 6
#define NUM_ENEMIES 7

#define kInfoScreenImageName @"infoScreen"
#define kNavigateButtonImageName @"blueBackButton"
#define kTableInfoBarImageName @"blueTableBar"
#define kFuturaFontName @"Futura (Light)"

@implementation EnemiesInfoController{
    // The view for background image
    UIImageView *backgroundImageView;
    // The image view for top bar of the table view
    UIImageView *topTableBarView;
    // The image view for bottom bar of the table view
    UIImageView *bottomTableBarView;
    // Current selected model
    NSInteger selectedIndex;
}

static NSString * const kDefaultEnemyInfo = @"This is info about default enemy.";
static NSString * const kFireEnemyInfo = @"This is info about fire enemy.";
static NSString * const kIceEnemyInfo = @"This is info about ice enemy.";
static NSString * const kNinjaEnemyInfo = @"This is info about ninja enemy.";
static NSString * const kBombEnemyInfo = @"This is info about bomb enemy.";
static NSString * const kGemEnemyInfo = @"This is info about gem enemy.";
static NSString * const kLightningEnemyInfo = @"This is info about lightning enemy.";

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
    } else if(selectedIndex == NUM_ENEMIES - 1){
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
    
    return NUM_ENEMIES;
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
        case DEFAULT_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-default"];
            [infoCell setTitle:@"Default Enemy"];
            [infoCell setDetails:kDefaultEnemyInfo];
            break;
        case FIRE_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-fire"];
            [infoCell setTitle:@"Fire Enemy"];
            [infoCell setDetails:kFireEnemyInfo];
            break;
        case ICE_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-ice"];
            [infoCell setTitle:@"Ice Enemy"];
            [infoCell setDetails:kIceEnemyInfo];
            break;
        case NINJA_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-ninja"];
            [infoCell setTitle:@"Ninja Enemy"];
            [infoCell setDetails:kNinjaEnemyInfo];
            break;
        case BOMB_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-bomb"];
            [infoCell setTitle:@"Bomb Enemy"];
            [infoCell setDetails:kBombEnemyInfo];
            break;
        case GEM_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-gem"];
            [infoCell setTitle:@"Gem Enemy"];
            [infoCell setDetails:kGemEnemyInfo];
            break;
        case LIGHTNING_ENEMY_INDEX:
            [infoCell setRepresentingImageName:@"enemy-lightning"];
            [infoCell setTitle:@"Lightning Enemy"];
            [infoCell setDetails:kLightningEnemyInfo];
            break;
        default:
            break;
    }
    

    return cell;
}

-(IBAction) upButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the up button is pressed. It will scroll up the list of models by 1
    
    self.downButton.hidden = NO;
    if(selectedIndex == FIRST_INDEX + 1){
        self.upButton.hidden = YES;
    }
    [self.infoTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex - 1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    selectedIndex--;
}

- (IBAction) downButtonPressed:(UIButton *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the down button is pressed. It will scroll down the list of models by 1
    
    self.upButton.hidden = NO;
    if(selectedIndex == NUM_ENEMIES - 2){
        self.downButton.hidden = YES;
    }
    [self.infoTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex + 1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    selectedIndex++;
}

@end


