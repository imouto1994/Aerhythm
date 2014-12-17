#import "SecondBoss.h"
#import "Vector2D.h"
#import "PlayScene.h"
#import "Constant.h"

#define kHealth 13000.0f
#define kHorizontalVelocity 150.0f
#define kSlowFactor 2.0f
#define kNumberNeededFrozenBullet 100
#define kNumberNeededWindBullet 1000
#define kFireDamage 25
#define kRadius 200

#define kThresholdState2 8000.0f
#define kThresholdState3 4000.0f

#define kFiringSpeed 15.0
#define kDefaultFireCounter 500.0

#define kSecondStateDefaultFireDelayCounter 2200.0
#define kSecondStateNumFirePerFence 6

#define kThirdStateDefaultSpinDelayCounter 2400.0
#define kThirdStateNumSpinToToggleDirection 6
#define kThirdStateAngleIncrementPerSpin 4

#define kScore 500

#define kSecondBossAtlas @"boss2"
#define kSecondBossDefaultTexture @"boss2"
#define kSecondBossFrozenTexture @"boss2-frozen"
#define kSecondBossDeadTexture @"boss2-dead"

@interface SecondBoss()

// The firing speed for the secondary shots
@property (nonatomic) CGFloat secondFiringSpeed;
// The firing speed for the original shots
@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@end

@implementation SecondBoss {
    // Counter for the original shots
    CGFloat fireCounter;
    // Counter for the secondary shots
    CGFloat secondFireCounter;
    // The direction of spinning
    SpinDirection spinDirection;
    // Number of spin fires
    int circleSpinFireCount;
    // Number of fences
    int fenceCount;
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
        self.firingSpeed = kFiringSpeed;
        self.secondFiringSpeed = kFiringSpeed;
        self.originalFiringSpeed = kFiringSpeed;
        
        spinDirection = kClockwiseSpin;
        circleSpinFireCount = 0;
        fenceCount = 0;
    }
    return self;
}

- (void) fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint    
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    if(self.health < kThresholdState3) {
        [self fireCircleOfBulletSpinWithToggleDirection];
    } else if(self.health < kThresholdState2) {
        [self fireFenceWithHint:hasHint
          andPlayerPositionHint:playerPosition];
        [self firePursueIceBulletWithHint:hasHint
                    andPlayerPositionHint:playerPosition];
    } else {
        [self fireIntensePursueWithHint:hasHint
                  andPlayerPositionHint:playerPosition];
        [self fireIceCircle];
    }
}

#pragma mark - First Stage Firing
-(void) fireIntensePursueWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinate system of self
    // EFFECTS: fire dense pursue bullets toward player jet. Player position may be passed as hint
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    int numFirePoints = 6;
    CGFloat xIndent = 10;
    CGFloat xIncrement = (self.radius - xIndent) * 2 / numFirePoints;
    for (int i = 0; i < numFirePoints; i++) {
        CGFloat dx = - (self.radius - xIndent) + i * xIncrement;
        CGFloat dy = - sqrtf(self.radius * self.radius - dx * dx);
        CGPoint firingPosition = CGPointMake(self.position.x + dx, self.position.y + dy);
        
        [self firePursueFromPosition:firingPosition
                      withBulletType:kSecondBossHighIntensedBullet
                            withHint:YES
               andPlayerPositionHint:playerPosition
                    needRotateBullet:YES];
    }
    
    fireCounter = kDefaultFireCounter;
}

- (void)fireIceCircle {
    // REQUIRES: self != nil
    // EFFECTS: fire a circle of ice bullets
    
    secondFireCounter -= self.secondFiringSpeed;
   
    if (secondFireCounter > 0){
        return;
    }

    int numFirePoints = 8;
    CGFloat angleIncrement = 360 / numFirePoints;
    BulletType bulletType = kIceEnemyBullet;
    
    Vector2D * velocityVector = [Vector2D vectorWithX:0 andY:-400.0];
    
    for (int i = 0; i < numFirePoints; i++) {
        CGFloat angle = i * angleIncrement;
        Vector2D* rotatedVector = [velocityVector rotateWithAngle:angle];
       
        Vector2D* translationVector = [[rotatedVector normalize] scalarMultiply:self.radius];
        CGPoint firingPosition = [translationVector applyVectorTranslationToPoint:self.position];
        
        [self fireBulletWithType:bulletType
                      atPosition:firingPosition
                    withVelocity:[rotatedVector toCGVector]];
    }
    
    secondFireCounter = kDefaultFireCounter;
}

#pragma mark - Second Stage Firing
- (void)fireFenceWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinate system of self
    // EFFECTS: fire one bullet aiming toward player jet. The pursue bullets of continous firing will form a strip
    //          playerPosition maybe passed as hint
    
    secondFireCounter -= self.secondFiringSpeed;
    
    if (secondFireCounter > 0) {
        return;
    }

    BulletType bulletType = kSecondBossExtremeIntensedBullet;
   
    int numFirePoints = 2;
    CGFloat xIndent = 10;
    CGFloat xIncrement = (self.radius - xIndent) * 2 / numFirePoints;
    
    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                           fromNode:self];
    CGFloat verticalOffsetFromTargetToPlayer = 100.0;
    
    for (int i = 0; i < numFirePoints; i++) {
        CGFloat dx = - (self.radius - xIndent) + i * xIncrement;
        CGFloat dy = - sqrtf(self.radius * self.radius - dx * dx);
        CGPoint firingPosition = CGPointMake(self.position.x + dx, self.position.y + dy);
        
        CGPoint firingWorldPoint = [[self gameObjectScene] convertPoint:firingPosition
                                                               fromNode:self.parent];
        
        CGFloat verticalOffsetToPlayer = abs(firingWorldPoint.y - playerWorldPoint.y);
        CGPoint fireTarget = playerPosition;
        
        if (verticalOffsetFromTargetToPlayer < verticalOffsetToPlayer){
            fireTarget = CGPointMake(playerPosition.x, playerPosition.y + verticalOffsetFromTargetToPlayer);
        }
        
        [self firePursueFromPosition:firingPosition
                      withBulletType:bulletType
                            withHint:hasHint
               andPlayerPositionHint:fireTarget
                    needRotateBullet:NO];
    }
    
    secondFireCounter = kDefaultFireCounter;
    fenceCount++;
    if (fenceCount == kSecondStateNumFirePerFence){
        secondFireCounter = kDefaultFireCounter + kSecondStateDefaultFireDelayCounter;
        fenceCount = 0;
    }
}

-(void) firePursueIceBulletWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition{
    // REQUIRES: self != nil, playerPosition is in the coordinate system of self
    // EFFECTS: fire an ice bullet aiming toward player jet. Player position may be passed as hint
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0){
        return;
    }
    
    [self firePursueFromPosition:self.position
                  withBulletType:kIceEnemyBullet
                        withHint:YES
           andPlayerPositionHint:playerPosition
                needRotateBullet:NO];
    
    fireCounter = kDefaultFireCounter;
}

#pragma mark - Third Stage Firing
- (void)fireCircleOfBulletSpinWithToggleDirection {
    // REQUIRES: self != nil
    // EFFECTS: fire a spinning circle of bullet with direction toggled after a pre-defined number of firing
    
    fireCounter -= self.firingSpeed;
    
    if (fireCounter > 0) {
        return;
    }
    
    BulletType bulletType = [self determineBulletTypeOfFireSpin];
    Vector2D * velocityVector = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:bulletType]];
 
    int numBulletFire = 4;
    CGFloat angleIncrement = 360 / numBulletFire;

    for (int i = 0; i < numBulletFire; i++) {
        CGFloat rotateAngle = circleSpinFireCount * kThirdStateAngleIncrementPerSpin * spinDirection + i * angleIncrement;
        
        velocityVector = [velocityVector rotateWithAngle:rotateAngle];
        
        Vector2D * unitDirection = [velocityVector normalize];
        CGPoint firingPosition = [[unitDirection scalarMultiply:self.radius]
                                  applyVectorTranslationToPoint:self.position];
        
        [self fireBulletWithType:bulletType
                      atPosition:firingPosition
                    withVelocity:[velocityVector toCGVector]];
    }
    
    circleSpinFireCount++;
    fireCounter = kDefaultFireCounter;
    
    if (circleSpinFireCount >= kThirdStateNumSpinToToggleDirection) {
        spinDirection = -spinDirection;
        circleSpinFireCount = 0;
        fireCounter = kDefaultFireCounter + kThirdStateDefaultSpinDelayCounter;
    }
}

- (BulletType)determineBulletTypeOfFireSpin {
    // EFFECTS: determine the bullet type based on the spinning direction
    // RETURN: the bullet type for for the current spinning circle
    
    if (spinDirection == kClockwiseSpin) {
        return kSecondBossNormalIntensedBullet;
    }
    return kSecondBossExtremeIntensedBullet;
}

#pragma mark - Update Firing Speed
- (void)update {
    // REQUIRES: self != nil
    // MODIFIES: self firing speeds and physics body
    // EFFECTS: update firing speed according to the current stage of the boss, defined by remaining health
    
    [super update];
    if (self.health > kThresholdState2) {
        self.firingSpeed = 12.0;
        self.secondFiringSpeed = 7.0;
    } else if (self.health > kThresholdState3) {
        self.firingSpeed = 10.0;
        self.secondFiringSpeed = 50.0;
    } else {
        if (!self.isFrozen) {
            self.physicsBody.angularVelocity = 2;
        }
        self.firingSpeed = 200.0;
    }
}

#pragma mark - Helper Firing Functions
- (Bullet*)firePursueFromPosition:(CGPoint)firingPosition
                   withBulletType:(BulletType)bulletType
                         withHint:(BOOL)hasHint
            andPlayerPositionHint:(CGPoint)playerPosition
                 needRotateBullet:(BOOL)needRotateBullet {
    // REQUIRES: self != nil, firingPosition and playerPosition is in coordinate system of self
    // EFFECTS: fire a bullet aiming to player jet with firing position, bullet type and player position passed in as hint
    //          rotate bullet toward firing direction if needRotateBullet is set to YES
    // RETURNS: the bullet fired
    
    CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                           fromNode:self];
    CGVector velocity = [Bullet getDefaultVelocity:bulletType];
    
    if (hasHint) {
        CGPoint firingWorldPoint = [[self gameObjectScene] convertPoint:firingPosition
                                                               fromNode:self.parent];
        
        Vector2D* fireDirectionVector = [[Vector2D vectorFromPoint:firingWorldPoint toPoint:playerWorldPoint] normalize];
        CGFloat speed = [[Vector2D vectorFromCGVector:velocity] length];
        velocity = [[fireDirectionVector scalarMultiply:speed] toCGVector];
    }
    
    Bullet * bullet = [self fireBulletWithType:bulletType
                                    atPosition:firingPosition
                                  withVelocity:velocity
                              needRotateBullet:needRotateBullet];
    
    return bullet;
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

- (Bullet*)fireBulletWithType:(BulletType)bulletType
                   atPosition:(CGPoint)position
                 withVelocity:(CGVector)velocity
             needRotateBullet:(BOOL)needRotateBullet{
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
    
        SKAction * rotateAction = [SKAction rotateByAngle:bulletRotateAngle duration:0.0];
        [bullet runAction:rotateAction];
    }
    
    [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
    return bullet;
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:kSecondBossAtlas];
    sDefaultTexture = [atlas textureNamed:kSecondBossDefaultTexture];
    sDeadTexture = [atlas textureNamed:kSecondBossDeadTexture];
    sFrozenTexture = [atlas textureNamed:kSecondBossFrozenTexture];
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
+ (SKTexture*)sDeadTexture {
    // EFFECTS: Get the shared default texture when the second boss is dying
    
    return sDeadTexture;
}

static SKTexture * sFrozenTexture = nil;
+ (SKTexture *)sFrozenTexture {
    // EFFECTS: Get the shared texture when the second boss is frozen
    
    return sFrozenTexture;
}

+ (float)scoreGain {
    // EFFECTS: Return the score gained when the second boss is killed
    
    return kScore;
}

@end
