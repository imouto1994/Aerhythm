#import "GameAchievement.h"

#define kEnemyKilledRatio 0.8
#define kHealthRatio 0.75
#define kTimeLimit 420

#define kKillBossScore 100.0
#define kKillBossWithoutRevival 2000.0
#define kKillEnemyScore 300.0
#define kHealthScore 500.0
#define kTimeScore 600.0

#define kDidKillBossKey @"didKillBoss"
#define kDidUseRevivalKey @"didUseRevival"
#define kEnemyKilledKey @"enemyKilled"
#define kTotalEnemyKey @"totalEnemy"
#define kFinalHealthKey @"finalHealth"
#define kOriginalHealthKey @"originalHealth"
#define kTimePlayedKey @"timePlayed"

@implementation GameAchievement

- (id)initWithTotalEnemy:(NSInteger)enemy andOriginalHealth:(CGFloat)health {
    // MODIFIES: self
    // EFFECTS: Initialize this object with an assigned number of total enemies and original health
    
    self = [super init];
    
    if (self) {
        _didKillBoss = false;
        _didUseRevival = false;
        _enemyKilled = 0;
        _totalEnemy = enemy;
        _finalHealth = 0.0;
        _originalHealth = health;
        _timePlayed = 0.0;
    }
    
    return self;
}

- (CGFloat)scoreForKillBossAchievement {
    // EFFECTS: Get additional score for killing boss
    
    return _didKillBoss ? kKillBossScore : 0.0;
}

- (CGFloat)scoreForKillBossWithoutRevival {
    // EFFECTS: Get additional score for killing boss withouht revival
    

    return _didKillBoss && (_didUseRevival == false) ? kKillBossWithoutRevival : 0.0;
}

- (CGFloat)scoreForKillEnemyAchievement {
    // EFFECTS: Get additional score for killing a certain amount of enemies
    
    return 1.0 * _enemyKilled / _totalEnemy >= kEnemyKilledRatio ? (kKillEnemyScore * _enemyKilled / _totalEnemy) : 0.0;
}

- (CGFloat)scoreForHealthAchievement {
    // EFFECTS: Get additional score for keeping the remaining health
    
    return 1.0 * _finalHealth / _originalHealth >= kHealthRatio ? (kHealthScore * _finalHealth / _originalHealth) : 0.0;
}

- (CGFloat)scoreForTimeAchievement {
    // EFFECTS: Get additional score for finishing level in a cetain amount of time
    
    return _didKillBoss && _timePlayed <= kTimeLimit ? kTimeScore * (kTimeLimit - _timePlayed) / kTimeLimit : 0.0;
}

- (CGFloat)getScores {
    // EFFECTS: Get the final score
    
    CGFloat scores = 0;
    scores += [self scoreForKillBossAchievement];
    scores += [self scoreForKillBossWithoutRevival];
    scores += [self scoreForKillEnemyAchievement];
    scores += [self scoreForHealthAchievement];
    scores += [self scoreForTimeAchievement];
    return scores;
}

- (void) encodeWithCoder:(NSCoder *)aCoder{
    // EFFECTS: Encode the data
    
    [aCoder encodeBool:_didKillBoss forKey:kDidKillBossKey];
    [aCoder encodeBool:_didUseRevival forKey:kDidUseRevivalKey];
    [aCoder encodeInteger:_enemyKilled forKey:kEnemyKilledKey];
    [aCoder encodeInteger:_totalEnemy forKey:kTotalEnemyKey];
    [aCoder encodeFloat:_finalHealth forKey:kFinalHealthKey];
    [aCoder encodeFloat:_originalHealth forKey:kOriginalHealthKey];
    [aCoder encodeFloat:_timePlayed forKey:kTimePlayedKey];
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    // EFFECTS: Initializing an object by using decoder

    self = [super init];
    if(self){
        self.didKillBoss = [aDecoder decodeBoolForKey:kDidKillBossKey];
        self.didUseRevival = [aDecoder decodeBoolForKey:kDidUseRevivalKey];
        self.enemyKilled = [aDecoder decodeIntegerForKey:kEnemyKilledKey];
        self.totalEnemy = [aDecoder decodeIntegerForKey:kTotalEnemyKey];
        self.finalHealth = [aDecoder decodeFloatForKey:kFinalHealthKey];
        self.originalHealth = [aDecoder decodeFloatForKey:kOriginalHealthKey];
        self.timePlayed = [aDecoder decodeFloatForKey:kTimePlayedKey];
    }
    return self;
}

@end
