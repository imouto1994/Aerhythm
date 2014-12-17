#import "ThirdBoss.h"
#import "Vector2D.h"
#import "PlayScene.h"
#import "EnemyFactory.h"

#define kHealth 14000.0
#define kHorizontalVelocity 200.0
#define kRadius 200

#define kFiringSpeed 30.0
#define kDefaultFireCounter 500.0

#define kSlowFactor 3.0
#define kNumberNeededFrozenBullet 50
#define kNumberNeededWindBullet 100000
#define kFireDamage 10

#define kSecondToReleaseSuicideEnemy 1.5
#define kNumSuicideEnemy 3
#define FPS 60

#define kNumAnglesForSpinFire 40

#define kPeriodForNormalFire 33
#define kNumTurnsForNormalFire 9

#define kPeriodForRockFire 45
#define kNumTurnsForRockFire 17
#define kFiringTimeDifferenceForRockFire 2

#define kPeriodForThirdStage 600
#define kTimeForRockFire 300

#define kThirdBossAtlas @"boss3"
#define kThirdBossDefaultTexture @"boss3"
#define kThirdBossFrozenTexture @"boss3-frozen"
#define kThirdBossDeadTexture @"boss3-dead"

#define kScore 1000

@interface ThirdBoss()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation ThirdBoss {
    CGFloat fireCounter;
    
    int normalFireCounter;
    
    int spinFireCounter;
    
    int rockFireCounter;
    
    int releaseSuicideEnemiesCounter;
    
    int thirdStageCounter;
}

@dynamic originalFiringSpeed;

const static int kFiringTimeForNormalBullets[9] = {0, 5, 10, 14, 18, 21, 24, 26, 28};
const static int kNumBullets[9] = {2, 2, 2, 3, 3, 3, 4, 4, 5};

const static int kFiringAnglesForRockBullets[17] = {0, -10, 0, 10, 20, 10, 0, -10, -20, -30, -20, -10, 0, 10, 20, 30, 40};

- (id)initAtPosition:(CGPoint)position {
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position
    
    self = [super initAtPosition:position withRadius:kRadius];
    
    if (self){
        self.texture = sDefaultTexture;
        self.health = kHealth;
        self.maxHealth = kHealth;
        self.physicsBody.velocity = CGVectorMake(kHorizontalVelocity, 0.0);
        self.jetSpeed = kHorizontalVelocity;
        self->slowFactor = kSlowFactor;
        self->numberNeededFrozenBullet = kNumberNeededFrozenBullet;
        self->numberNeededWindBullet = kNumberNeededWindBullet;
        self->fireDamage = kFireDamage;
        
        fireCounter = kDefaultFireCounter;
        self.firingSpeed = kFiringSpeed;
        self.originalFiringSpeed = kFiringSpeed;
        
        releaseSuicideEnemiesCounter = 0;
        spinFireCounter = 0;
        normalFireCounter = 0;
        rockFireCounter = 0;
        thirdStageCounter = 0;
    }
    return self;
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    CGFloat thresholdState2 = 2.0 / 3.0 * kHealth;
    CGFloat thresholdState3 = 1.0 / 3.0 * kHealth;
    
    if (self.health < thresholdState3) {
        if (thirdStageCounter < kTimeForRockFire) {
            [self fireRockBulletsWithPlayerPosition:playerPosition];
        } else {
            [self fireSpinBullets];
        }
        [self releaseSuicideEnemies];
        
        thirdStageCounter = (thirdStageCounter + 1) % kPeriodForThirdStage;
        
    } else if (self.health < thresholdState2) {
        [self fireSpinBullets];
    } else {
        [self fireNormalBulletsWithPlayerPosition:playerPosition];
    }
}

#pragma mark - First Stage Firing
- (void)fireNormalBulletsWithPlayerPosition:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinate system of self
    // EFFECTS: Fire normal bullets
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    fireCounter = kDefaultFireCounter;
    
    for (int i = 0; i < kNumTurnsForNormalFire; i++) {
        if (kFiringTimeForNormalBullets[i] == normalFireCounter) {
            switch (kNumBullets[i]) {
                case 1: {
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:0.0];
                    break;
                }
                    
                case 2: {
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:15.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-15.0];
                    break;
                }
                    
                case 3: {
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:30.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:0.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-30.0];
                    break;
                }
                    
                case 4: {
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:45.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:15.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-15.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-45.0];
                    break;
                }
                    
                case 5: {
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:60.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:30.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:0.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-30.0];
                    [self fireBulletWithType:kThirdBossNormalIntensedBullet
                          withPlayerPosition:playerPosition
                                    andAngle:-60.0];
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
    
    normalFireCounter = (normalFireCounter + 1) % kPeriodForNormalFire;
}

#pragma mark - Second Stage Firing
- (void)fireSpinBullets {
    // REQUIRS: self != nil
    // EFFECTS: Fire spin bullets
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    fireCounter = kDefaultFireCounter;
    
    BulletType bulletType = kThirdBossHighIntensedBullet;
    Vector2D *velocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    CGFloat speed = sqrt([velocity squareLength]);
    CGFloat distanceFromCenter = kRadius + 10.0;
    
    spinFireCounter = (spinFireCounter + 1) % kNumAnglesForSpinFire;
    
    for (int i = 0; i < 8; i++) {
        CGFloat angle = spinFireCounter * 360.0 / kNumAnglesForSpinFire + i * 45.0;
        Vector2D *rotatedVelocity = [velocity rotateWithAngle:angle];
        
        CGFloat dx = distanceFromCenter * rotatedVelocity.x / speed;
        CGFloat dy = distanceFromCenter * rotatedVelocity.y / speed;
        CGPoint firingPosition = CGPointMake(self.position.x + dx, self.position.y + dy);
        [self fireBulletWithType:bulletType
                      atPosition:firingPosition
                     andVelocity:[rotatedVelocity toCGVector]];
    }
}

#pragma mark - Third Stage Firing
- (void)fireRockBulletsWithPlayerPosition:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinate system of self
    // EFFECTS: Fire rock bullets
    
    fireCounter -= self.firingSpeed * 2;
    
    if (fireCounter > 0) {
        return;
    }
    
    fireCounter = kDefaultFireCounter;
    
    if (rockFireCounter % kFiringTimeDifferenceForRockFire == 0 && rockFireCounter < kNumTurnsForRockFire * kFiringTimeDifferenceForRockFire) {
        
        int angle = kFiringAnglesForRockBullets[rockFireCounter / kFiringTimeDifferenceForRockFire];
        
        [self fireBulletWithType:kRockEnemyBullet
              withPlayerPosition:playerPosition
                        andAngle:angle];
    }
    
    rockFireCounter = (rockFireCounter + 1) % kPeriodForRockFire;

}

- (void)releaseSuicideEnemies {
    // REQUIRES: self != nil
    // EFFECTS: Release suicide enemies from the boss
    
    releaseSuicideEnemiesCounter++;
    if (releaseSuicideEnemiesCounter < kSecondToReleaseSuicideEnemy * FPS) {
        return;
    }
    
    for (int i = 0; i < kNumSuicideEnemy; i++) {
        double angle = (arc4random() % 180) * acos(-1.0) / 180;
        CGPoint releasePosition = CGPointMake(self.position.x + cos(angle) * self.radius,
                                              self.position.y - sin(angle) * self.radius);
    
        EnemyJet *suicideEnemy = [EnemyFactory createEnemyJetWithType:kSuicideEnemy
                                                        andAtPosition:releasePosition];
        [[self gameObjectScene] addNode:suicideEnemy atWorldLayer:kEnemyLayer];
    }
    
    releaseSuicideEnemiesCounter = 0;
}

- (void)fireBulletWithType:(BulletType)bulletType
                atPosition:(CGPoint)position
               andVelocity:(CGVector)velocity {
    // REQUIRES: self != nil
    // EFFECTS: Fire a bullet with given type and firing position and velocity
    
    Bullet * bullet = [[EnemyBullet alloc] initWithPosition:position
                                              andBulletType:bulletType
                                                andVelocity:velocity
                                                 fromOrigin:kEnemyJet];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
}

- (void)fireBulletWithType:(BulletType)bulletType
        withPlayerPosition:(CGPoint)playerPosition
                  andAngle:(CGFloat)angle {
    // REQUIRES: self != nil
    // EFFECTS: Fire a bullet with given type, firing position and player position and rotate angle
    
    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition fromNode:self];
    CGPoint bossWorldPoint = [[self gameObjectScene] convertPoint:self.position fromNode:self.parent];
    
    CGVector velocity = [Bullet getDefaultVelocity:bulletType];
    Vector2D * fireDirectionVector = [[Vector2D vectorFromPoint:bossWorldPoint toPoint:playerWorldPoint] normalize];
    CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
    velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
    
    Vector2D * unitDirection = [[Vector2D vectorFromCGVector:velocity] normalize];
    CGPoint firingPosition = [[[unitDirection scalarMultiply:self.radius] rotateWithAngle:angle] applyVectorTranslationToPoint:self.position];
    
    Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                              andBulletType:bulletType
                                                andVelocity:velocity
                                                 fromOrigin:kEnemyJet];
    
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
   
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:kThirdBossAtlas];
    sDefaultTexture = [atlas textureNamed:kThirdBossDefaultTexture];
    sDeadTexture = [atlas textureNamed:kThirdBossDeadTexture];
    sFrozenTexture = [atlas textureNamed:kThirdBossFrozenTexture];
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sDefaultTexture = nil;
    sFrozenTexture = nil;
}

static SKTexture *sDefaultTexture = nil;
+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Get the shared default texture
    
    return sDefaultTexture;
}

static SKTexture *sDeadTexture = nil;
+ (SKTexture*)sDeadTexture {
    // EFFECTS: Get the shared default texture when the jet is dying
    
    return sDeadTexture;
}

static SKTexture *sFrozenTexture = nil;
+ (SKTexture *)sFrozenTexture {
    // EFFECTS: Get the shared default texture when the jet is frozen
    
    return sFrozenTexture;
}

+ (float)scoreGain {
    // EFFECTS: Get the score gain when the boss is killed
    
    return kScore;
}

@end
