#import "Constant.h"

@implementation Constant

+ (NSArray *)damageList:(NSInteger)modelType {
    // EFFECTS: Get the list of damages for each type of bullet according to the type of model
    
    static NSArray * originalDamages;
    static NSArray * highDamages;
    static NSArray * lowDamages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        originalDamages = @[@18.0, @18.0, @14.0, @16.0, @15.0, @18.0, @15.0];
        highDamages = @[@22.0, @22.0, @18.0, @20.0, @19.0, @22.0, @19.0];
        lowDamages = @[@16.0, @16.0, @12.0, @14.0, @13.0, @16.0, @13.0];
    });
    
    if(modelType == 0){
        return originalDamages;
    } else if (modelType == 1) {
        return highDamages;
    } else if (modelType == 2) {
        return lowDamages;
    } else {
        [NSException raise:@"Invalid model type" format:@"This model is invalid"];
        return nil;
    }
}

+ (NSArray *)getStrength:(NSInteger)modelType {
    // EFFECTS: Get the strength in each attribute according to the type of model
    
    static NSArray * originalStrength;
    static NSArray * highDamageStrength;
    static NSArray * highHealthStrength;
    static dispatch_once_t onceStrengthToken;
    dispatch_once(&onceStrengthToken, ^{
        originalStrength = @[@5, @5];
        highDamageStrength = @[@3, @7];
        highHealthStrength = @[@7, @3];
    });
    
    if (modelType == 0){
        return originalStrength;
    } else if (modelType == 1){
        return highDamageStrength;
    } else if (modelType == 2) {
        return highHealthStrength;
    } else {
        [NSException raise:@"Invalid model type" format:@"This model is invalid"];
        return nil;
    }
}

+ (NSArray *)enemyList:(NSInteger)levelID {
    // EFFECTS: Get the list of enemies according to the level ID

    switch (levelID) {
        case 0:
            return [Constant firstLevelEnemyList];
            break;
        case 1:
            return [Constant secondLevelEnemyList];
            break;
        case 2:
            return [Constant thirdLevelEnemyList];
            break;
        case 3:
            return [Constant fourthLevelEnemyList];
            break;
        case 4:
            return [Constant testLevelEnemyList];
            break;
        default:
            return nil;
    }
}

+ (NSArray *)testLevelEnemyList {
    // EFFECTS: Get the list of enemies for test level
    
    static NSArray * testLevelList;
    static dispatch_once_t onceTestToken;
    dispatch_once(&onceTestToken, ^{
        testLevelList = @[@8, @9, @10, @11, @5];
    });
    return testLevelList;
}

+ (NSArray *)firstLevelEnemyList {
    // EFFECTS: Get the list of enemies for first level
    
    static NSArray *firstLevelList;
    static dispatch_once_t onceFirstToken;
    dispatch_once(&onceFirstToken, ^{
        firstLevelList = @[@1, @2, @3, @8];
    });
    
    return firstLevelList;
}

+ (NSArray *)secondLevelEnemyList {
    // EFFECTS: Get the list of enemies for second level
    
    static NSArray *secondLevelList;
    static dispatch_once_t onceSecondToken;
    dispatch_once(&onceSecondToken, ^{
        secondLevelList = @[@1, @2, @3, @4, @9];
    });
    
    return secondLevelList;
}

+ (NSArray *)thirdLevelEnemyList {
    // EFFECTS: Get the list of enemies for third level
    
    static NSArray *thirdLevelList;
    static dispatch_once_t onceThirdToken;
    dispatch_once(&onceThirdToken, ^{
        thirdLevelList = @[@1, @2, @3, @4, @5, @6, @10];
    });
    
    return thirdLevelList;
}

+ (NSArray *)fourthLevelEnemyList {
    // EFFECTS: Get the list of enemies for fourth level
    
    static NSArray *fourthLevelList;
    static dispatch_once_t onceFourthToken;
    dispatch_once(&onceFourthToken, ^{
        fourthLevelList = @[@1, @2, @3, @4, @5, @6, @7, @11];
    });
    return fourthLevelList;
}

// List of constant names for player jet models
static NSString * const kOriginalJetName = @"Sky Avalon";
static NSString * const kHighDamageJetName = @"Lightning Flash";
static NSString * const kHighHealthJetName = @"Astro Rocket";

+ (NSString *)getNameOfPlayerJetWithType:(PlayerJetType)type{
    // EFFECTS: Returns a string representing the name of the player jet model based on the input type
    
    switch (type) {
        case kOriginal:
            return kOriginalJetName;
            
        case kHighDamage:
            return kHighDamageJetName;
            
        case kHighHealth:
            return kHighHealthJetName;
    }
}

+ (EnemyType)getEnemyTypeFromName:(NSString *)name {
    // EFFECTS: Returns the enemy type based on the input string representing the enemy name
    
    if ([name isEqualToString:kFireEnemyName]) {
        return kFireEnemy;
    }
    if ([name isEqualToString:kDefaultEnemyName]) {
        return kDefaultEnemy;
    }
    if ([name isEqualToString:kNinjaEnemyName]) {
        return kNinjaEnemy;
    }
    if ([name isEqualToString:kIceEnemyName]) {
        return kIceEnemy;
    }
    if ([name isEqualToString:kSuicideEnemyName]) {
        return kSuicideEnemy;
    }
    if ([name isEqualToString:kRockEnemyName]) {
        return kRockEnemy;
    }
    if ([name isEqualToString:kShockEnemyName]) {
        return kShockEnemy;
    }
    if ([name isEqualToString:kFirstBossName]) {
        return kFirstBoss;
    }
    if ([name isEqualToString:kSecondBossName]) {
        return kSecondBoss;
    }
    if ([name isEqualToString:kThirdBossName]) {
        return kThirdBoss;
    }
    
    if ([name isEqualToString:kFourthBossName]){
        return kFourthBoss;
    }
    // Dummy
    return kNoEnemy;
}

// List of constant names for enemies
static NSString * const kNoEnemyName = @"";
static NSString * const kFireEnemyName = @"fireEnemy";
static NSString * const kDefaultEnemyName = @"defaultEnemy";
static NSString * const kNinjaEnemyName = @"ninjaEnemy";
static NSString * const kIceEnemyName = @"iceEnemy";
static NSString * const kSuicideEnemyName = @"suicideEnemy";
static NSString * const kRockEnemyName = @"rockEnemy";
static NSString * const kShockEnemyName = @"shockEnemy";
static NSString * const kFirstBossName = @"firstBoss";
static NSString * const kSecondBossName = @"secondBoss";
static NSString * const kThirdBossName = @"thirdBoss";
static NSString * const kFourthBossName = @"fourthBoss";

+ (NSString *)getNameOfEnemyWithType:(EnemyType)enemyType{
    // EFFECTS: Returns a string representing the name of the enemy based on the input enemy type
    
    switch (enemyType) {
        case kFireEnemy:
            return kFireEnemyName;
        case kDefaultEnemy:
            return kDefaultEnemyName;
        case kNinjaEnemy:
            return kNinjaEnemyName;
        case kIceEnemy:
            return kIceEnemyName;
        case kSuicideEnemy:
            return kSuicideEnemyName;
        case kRockEnemy:
            return kRockEnemyName;
        case kShockEnemy:
            return kShockEnemyName;
        case kFirstBoss:
            return kFirstBossName;
        case kSecondBoss:
            return kSecondBossName;
        case kThirdBoss:
            return kThirdBossName;
            break;
        case kFourthBoss:
            return kFourthBossName;
        default:
            return kNoEnemyName;
    }
}

+ (NSArray *)getAppDefaultFacebookPermissions {
    // EFFECTS: Returns the default Facebook permissions of the app
    
    return @[@"email", @"basic_info", @"publish_actions",
             @"user_about_me", @"read_friendlists",
             @"friends_online_presence"];
}

@end
