#import <Foundation/Foundation.h>

@interface GameAchievement : NSObject<NSCoding>
// OVERVIEW: This is the class used to keep track of the achievements the player gains in each level gameplay

// Indicator whether the player did kill the boss in the level
@property (nonatomic) BOOL didKillBoss;
// Number of killed enemies
@property (nonatomic) NSInteger enemyKilled;
// Number of total enemeies
@property (nonatomic) NSInteger totalEnemy;
// The final health of the player
@property (nonatomic) CGFloat finalHealth;
// The original health of the player
@property (nonatomic) CGFloat originalHealth;
// Indicator whether the player did use revival or not
@property (nonatomic) BOOL didUseRevival;
// The time the user spent playing this level
@property (nonatomic) NSTimeInterval timePlayed;

- (id)initWithTotalEnemy:(NSInteger)enemy andOriginalHealth:(CGFloat)health;
// MODIFIES: self
// EFFECTS: Initialize this object with an assigned number of total enemies and original health

- (CGFloat)getScores;
// EFFECTS: Get the final score

- (CGFloat)scoreForKillBossAchievement ;
// EFFECTS: Get additional score for killing boss

- (CGFloat)scoreForKillBossWithoutRevival;
// EFFECTS: Get additional score for killing boss withouht revival

- (CGFloat)scoreForKillEnemyAchievement ;
// EFFECTS: Get additional score for killing a certain amount of enemies

- (CGFloat)scoreForHealthAchievement;
// EFFECTS: Get additional score for keeping the remaining health

- (CGFloat)scoreForTimeAchievement;
// EFFECTS: Get additional score for finishing level in a cetain amount of time

@end
