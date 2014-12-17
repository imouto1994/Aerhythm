#import "FirstBoss.h"
#import "Vector2D.h"
#import "PlayScene.h"

#define kHealth 12000.0f
#define kHorizontalVelocity 100.0f
#define kSlowFactor 2.0f
#define kNumberNeededFrozenBullet 10
#define kNumberNeededWindBullet 100000
#define kFireDamage 2
#define kRadius 200
#define kFiringSpeed 8.0
#define kDefaultFireCounter 500.0
#define kScore 200

#define kFirstBossAtlas @"boss1"
#define kFirstBossDefaultTexture @"boss1"
#define kFirstBossFrozenTexture @"boss1-frozen"
#define kFirstBossDeadTexture @"boss1-dead"

@interface FirstBoss()

// The original firing speed
@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation FirstBoss {
    // The fire counter for the first boss
    CGFloat fireCounter;
}

@dynamic originalFiringSpeed;

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
    }
    return self;
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint
    
    if (!self.isAbleToFire || self.currentState == STATE_DEATH) {
        return;
    }
    
    CGFloat thresholdState2 = 2.0 / 3.0 * kHealth;
    CGFloat thresholdState3 = 1.0 / 3.0 * kHealth;
    
    if (self.health < thresholdState3) {
        [self fireCircleOfBullet];
    } else if (self.health < thresholdState2) {
        [self fireFanOfFireBulletWithHint:hasHint andPlayerPositionHint:playerPosition];
    } else {
        [self fireDefaultBulletWithHint:hasHint andPlayerPositionHint:playerPosition];
    }
}

#pragma mark - First Stage Firing
- (void)fireDefaultBulletWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Shoots a fan of fire bullets. Player position may be provided as a hint
    
    self.fireCounter -= 2.5 * self.firingSpeed;
    if (self.fireCounter > 0) {
        return;
    }
    
    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                           fromNode:self];
    CGPoint bossWorldPoint = [[self gameObjectScene] convertPoint:self.position
                                                         fromNode:self.parent];
    
    CGVector velocity = [Bullet getDefaultVelocity:self.bulletType];
    if (hasHint) {
        // Have player position as a hint
        Vector2D * fireDirectionVector = [[Vector2D vectorFromPoint:bossWorldPoint
                                                            toPoint:playerWorldPoint] normalize];
        CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
        velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
    }
    
    Vector2D * unitDirection = [[Vector2D vectorFromCGVector:velocity] normalize];
    CGPoint firingPosition = [[unitDirection scalarMultiply:self.radius]
                              applyVectorTranslationToPoint:self.position];
    
    Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                              andBulletType:kFirstBossNormalIntensedBullet
                                                andVelocity:velocity
                                                 fromOrigin:kEnemyJet];
    
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
    
    self.fireCounter = kDefaultFireCounter;
}

#pragma mark - Second Stage Firing
- (void)fireFanOfFireBulletWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Shoots a fan of fire bullets. Player position may be provided as a hint
    self.fireCounter -= 2.5 * self.firingSpeed;
    
    if (self.fireCounter > 0) {
        return;
    }

    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                           fromNode:self];
    CGPoint bossWorldPoint = [[self gameObjectScene] convertPoint:self.position
                                                         fromNode:self.parent];
    CGFloat aboveOrBelow = -1;
    if (playerWorldPoint.y > bossWorldPoint.y) {
        aboveOrBelow = 1;
    }
    
    Vector2D * defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:kFireEnemyBullet]];
    Vector2D * horizonVelocity = [Vector2D vectorWithX:defaultVelocity.length andY:0];
    Vector2D * positionOffset = [Vector2D vectorWithX:self.radius
                                                 andY:0];
    CGFloat rotateAngleOffset = 30;
    CGFloat currentRotateAngle = rotateAngleOffset;
    
    // Generate fire bullet fan
    while (currentRotateAngle < 180) {
        Vector2D * newVelocity = [horizonVelocity rotateWithAngle:aboveOrBelow * currentRotateAngle];
        Vector2D * newPositionOffset = [positionOffset rotateWithAngle:aboveOrBelow * currentRotateAngle];
        
        CGPoint firingPosition = CGPointMake(self.position.x + newPositionOffset.x,
                                             self.position.y + newPositionOffset.y);
        Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                  andBulletType:kFireEnemyBullet
                                                    andVelocity:[newVelocity toCGVector]
                                                     fromOrigin:kEnemyJet];
        [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        
        currentRotateAngle += rotateAngleOffset;
    }
    
    // Bonus some default bullets
    CGVector velocity = [Bullet getDefaultVelocity:kFirstBossNormalIntensedBullet];
    if (hasHint) {
        // Have player position as a hint
        Vector2D * fireDirectionVector = [[Vector2D vectorFromPoint:bossWorldPoint
                                                            toPoint:playerWorldPoint] normalize];
        CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
        velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
    }
    Vector2D * unitDirection = [[Vector2D vectorFromCGVector:velocity] normalize];
    
    NSUInteger numBonusDefaultBullets = 3;
    CGFloat bulletDistanceOffset = 10;
    
    CGFloat distanceOffset = self.radius / 2 + [Bullet getDefaultRadiusSize:kFirstBossNormalIntensedBullet];
    for (NSUInteger i = 0; i < numBonusDefaultBullets; i++) {
        CGPoint firingPosition = [[unitDirection scalarMultiply:distanceOffset]
                                   applyVectorTranslationToPoint:self.position];
        Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                  andBulletType:kFirstBossNormalIntensedBullet
                                                    andVelocity:velocity
                                                     fromOrigin:kEnemyJet];
        [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        
        distanceOffset += 2 * [EnemyBullet getDefaultRadiusSize:kFirstBossNormalIntensedBullet] + bulletDistanceOffset;
    }
    
    self.fireCounter = kDefaultFireCounter;
}

#pragma mark - Third Stage Firing
- (void)fireCircleOfBullet {
    // REQUIRES: self != nil
    // EFFECTS: Shoots a circle bullets
    
    self.fireCounter -= 3.0 * self.firingSpeed;
    
    if (self.fireCounter > 0) {
        return;
    }

    CGFloat ninjaBulletSpeed = [[Vector2D vectorFromCGVector:
                                [Bullet getDefaultVelocity:kFirstBossHighIntensedBullet]] length];
    CGFloat fireBulletSpeed = [[Vector2D vectorFromCGVector:
                               [Bullet getDefaultVelocity:kFireEnemyBullet]] length];
    CGFloat defaultBulletSpeed = [[Vector2D vectorFromCGVector:
                                  [Bullet getDefaultVelocity:kFirstBossNormalIntensedBullet]] length];
    
    BOOL useNinjaBullet = NO;
    BOOL useDefaultBullet = NO;
    CGFloat rotateAngleOffset = 30;
    if (arc4random() % 3 == 0) {
        useDefaultBullet = YES;
        rotateAngleOffset = 15;
    } else if(arc4random() % 3 == 1){
        useNinjaBullet = YES;
        rotateAngleOffset = 30;
    }
    
    CGFloat distanceOffset = 20;
    Vector2D * horizonDirection = [Vector2D vectorWithX:1 andY:0];
    Vector2D * positionOffset = [Vector2D vectorWithX:self.radius / 2 + distanceOffset
                                                 andY:0];
    CGFloat currentRotateAngle = 0;
    if (useNinjaBullet || useDefaultBullet) {
        currentRotateAngle += rotateAngleOffset;
    }
    
    while (currentRotateAngle < 360) {
        Vector2D * firingDirection = [horizonDirection rotateWithAngle:currentRotateAngle];
        Vector2D * newPositionOffset = [positionOffset rotateWithAngle:currentRotateAngle];
        CGPoint firingPosition = CGPointMake(self.position.x + newPositionOffset.x,
                                             self.position.y + newPositionOffset.y);
        
        if (useNinjaBullet) {
            CGVector velocity = [[firingDirection scalarMultiply:ninjaBulletSpeed] toCGVector];
            Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                      andBulletType:kFirstBossHighIntensedBullet                                                        andVelocity:velocity
                                                         fromOrigin:kEnemyJet];
            [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        } else if(useDefaultBullet){
            // Bonus a default bullet
            firingDirection = [firingDirection rotateWithAngle:rotateAngleOffset / 2.0];
            newPositionOffset = [newPositionOffset rotateWithAngle:rotateAngleOffset / 2.0];
            firingPosition = CGPointMake(self.position.x + newPositionOffset.x,
                                         self.position.y + newPositionOffset.y);
            CGVector velocity = [[firingDirection scalarMultiply:defaultBulletSpeed] toCGVector];
            Bullet *bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                             andBulletType:kFirstBossNormalIntensedBullet
                                               andVelocity:velocity
                                                fromOrigin:kEnemyJet];
            [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        } else {
            CGVector velocity = [[firingDirection scalarMultiply:fireBulletSpeed] toCGVector];
            Bullet * bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                      andBulletType:kFireEnemyBullet
                                                        andVelocity:velocity
                                                         fromOrigin:kEnemyJet];
            [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        }
        
        currentRotateAngle += rotateAngleOffset;
    }
    
    self.fireCounter = kDefaultFireCounter;
}

+ (float)scoreGain {
    // EFFECTS: Return the score gained when the boss is killed
    return kScore;
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet

    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:kFirstBossAtlas];
    sDefaultTexture = [atlas textureNamed:kFirstBossDefaultTexture];
    sDeadTexture = [atlas textureNamed:kFirstBossDeadTexture];
    sFrozenTexture = [atlas textureNamed:kFirstBossFrozenTexture];
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sFrozenTexture = nil;
    sDefaultTexture = nil;
}

static SKTexture *sDefaultTexture = nil;
+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Get the shared default texture
    
    return sDefaultTexture;
}

static SKTexture *sDeadTexture = nil;
+ (SKTexture*)sDeadTexture {
    // EFFECTS: Get the shared default texture when the jet first boss dying
    
    return sDeadTexture;
}

static SKTexture *sFrozenTexture = nil;
+(SKTexture *)sFrozenTexture {
    // EFFECTS: Get the shared frozen texture for the first boss
    
    return sFrozenTexture;
}

@end
