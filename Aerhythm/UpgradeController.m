#import "UpgradeController.h"
#import "UpgradeCell.h"
#import "GameUpgrade.h"
#import "Utilities.h"

#define Upgrade_Identifier @"Upgrade_Identifier"
#define NUM_SECTIONS 1
#define NUM_ROWS 7

#define kBackToMenuSegueIdentifier @"backToMenu"
#define kFuturaFontName @"Futura (Light)"
#define kUpgradeScreenImageName @"upgradeScreen"
#define kTableUpgradeBarImageName @"blueTableBar"
#define kUpgradeBackButtonImageName @"blueBackButton"

@interface UpgradeController()<UpgradeCellDelegateProtocol>

@end

@implementation UpgradeController{
    // The image view for background
    UIImageView *backgroundImageView;
    // The image view for top bar of the table view
    UIImageView *topTableBarView;
    // The image view for bottom bar of the table view
    UIImageView *bottomTableBarView;
    // The data for current game upgrade
    GameUpgrade *currentGameUpgrade;
}

-(void) viewDidLoad{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the view is loaded
    
    [super viewDidLoad];
    self.upgradeTable.delegate = self;
    self.upgradeTable.dataSource = self;
    [self.upgradeTable registerClass:[UpgradeCell class] forCellReuseIdentifier:Upgrade_Identifier];
    self.scoreLabel.font = [UIFont fontWithName:kFuturaFontName size:25];
}

-(void) viewWillAppear:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the view will appear
    
    [super viewWillAppear:animated];
    // Setup the background image view
    UIImage *background = [Utilities loadImageWithName:kUpgradeScreenImageName];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup the table bar view
    UIImage *barImage = [Utilities loadImageWithName:kTableUpgradeBarImageName];
    topTableBarView = [[UIImageView alloc] initWithImage:barImage];
    [topTableBarView setFrame:CGRectMake(0, 180, 768, 30)];
    [self.view addSubview:topTableBarView];
    
    bottomTableBarView = [[UIImageView alloc] initWithImage:barImage];
    [bottomTableBarView setFrame:CGRectMake(0, 710, 768, 30)];
    [self.view addSubview:bottomTableBarView];
    
    // Load game upgrade data
    currentGameUpgrade = [GameUpgrade loadUpgradeData];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.0f", currentGameUpgrade.score];
    
    // Setup "Back" button
    UIImage *backImage = [Utilities loadImageWithName:kUpgradeBackButtonImageName];
    [self.backButton setImage: backImage forState:UIControlStateNormal];
}

-(void) viewDidDisappear:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the view did disappear
    
    [super viewDidDisappear:animated];
    // Remove background
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    // Remove table bars
    [topTableBarView removeFromSuperview];
    topTableBarView = nil;
    [bottomTableBarView removeFromSuperview];
    bottomTableBarView = nil;
    
    // Remove button image display
    [self.backButton setImage:nil forState:UIControlStateNormal];
}

#pragma mark - Table View Data Source protocol
-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView{
    // EFFECTS: Return the number of sections in the table view
    
    return NUM_SECTIONS;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // EFFECTS: Return the number of rows in a specific section
    
    return NUM_ROWS;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // EFFECTS: Construct a cell according to the index path in the  table view
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Upgrade_Identifier];
    if(cell == nil){
        cell = [[UpgradeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Upgrade_Identifier];
    }
    UpgradeCell *upgradeCell = (UpgradeCell *)cell;
    upgradeCell.delegate = self;
    [upgradeCell updateType:indexPath.row forCurrentUpgrade:currentGameUpgrade];
    [upgradeCell updateRate:[currentGameUpgrade currentRateForPowerupType:indexPath.row]];
    
    return cell;
}

#pragma mark - Upgrade Cell Delegate Protocol

-(void) upgradePowerupForPowerupType:(PowerupType)powerupType{
    // EFFECTS: Upgrade the given type of power-up if possible
    
    if([currentGameUpgrade currentRateForPowerupType:powerupType] < 7 && currentGameUpgrade.score > [currentGameUpgrade getIncrementCostForPowerupType:powerupType]){
        currentGameUpgrade.score -= [currentGameUpgrade getIncrementCostForPowerupType:powerupType];
        [currentGameUpgrade incrementStrengthForPowerupType:powerupType];
        self.scoreLabel.text = [NSString stringWithFormat:@"%.0f", currentGameUpgrade.score];
        [self.upgradeTable reloadData];
    }
}

#pragma mark - Segue Transition Preparation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method if the segue is used for navigating back to the Main Menu screen
    
    if([segue.identifier isEqual:kBackToMenuSegueIdentifier]){
        [GameUpgrade updateUpgradeData:currentGameUpgrade];
    }
}
@end
