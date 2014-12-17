#import "FourthBoss.h"
#import "Vector2D.h"
#import "PlayScene.h"

#define kHealth 14000.0
#define kHorizontalVelocity 200.0
#define kRadius 200

#define kSlowFactor 3.0
#define kNumberNeededFrozenBullet 100
#define kNumberNeededWindBullet 100000
#define kFireDamage 8

#define kXRatioBossCenterToEye 0.2
#define kYRatioBossCenterToEye 0.2

#define kFiringSpeed 30.0
#define kDefaultFireCounter 500.0

#define kSpeedToScatterShockBullet 15.0

#define kThresholdState2 11000.0f
#define kThresholdState3 7000.0f

#define kFourthBossAtlas @"boss4"
#define kFourthBossDefaultTexture @"boss4"
#define kFourthBossFrozenTexture @"boss4-frozen"
#define kFourthBossDeadTexture @"boss4-dead"

#define kScore 1500

@interface FourthBoss()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;
@property (nonatomic) CGFloat secondFiringSpeed;
@property (nonatomic) CGFloat thirdFiringSpeed;

@end

@implementation FourthBoss {
    CGFloat fireCounter;
    CGFloat secondFireCounter;
    CGFloat thirdFireCounter;
    CGFloat scatterFireCounter;
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
        secondFireCounter = kDefaultFireCounter;
        thirdFireCounter = kDefaultFireCounter;
        scatterFireCounter = kDefaultFireCounter;
        
        self.firingSpeed = kFiringSpeed;
        self.secondFiringSpeed = kFiringSpeed;
        self.thirdFiringSpeed = kFiringSpeed;
        self.originalFiringSpeed = kFiringSpeed;
    }
    return self;
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition{
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint
    
    if (self.currentState == STATE_DEATH){
        return;
    }
    
    [self scatterShockBullets];
    
    if (self.health < kThresholdState3) {
        [self fireBossTears];
        [self fireTricklePursueWithHint:hasHint
                  andPlayerPositionHint:playerPosition];
        [self fireLooseFireworkCircle];
    } else if (self.health < kThresholdState2) {
        [self fireIntensedFireworkCircle];
    } else {
        [self fireFireworkWithRandomDirection];
        [self fireSelfMultipliedPursueWithHint:hasHint
                         andPlayerPositionHint:playerPosition];
    }
}

- (void)scatterShockBullets {
    // REQUIRES: self != nil
    // EFFECTS: scatter the shock bullets with random directions
    
    scatterFireCounter -= kSpeedToScatterShockBullet;
    
    if (scatterFireCounter > 0){
        return;
    }
    
    BulletType bulletType = kShockEnemyBullet;
    Vector2D * defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    
    CGFloat angleShift = arc4random() % 360;
    
    int numFirePoints = 4;
    CGFloat angleIncrement = 360 / numFirePoints;
    for (int i = 0; i < numFirePoints; i++) {
        CGFloat rotateAngle = angleShift + i * angleIncrement;
        Vector2D * velocity = [defaultVelocity rotateWithAngle:rotateAngle];
        
        Vector2D * unitDirection = [velocity normalize];
        CGPoint firingPosition = [[unitDirection scalarMultiply:self.radius] applyVectorTranslationToPoint:self.position];
        [self fireBulletWithType:bulletType
                      atPosition:firingPosition
                    withVelocity:[velocity toCGVector]];
    }
    
    scatterFireCounter = kDefaultFireCounter;
}

#pragma mark - First Stage Firing
- (void)fireFireworkWithRandomDirection {
    // REQUIRES: self != nil
    // EFFECTS: Fire a bullet with random direction and schedule it to self-multiply
    
    secondFireCounter -= self.secondFiringSpeed;
    
    if (secondFireCounter > 0) {
        return;
    }
    
    BulletType bulletType = kFourthBossExtremeIntensedBullet;
    Vector2D * defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    
    CGFloat randomAngle = arc4random() % 360;
    
    Vector2D * velocity = [defaultVelocity rotateWithAngle:randomAngle];
    Vector2D * unitDirection = [velocity normalize];
    CGPoint firingPosition = [[unitDirection scalarMultiply:self.radius]
                              applyVectorTranslationToPoint:self.position];
    
    Bullet * bullet = [self fireBulletWithType:bulletType
                                    atPosition:firingPosition
                                  withVelocity:[velocity toCGVector]];
    
    [self scheduleSelfMultiplyOnBullet:bullet
                                atTime:0.5
                           numMultiply:8];
    
    secondFireCounter = kDefaultFireCounter;
}

- (void)fireSelfMultipliedPursueWithHint:(BOOL)hasHint
                   andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Fire a bullet aimed at player jet and schedule it to self-multiply. Player position is provided as a hint
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    BulletType bulletType = kFourthBossHighIntensedBullet;
    Vector2D * defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    CGFloat speed = [defaultVelocity length];
    
    Vector2D * unitPursueDirection = [self findUnitPursueDirectionFromPosition:self.position
                                                                      withHint:hasHint
                                                         andPlayerPositionHint:playerPosition];
    Vector2D * velocity = [unitPursueDirection scalarMultiply:speed];
    
    CGPoint firingPosition = [[unitPursueDirection scalarMultiply:self.radius]
                              applyVectorTranslationToPoint:self.position];
    Bullet * bullet = [self fireBulletWithType:bulletType
                                    atPosition:firingPosition
                                  withVelocity:[velocity toCGVector]
                              needRotateBullet:YES];
    
    [self scheduleSelfMultiplyOnBullet:bullet atTime:0.17 numMultiply:5];
    
    fireCounter = kDefaultFireCounter;
}

- (void)scheduleSelfMultiplyOnBullet:(Bullet*)bullet
                              atTime:(CGFloat)duration
                         numMultiply:(int)numMultiply {
    // REQUIRES: self != nil, bullet != nil, duration > 0, numMultiply > 0
    // EFFECTS: schedule self-multiply action for an input bullet with input delay duration and number of multiply
    
    SKAction * waitAction = [SKAction waitForDuration:duration];
    SKAction * multiplyAction = [SKAction runBlock:^{
        [self fireCircleOfBulletAtPosition:bullet.position
                            withBulletType:bullet.bulletType
                                  numLines:numMultiply];
    }];
    
    SKAction * sequence = [SKAction sequence:@[waitAction, multiplyAction]];
    [bullet runAction:sequence];
}

- (void)fireCircleOfBulletAtPosition:(CGPoint)firingPosition
                      withBulletType:(BulletType)bulletType
                            numLines:(CGFloat)numLines {
    // REQUIRES: self != nil, firingPosition is in the coordinate system of self, numLines > 0
    // EFFECTS: fire a circle of bullet of type bulletType and number of firing line numLines
    
    CGFloat angleIncrement = 360 / numLines;
    
    Vector2D* velocityVector = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    
    for (int i = 0; i < numLines; i++) {
        CGFloat angle = i * angleIncrement;
        Vector2D * rotatedVector = [velocityVector rotateWithAngle:angle];
        
        [self fireBulletWithType:bulletType
                      atPosition:firingPosition
                    withVelocity:[rotatedVector toCGVector]
                needRotateBullet:YES];
    }
}

#pragma mark - Second Stage Firing
- (void)fireIntensedFireworkCircle {
    // REQUIRES: self != nil
    // EFFECTS: fire a circle of dense circles of bullet
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    [self fireFireworkCircleWithNumFireOrigins:5 andNumLinesPerCircle:16];
    
    fireCounter = kDefaultFireCounter;
}

#pragma mark - Third Stage Firing
- (void)fireBossTears {
    // REQUIRES: self != nil
    // EFFECTS: fire 2 rows of bullets from boss eyes
    
    secondFireCounter -= self.secondFiringSpeed;
    
    if (secondFireCounter > 0) {
        return;
    }
    
    CGFloat bulletType = kFourthBossNormalIntensedBullet;
    
    CGFloat xDistanceToEye = self.radius * kXRatioBossCenterToEye;
    CGFloat yDistanceToEye = self.radius * kYRatioBossCenterToEye;
    
    for (int j  = -1; j < 2; j+=2) {
        CGFloat dxFromCenter = j * xDistanceToEye;
        CGFloat dyFromCenter = yDistanceToEye;
        CGPoint firingPosition = CGPointMake(self.position.x + dxFromCenter,
                                            self.position.y + dyFromCenter);
            
        Bullet * bullet = [self fireBulletWithType:bulletType atPosition:firingPosition];
        bullet.zPosition = self.zPosition + 1;
    }
    
    secondFireCounter = kDefaultFireCounter;
}

- (void)fireTricklePursueWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition{
    // REQUIRES: self != nil
    // EFFECTS: fire a circle of bullet aiming toward player jet, forming a trickle shape
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0){
        return;
    }
    
    BulletType bulletType = kFourthBossUltimateIntensedBullet;
    Vector2D* defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    CGFloat bulletSpeed = [defaultVelocity length];
    
    CGFloat trickleRadius = 160;
    
    Vector2D* unitPursueDirectionFromCenter = [self findUnitPursueDirectionFromPosition:self.position
                                                                     withHint:hasHint
                                                        andPlayerPositionHint:playerPosition];
    CGPoint trickleCenter = [[unitPursueDirectionFromCenter scalarMultiply:self.radius] applyVectorTranslationToPoint:self.position];
    
    int numFirePoints = 16;
    CGFloat angleIncrement = 360 / numFirePoints;
    for (int i = 0; i < numFirePoints; i++){
        CGFloat rotateAngle = i * angleIncrement;
        Vector2D* unitVerticalVector = [Vector2D vectorWithX:0.0 andY:1.0];
        Vector2D* directionVector = [unitVerticalVector rotateWithAngle:rotateAngle];
        
        CGPoint firingPoisition = [[directionVector scalarMultiply:trickleRadius] applyVectorTranslationToPoint:trickleCenter];
        Vector2D* unitPursueDirectionFromFiringPosition = [self findUnitPursueDirectionFromPosition:firingPoisition
                                                                                           withHint:hasHint andPlayerPositionHint:playerPosition];
        Vector2D* velocity = [unitPursueDirectionFromFiringPosition scalarMultiply:bulletSpeed];
        [self fireBulletWithType:bulletType
                      atPosition:firingPoisition
                    withVelocity:[velocity toCGVector]];
    }
    
    fireCounter = kDefaultFireCounter;
}

- (void)fireLooseFireworkCircle{
    // REQUIRES: self != nil
    // EFFECTS: fire a circle of sparse circles of bullet
    
    thirdFireCounter -= self.thirdFiringSpeed;
    
    if (thirdFireCounter > 0){
        return;
    }
    
    [self fireFireworkCircleWithNumFireOrigins:3
                          andNumLinesPerCircle:12];
    
    thirdFireCounter = kDefaultFireCounter;
}

#pragma mark - Update Firing Speed
- (void)update {
    // REQUIRES: self != nil
    // MODIFIES: self firing speeds
    // EFFECTS: update firing speed according to the current stage of the boss, defined by remaining health
    
    [super update];
    if(self.health > kThresholdState2) {
        self.firingSpeed = 5.0;
        self.secondFiringSpeed = 7.0;
    } else if(self.health > kThresholdState3) {
        self.firingSpeed = 5.0;
    } else {
        self.firingSpeed = 5.0;
        self.secondFiringSpeed = 20.0;
        self.thirdFiringSpeed = 8.0;
    }
}

#pragma mark - Helper Firing Functions
- (void)fireFireworkCircleWithNumFireOrigins:(int)numFireOrigins andNumLinesPerCircle:(int)numLines{
    // REQUIRES: self != nil
    // EFFECTS: fire a circle of smaller circles of bullet with number of small circles and number of fires per small circle
    
    BulletType bulletType = kFourthBossExtremeIntensedBullet;
    Vector2D * defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
    
    CGFloat angleIncrement = 360 / numFireOrigins;
    
    for (int i = 0; i < numFireOrigins; i++) {
        CGFloat rotateAngle = angleIncrement * i;
        
        Vector2D * velocity = [defaultVelocity rotateWithAngle:rotateAngle];
        Vector2D * unitDirection = [velocity normalize];
        CGPoint firingPosition = [[unitDirection scalarMultiply:self.radius] applyVectorTranslationToPoint:self.position];
        
        [self fireCircleOfBulletAtPosition:firingPosition
                            withBulletType:bulletType
                                  numLines:numLines];
    }
}

- (Vector2D *)findUnitPursueDirectionFromPosition:(CGPoint)startPosition
                                         withHint:(BOOL)hasHint
                            andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, startPosition and playerPosition is in the coordinate system of self
    // EFFECTS: find the unit pursue direction from startPosition toward playerPosition
    // RETURNS: unit pursue direction
    
    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                           fromNode:self];
    Vector2D * unitVerticalVector = [Vector2D vectorWithX:0 andY:-1];
    Vector2D * unitPursueDirection = unitVerticalVector;
    
    if (hasHint) {
        CGPoint startWorldPoint = [[self gameObjectScene] convertPoint:startPosition
                                                              fromNode:self.parent];
        
        unitPursueDirection = [[Vector2D vectorFromPoint:startWorldPoint toPoint:playerWorldPoint] normalize];
    }
    
    return unitPursueDirection;
}

- (Bullet *)fireBulletWithType:(BulletType)bulletType
                    atPosition:(CGPoint)position {
    // REQUIRES: self != nil, position is in the coordinate system of self
    // EFFECTS: fire a bullet with bullet type and firing position
    // RETURNS: the bullet fired
    
    CGVector velocity = [Bullet getDefaultVelocity:bulletType];
    return [self fireBulletWithType:bulletType
                         atPosition:position
                       withVelocity:velocity];
}

- (Bullet *)fireBulletWithType:(BulletType)bulletType
                    atPosition:(CGPoint)position
                  withVelocity:(CGVector)velocity {
    // REQUIRES: self != nil, position is in the coordinate system of self
    // EFFECTS: fire a bullet with bullet type and firing position and bullet velocity
    // RETURNS: the bullet fired

    Bullet * bullet = [[EnemyBullet alloc] initWithPosition:position
                                              andBulletType:bulletType
                                                andVelocity:velocity
                                                 fromOrigin:kEnemyJet];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
    return bullet;
}

- (Bullet *)fireBulletWithType:(BulletType)bulletType
                    atPosition:(CGPoint)position
                  withVelocity:(CGVector) velocity
              needRotateBullet:(BOOL)needRotateBullet {
    // REQUIRES: self != nil, position is in the coordinate system of self
    // EFFECTS: fire a bullet with bullet type and firing position and bullet velocity
    //          and rotate the bullet to the firing direction if needRotateBullet is YES
    // RETURNS: the bullet fired

    Bullet * bullet = [[EnemyBullet alloc] initWithPosition:position
                                              andBulletType:bulletType
                                                andVelocity:velocity
                                                 fromOrigin:kEnemyJet];
    
    Vector2D * verticalUnitVector = [Vector2D vectorWithX:0 andY:-1];
    CGFloat bulletRotateAngle = [verticalUnitVector angleWithVector:[Vector2D vectorFromCGVector:velocity]];
    
    if (needRotateBullet) {
        if (velocity.dx < 0) {
            bulletRotateAngle = -bulletRotateAngle;
        }
        
        SKAction* rotateAction = [SKAction rotateByAngle:bulletRotateAngle duration:0.0];
        [bullet runAction:rotateAction];
    }
    
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
    return bullet;
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:kFourthBossAtlas];
    sDefaultTexture = [atlas textureNamed:kFourthBossDefaultTexture];
    sDeadTexture = [atlas textureNamed:kFourthBossDeadTexture];
    sFrozenTexture = [atlas textureNamed:kFourthBossFrozenTexture];
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sDefaultTexture = nil;
    sFrozenTexture = nil;
}

static SKTexture * sDefaultTexture = nil;
+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Get the shared default texture
    
    return sDefaultTexture;
}

static SKTexture * sDeadTexture = nil;
+ (SKTexture *)sDeadTexture{
    // EFFECTS: Get the shared default texture when the jet is dying
    
    return sDeadTexture;
}

static SKTexture * sFrozenTexture = nil;
+(SKTexture *)sFrozenTexture {
    // EFFECTS: Get the shared default texture when the jet is frozen
    
    return sFrozenTexture;
}

+ (float)scoreGain {
    // EFFECTS: return the score gain when the boss is killed
    
    return kScore;
}

@end
