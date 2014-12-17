#import <Foundation/Foundation.h>
#import "Constant.h"

@interface GameUpgrade : NSObject<NSCoding>
// OVERVIEW: This is the class for storing the milestones in upgrading for the game

// The total score the player has gained throughout the game
@property (nonatomic) CGFloat score;
// The current rate for healing amount
@property (nonatomic) NSInteger healAmountRate;
// The current rate for duration of triple fire
@property (nonatomic) NSInteger tripleFireDurationRate;
// The current rate for duration of shield
@property (nonatomic) NSInteger shieldDurationRate;
// The current rate for duration of double fire
@property (nonatomic) NSInteger doubleFireDurationRate;
// The current rate for duration of quadruple fire
@property (nonatomic) NSInteger quadrupleFireDurationRate;
// The current rate for duration of pursue fire
@property (nonatomic) NSInteger pursueFireDurationRate;
// The current number of stocks for revival
@property (nonatomic) NSInteger reviveStock;

+(NSString *) filePath;
// EFFECTS: Static method to return the path containing the filed used for game

+ (GameUpgrade *)loadUpgradeData;
// EFFECTS: Static method to get the game upgrade data from the game in the current device

+ (void)updateUpgradeData:(GameUpgrade *) newUpgradeData;
// EFFECTS: Static method to save the assigned game upgrade data for the game in the current device

-(NSInteger) currentRateForPowerupType:(PowerupType) type;
// REQUIRES: self != nil
// EFFECTS: Get the current rate for the given type of power-up

-(NSInteger) getIncrementCostForPowerupType:(PowerupType) type;
// REQUIRES: self != nil
// EFFECTS: Get the cost of upgrading for the given type of power-up

-(void) incrementStrengthForPowerupType:(PowerupType) type;
// REQUIRES: self != nil
// EFFECTS: Increment the rate for the given type of power-up

@end
