#import "UpgradeCell.h"
#import "CircularView.h"
#import "GameUpgrade.h"
#import "Utilities.h"

#define HEALTH_UPGRADE_INDEX 0
#define SHIELD_UPGRADE_INDEX 1
#define DOUBLE_FIRE_UPGRADE_INDEX 2
#define TRIPLE_FIRE_UPGRADE_INDEX 3
#define QUADRUPLE_FIRE_UPGRADE_INDEX 4
#define PURSUE_FIRE_UPGRADE_INDEX 5
#define REVIVAL_UPGRADE_INDEX 6

#define kFuturaFontName @"Futura (Light)"

@implementation UpgradeCell{
    // The view of the cell
    UIView *cellView;
    // The view of the cell border
    UIImageView *upgradeImageView;
    // The title of the upgrade cell
    UILabel *upgradeTitle;
    // The button for upgrading
    UIButton *upgradeButton;
    // The display slots for upgrading
    NSMutableArray *slotImageViews;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    // MODIFIES: self
    // EFFECTS: Init the cell with the given style and its corresponding resued identifier.
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        
        // Add view for upgrade table cell
        cellView = [[UIView alloc] init];
        [cellView setFrame:CGRectMake(0, 0, 768, 130)];
        
        // Add table cell frame
        UIImage *tableFrame = [Utilities loadImageWithName:@"tableUpgrade"];
        UIImageView *frameView = [[UIImageView alloc] initWithImage:tableFrame];
        [frameView setFrame:CGRectMake(0, 0, 768, 130)];
        [cellView addSubview:frameView];
        [cellView sendSubviewToBack:frameView];
        
        // Add upgrade image
        upgradeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 90, 90)];
        [cellView addSubview:upgradeImageView];
        
        // Add upgrade title
        upgradeTitle = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 500, 40)];
        [upgradeTitle setFont:[UIFont fontWithName:kFuturaFontName size:25]];
        upgradeTitle.textColor = [UIColor whiteColor];
        [cellView addSubview:upgradeTitle];
        
        // Add upgrade button
        UIImage *upgradeImage = [Utilities loadImageWithName:@"increaseButton"];
        upgradeButton = [[UIButton alloc] initWithFrame:CGRectMake(650, 40, 48, 48)];
        [upgradeButton setImage:upgradeImage forState:UIControlStateNormal];
        [upgradeButton addTarget:self action:@selector(upgrade) forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:upgradeButton];
        
        // Add default slots for upgrade
        UIImage *upgradeSlotImage = [UIImage imageNamed:@"note-upgrade"];
        slotImageViews = [NSMutableArray array];
        for(int i = 0; i < 7; i++){
            UIImageView *slotView = [[UIImageView alloc] initWithImage:upgradeSlotImage];
            [slotView setFrame:CGRectMake(125 + i * 65, 38, 50, 50)];
            [cellView addSubview:slotView];
            [slotImageViews addObject:slotView];
        }
        
        [self addSubview:cellView];
    }
    return self;
}

-(void) upgrade{
    // REQUIRES: self
    // EFFECTS: Call the delegate to update the current type of power-up in this cell
    
    [self.delegate upgradePowerupForPowerupType:self.upgradeType];
}

-(void) updateType:(NSInteger)upgradeType forCurrentUpgrade:(GameUpgrade *)currentUpgrade{
    // REQUIRES: self != nil
    // MODIFIES: self.upgradeType
    // EFFECTS: Set the type of power-up for upgrading in this cell. Set the necessary data for display and the cost for the next upgrade basing on the current data of upgrading.
    
    self.upgradeType = upgradeType;
    UIImage *upgradeImage;
    switch (upgradeType) {
        case HEALTH_UPGRADE_INDEX:
            upgradeTitle.text = @"Heal Amount Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"healthPowerup"];
            break;
        case SHIELD_UPGRADE_INDEX:
            upgradeTitle.text = @"Shield Duration Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"shieldPowerup"];
            break;
        case DOUBLE_FIRE_UPGRADE_INDEX:
            upgradeTitle.text = @"Double Fire Duration Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"projectile2Powerup"];
            break;
        case TRIPLE_FIRE_UPGRADE_INDEX:
            upgradeTitle.text = @"Triple Fire Duration Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"projectile3Powerup"];
            break;
        case QUADRUPLE_FIRE_UPGRADE_INDEX:
            upgradeTitle.text = @"Quadruple Fire Duration Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"projectile4Powerup"];
            break;
        case PURSUE_FIRE_UPGRADE_INDEX:
            upgradeTitle.text = @"Pursue Fire Duration Upgrade";
            upgradeImage = [Utilities loadImageWithName:@"aimPowerup"];
            break;
        case REVIVAL_UPGRADE_INDEX:
            upgradeTitle.text = @"Revival Stock";
            upgradeImage = [Utilities loadImageWithName:@"revivePowerup"];
            break;
        default:
            upgradeTitle.text = @"";
            upgradeImage = nil;
            break;
    }
    if([currentUpgrade currentRateForPowerupType:upgradeType] != 7){
    upgradeTitle.text = [upgradeTitle.text stringByAppendingString:[NSString stringWithFormat:@" - %ld", (long)[currentUpgrade getIncrementCostForPowerupType:upgradeType]]];
    }
    upgradeImageView.image = upgradeImage;
}

-(void) updateRate:(NSInteger)rate{
    // REQUIRES: self != nil
    // MODIFIES: self.upgradeRate
    // EFFECTS: Update the rate of upgrading to the given rate
    
    UIImage *upgradedImage = [Utilities loadImageWithName:@"note1-2"];
    UIImage *upgradeSlotImage = [Utilities loadImageWithName:@"note-upgrade"];

    for(int i = 0; i < 7; i++){
        UIImageView *slotView = [slotImageViews objectAtIndex:i];
        if(i < rate){
            [slotView setImage:upgradedImage];
        } else {
            [slotView setImage:upgradeSlotImage];
        }
    }
}

@end
