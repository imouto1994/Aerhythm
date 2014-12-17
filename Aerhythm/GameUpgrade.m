#import "GameUpgrade.h"

#define kGameUpgradeKey @"gameUpgrade"
#define kScoreKey @"score"
#define kHealAmountKey @"healAmount"
#define kShieldDuationKey @"shieldDuration"
#define kDoubleFireDurationKey @"doubleFireDuration"
#define kTripleFireDurationKey @"tripleFireDuration"
#define kQuadrupleFireDurationKey @"quadrupleFireDuration"
#define kPursueFireDurationKey @"pursueFireDuration"
#define kReviveStockKey @"reviveStock"

@implementation GameUpgrade

-(id) init{
    // MODIFIES: self
    // EFFECTS: Override the init method from super class
    
    self = [super init];
    if(self){
        _score = 0.0;
        _healAmountRate = 0;
        _shieldDurationRate = 0;
        _doubleFireDurationRate = 0;
        _tripleFireDurationRate = 0;
        _quadrupleFireDurationRate  = 0;
        _pursueFireDurationRate = 0;
        _reviveStock = 0;
    }
    return self;
}

+ (GameUpgrade *)loadUpgradeData{
    // EFFECTS: Loads the current upgrade data of the game
    
    NSString * path = [GameUpgrade filePath];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (!data) { // no intial data
        GameUpgrade *initialData = [[GameUpgrade alloc] init];
        [GameUpgrade updateUpgradeData:initialData];
        return initialData;
    }
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GameUpgrade *upgradeData = [unarchiver decodeObjectForKey:kGameUpgradeKey];
    [unarchiver finishDecoding];
    return upgradeData;
}

+ (void)updateUpgradeData:(GameUpgrade *) newUpgradeData{
    // EFFECTS: Updates the current upgrade data of the game

    NSMutableData * data = [[NSMutableData alloc]init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:newUpgradeData forKey:kGameUpgradeKey];
    [archiver finishEncoding];
    NSString * path = [GameUpgrade filePath];
    [data writeToFile:path atomically:YES];
}

#pragma mark - NSCoding Protocol

-(id) initWithCoder:(NSCoder *)aDecoder{
    // MODIFIES: self
    // EFFECTS: Initialize the objecby decoding data
    
    self = [super init];
    if(self){
        _score = [aDecoder decodeFloatForKey:kScoreKey];
        _healAmountRate = [aDecoder decodeIntegerForKey:kHealAmountKey];
        _shieldDurationRate = [aDecoder decodeIntegerForKey:kShieldDuationKey];
        _doubleFireDurationRate = [aDecoder decodeIntegerForKey:kDoubleFireDurationKey];
        _tripleFireDurationRate = [aDecoder decodeIntegerForKey:kTripleFireDurationKey];
        _quadrupleFireDurationRate = [aDecoder decodeIntegerForKey:kQuadrupleFireDurationKey];
        _pursueFireDurationRate = [aDecoder decodeIntegerForKey:kPursueFireDurationKey];
        _reviveStock = [aDecoder decodeIntegerForKey:kReviveStockKey];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    // REQUIRES: self != nil
    // EFFECTS: Encode the current data with given encoder
    
    [aCoder encodeFloat:self.score forKey:kScoreKey];
    [aCoder encodeInteger:self.healAmountRate forKey:kHealAmountKey];
    [aCoder encodeInteger:self.shieldDurationRate forKey:kShieldDuationKey];
    [aCoder encodeInteger:self.doubleFireDurationRate forKey:kDoubleFireDurationKey];
    [aCoder encodeInteger:self.tripleFireDurationRate forKey:kTripleFireDurationKey];
    [aCoder encodeInteger:self.quadrupleFireDurationRate forKey:kQuadrupleFireDurationKey];
    [aCoder encodeInteger:self.pursueFireDurationRate forKey:kPursueFireDurationKey];
    [aCoder encodeInteger:self.reviveStock forKey:kReviveStockKey];
}

+(NSString *) filePath{
    // EFFECTS: Gets the path of file containing the info for current upgrade data of the game
    
    NSArray * pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    NSString * documentPath = [pathList objectAtIndex:0];
    NSString * filePath = [documentPath stringByAppendingPathComponent:@"GameUpgrade.td"];
    return filePath;
}

-(NSInteger) currentRateForPowerupType:(PowerupType)type{
    // REQUIRES: self != nil
    // EFFECTS: Get the current rate for the given type of power-up
    
    switch (type) {
        case kHealerPowerup:
            return self.healAmountRate;
            break;
        case kShieldPowerup:
            return self.shieldDurationRate;
            break;
        case kDoubleFirePowerup:
            return self.doubleFireDurationRate;
            break;
        case kTripleFirePowerup:
            return self.tripleFireDurationRate;
            break;
        case kQuadrupleFirePowerup:
            return self.quadrupleFireDurationRate;
            break;
        case kPursuePowerup:
            return self.pursueFireDurationRate;
            break;
        case kRevivalPowerup:
            return self.reviveStock;
            break;
        default:
            return -1;
            break;
    }
}

-(NSInteger) getIncrementCostForPowerupType:(PowerupType)type{
    // REQUIRES: self != nil
    // EFFECTS: Get the cost of upgrading for the given type of power-up
    
    switch ([self currentRateForPowerupType:type]) {
        case 0:
            return 500;
            break;
        case 1:
            return 1500;
            break;
        case 2:
            return 3000;
            break;
        case 3:
            return 6000;
            break;
        case 4:
            return 12000;
            break;
        case 5:
            return 24000;
            break;
        case 6:
            return 48000;
            break;
        case 7:
            return 96000;
            break;
        default:
            return -1;
            break;
    }
}

-(void) incrementStrengthForPowerupType:(PowerupType)type{
    // REQUIRES: self != nil
    // EFFECTS: Increment the rate for the given type of power-up
    
    switch (type) {
        case kHealerPowerup:
            self.healAmountRate++;
            break;
        case kShieldPowerup:
            self.shieldDurationRate++;
            break;
        case kDoubleFirePowerup:
            self.doubleFireDurationRate++;
            break;
        case kTripleFirePowerup:
            self.tripleFireDurationRate++;
            break;
        case kQuadrupleFirePowerup:
            self.quadrupleFireDurationRate++;
            break;
        case kPursuePowerup:
            self.pursueFireDurationRate++;
            break;
        case kRevivalPowerup:
            self.reviveStock++;
            break;
        default:
            break;
    }

}


@end
