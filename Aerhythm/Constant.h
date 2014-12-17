#import <Foundation/Foundation.h>

@interface Constant : NSObject

/*******************************************
                Type of bullet
 *******************************************/
typedef enum {
    kPlayerBullet1,
    kPlayerBullet2,
    kPlayerBullet3,
    kPlayerBullet4,
    kPlayerBullet5,
    kPlayerBullet6,
    kPlayerBullet7,
    kFireEnemyBullet,
    kDefaultEnemyBullet,
    kNinjaEnemyBullet,
    kIceEnemyBullet,
    kRockEnemyBullet,
    kShockEnemyBullet,
    kFirstBossNormalIntensedBullet,
    kFirstBossHighIntensedBullet,
    kSecondBossNormalIntensedBullet,
    kSecondBossHighIntensedBullet,
    kSecondBossExtremeIntensedBullet,
    kThirdBossNormalIntensedBullet,
    kThirdBossHighIntensedBullet,
    kFourthBossNormalIntensedBullet,
    kFourthBossHighIntensedBullet,
    kFourthBossExtremeIntensedBullet,
    kFourthBossUltimateIntensedBullet,
} BulletType;

/********************************************
                Type of powerups
 ********************************************/
typedef NS_ENUM(NSUInteger, PowerupType) {
    kHealerPowerup = 0,
    kShieldPowerup = 1,
    kDoubleFirePowerup = 2,
    kTripleFirePowerup = 3,
    kQuadrupleFirePowerup = 4,
    kPursuePowerup = 5,
    kRevivalPowerup = 6,
    kConfusePowerup = 7,
    kDestructionPowerup = 8,
    kPowerupTypeCount = 9
};

/*******************************************
            Type of bitmasks
********************************************/
typedef NS_OPTIONS(NSInteger, GameObjectType) {
    kPlayerJet = 1 << 0,
    kEnemyJet = 1 << 1,
    kBossJet = 1 << 2,
    kPlayerBullet = 1 << 3,
    kEnemyBullet = 1 << 4,
    kPowerup = 1 << 5,
    kWallLeft = 1 << 6,
    kWallRight = 1 << 7,
    kWallTop = 1 << 8,
    kSuicideEnemyJet = 1 << 9,
};

/*****************************************
            Type of enemies
 ****************************************/
typedef NS_ENUM(NSUInteger, EnemyType) {
    kNoEnemy = 0,
    kFireEnemy = 1,
    kDefaultEnemy = 2,
    kNinjaEnemy = 3,
    kIceEnemy = 4,
    kSuicideEnemy = 5,
    kRockEnemy = 6,
    kShockEnemy = 7,
    kFirstBoss = 8,
    kSecondBoss = 9,
    kThirdBoss = 10,
    kFourthBoss = 11
};

/*****************************************
 Type of enemies
 ****************************************/
typedef NS_ENUM(NSUInteger, BossType) {
    kBossOne = 0,
    kBossTwo = 1,
    kBossThree = 2,
    kBossFour = 3
};

/****************************************
            Type of player jets
******************************************/
typedef NS_ENUM(NSUInteger, PlayerJetType) {
    kOriginal = 0,
    kHighDamage = 1,
    kHighHealth = 2
};

/****************************************
            Type of walls
 ******************************************/
typedef NS_ENUM(NSUInteger, WallType) {
    kLeftWall,
    kRightWall,
};

/****************************************
            Type of firing
 ******************************************/
typedef NS_ENUM(NSUInteger, PlayerFireType) {
    kDefaultFire = 0,
    kDoubleFire = 1,
    kTripleFire = 2,
    kQuadrupleSpinFire = 3,
    kPursueFire = 4,
    kNumFireType = 5
};

/****************************************
        Type of spinning direction
 ******************************************/
typedef NS_ENUM(NSInteger, SpinDirection) {
    kClockwiseSpin = -1,
    kAntiClockwiseSpin = 1
};

/****************************************
        Type of profile picture size
 ******************************************/
typedef NS_ENUM(NSUInteger, ProfilePictureSize) {
    kSmall = 0,
    kNormal = 1,
    kLarge = 2,
    kSquare = 3,
};

/****************************************
        RGB Color Structure
 ******************************************/
typedef struct {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} RGBColor;

+ (NSArray *)enemyList:(NSInteger)levelID;
// EFFECTS: Get the list of enemies according to the level ID

+ (NSArray *)damageList:(NSInteger)modelType;
// EFFECTS: Get the list of damages for each type of bullet according to the type of model

+ (NSArray *)getStrength:(NSInteger)modelType;
// EFFECTS: Get the strength in each attribute according to the type of model

+ (NSString *)getNameOfPlayerJetWithType:(PlayerJetType)type;
// EFFECTS: Returns a string representing the name of the player jet model based on the input type

+ (EnemyType)getEnemyTypeFromName:(NSString *)name;
// EFFECTS: Returns the enemy type based on the input string representing the enemy name

+ (NSString *)getNameOfEnemyWithType:(EnemyType)enemyType;
// EFFECTS: Returns a string representing the name of the enemy based on the input enemy type

+ (NSArray *)getAppDefaultFacebookPermissions;
// EFFECTS: Returns the default Facebook permissions of the app

@end

static NSString * const kGameStatisticsParseClassName = @"AerhythmGameStatistics";
const static int kNumLevel = 4;

/*******************************************
 List of colors for enemies in map layout
 **********************************************/

const static RGBColor kFireEnemyLayoutColor= {255, 72, 72};
const static RGBColor kDefaultEnemyLayoutColor = {72, 180, 255};
const static RGBColor kNinjaEnemyLayoutColor = {72, 255, 98};
const static RGBColor kIceEnemyLayoutColor = {0, 255, 0};
const static RGBColor kSuicideEnemyLayoutColor = {255, 0, 255};
const static RGBColor kRockEnemyLayoutColor = {192, 192, 192};
const static RGBColor kShockEnemyLayoutColor = {255, 255, 0};
const static RGBColor kBossLayoutColor = {255, 0, 0};
