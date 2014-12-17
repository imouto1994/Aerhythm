#import "EnemyJet.h"
#import "Utilities.h"
#import "Powerup.h"
#import "PlayScene.h"
#import "PlayerBullet.h"
#import "SuicideEnemy.h"
#import "BossEnemy.h"

#define kHealerPowerupProbability 0.035
#define kShieldPowerupProbability 0.015
#define kDoubleFirePowerupProbability 0.0375
#define kTripleFirePowerupProbability 0.0375
#define kQuadrupleSpinFirePowerupProbability 0.0275
#define kPursueFirePowerupProbability 0.025
#define kConfuseFirePowerupProbability 0.015
#define kDestructionPowerupProbability 0.0075

#define kDefaultFireCounter 500.0

#define kFrozenEffect @"frozen-effect"
#define kSlowEffect @"slow-effect"
#define kFireEffect @"fire-effect"
#define kWindEffect @"wind-effect"
#define kShockEffect @"shock-effect"
#define kSlowFiringSpeedEffect @"slow-firing-speed-effect"


@interface EnemyJet()

// The radius of the body of the jet
@property (nonatomic, readwrite) CGFloat radius;

// The damage of the bullet
@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

// Indicator of special effects
@property (nonatomic, readwrite) BOOL isSlowed;
@property (nonatomic, readwrite) BOOL isFrozen;
@property (nonatomic, readwrite) BOOL isFired;
@property (nonatomic, readwrite) BOOL isPushed;

@end

@implementation EnemyJet {
    // Number of consecutive frozen bullets hit
    int frozenBulletCount;
    
    // Number of consecutive wind bullets hit
    int windBulletCount;
    
    // Previous velocity to reset after being unfrozen
    CGVector previousVelocity;
    
    // Indicator whether the powerup should be generated when this enemy jet is dead or not
    BOOL shouldGeneratePowerup;
}


#pragma mark - Initalization
- (id)initAtPosition:(CGPoint)position withRadius:(CGFloat)radius {
    return [self initAtPosition:position withRadius:radius enableFire:YES];
}

- (id)initAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire {
    return [self initAtPosition:position withRadius:0.0 enableFire:isEnableFire];
}

- (id)initAtPosition:(CGPoint)position withRadius:(CGFloat)radius enableFire:(BOOL)isEnableFire {
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position and radius
    
    self = [super initWithTexture:[self.class sDefaultTexture]];
    if (self) {
        self.position = position;
        self.name = @"enemy";
        _radius = radius;
        self.size = CGSizeMake(_radius * 2, _radius * 2);
        _isAbleToFire = isEnableFire;
        [self configurePhysicsBody];
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // MODIFIES: self
    // EFFECTS: Setup the game object when it is first initialized
    
    _fireCounter = kDefaultFireCounter;
    _isSlowed = false;
    _isFrozen = false;
    frozenBulletCount = 0;
    _isFired = false;
    _isPushed = false;
    _mobile = true;
    windBulletCount = 0;
    _isImmuneToBullet = false;
    shouldGeneratePowerup = false;
}

- (void)configurePhysicsBody {
    // MODIFIES: self
    // EFFECTS: Setup the game object when it is first initialized
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: _radius - _radius / 3.0];
    self.physicsBody.categoryBitMask = kEnemyJet;
    self.physicsBody.collisionBitMask = kEnemyJet | kPlayerJet | kWallLeft | kWallRight | kWallTop;
    self.physicsBody.restitution = 1;
    self.physicsBody.friction = 0;
    self.physicsBody.linearDamping = 0;
    self.physicsBody.angularDamping = 0;
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.contactTestBitMask = kPlayerBullet;
}


#pragma mark - Power-up Generation
- (void)generatePowerups {
    // EFFECTS: randomly generate power-ups
    for (int i = 0; i < kPowerupTypeCount; i++) {
        if (i != kRevivalPowerup) {
            [self generatePowerupWithType:i];
        }
    }
}

- (void)generatePowerupsOfTypes:(NSArray*)typeArray {
    for (NSNumber* type in typeArray) {
        [self generatePowerupWithType:type.unsignedIntegerValue];
    }
}

- (void)generatePowerupWithType:(PowerupType)type {
    // EFFECTS: generate a power-up with given type and probability
    float probability = [self getProbabilityOfPowerupType:type];
    
    double randomNumber = arc4random() % 1000 / 1000.0;
    if (randomNumber < probability) {
        CGPoint position = self.position;
        Powerup *powerup = [Powerup powerupAtPosition:position withType:type];
        [[self gameObjectScene] addNode:powerup atWorldLayer:kEnemyLayer];
        powerup.position = position;
    }
}

- (float)getProbabilityOfPowerupType:(PowerupType)powerupType {
    // EFFECTS: return the generation probability for a given powerup type
    
    switch (powerupType) {
        case kHealerPowerup:
            return kHealerPowerupProbability;
            break;
        case kShieldPowerup:
            return kShieldPowerupProbability;
            break;
        case kDoubleFirePowerup:
            return kDoubleFirePowerupProbability;
            break;
        case kTripleFirePowerup:
            return kTripleFirePowerupProbability;
            break;
        case kQuadrupleFirePowerup:
            return kQuadrupleSpinFirePowerupProbability;
            break;
        case kPursuePowerup:
            return kPursueFirePowerupProbability;
            break;
        case kConfusePowerup:
            return kConfuseFirePowerupProbability;
            break;
        case kDestructionPowerup:
            return kDestructionPowerupProbability;
            break;
        default:
            break;
    }
    
    return 0.0;
}


#pragma mark - Effect Handler
- (void)hitByBullet:(Bullet *)bullet {
    // MODIFIES: self
    // EFFECTS: Handling method when the enemy jet is hit by the bullet
    
    [self handleSpecialEffectsByBullet:bullet];
    [self applyDamage:bullet.damage];
}

- (void)handleSpecialEffectsByBullet:(Bullet *)bullet {
    //MODIFIES: self
    // EFFECTS: Handling special effects when the enemy jet is hit by the bullet
    
    if (bullet.bulletType == kPlayerBullet1) {
        frozenBulletCount++;
    } else {
        frozenBulletCount = 0;
    }
    
    if (bullet.bulletType == kPlayerBullet4) {
        windBulletCount++;
    } else {
        windBulletCount = 0;
    }
    
    switch (bullet.bulletType) {
        case kPlayerBullet1:
            [self handleEffectOfPlayerBullet1];
            break;
        case kPlayerBullet2:
            [self handleEffectOfPlayerBullet2];
            break;
        case kPlayerBullet3:
            [self handleEffectOfPlayerBullet3];
            break;
        case kPlayerBullet4:
            [self handleEffectOfPlayerBullet4];
            break;
        case kPlayerBullet5:
            [self handleEffectOfPlayerBullet5];
            break;
        case kPlayerBullet6:
            [self handleEffectOfPlayerBullet6];
            break;
        case kPlayerBullet7:
            [self handleEffectOfPlayerBullet7];
            break;
        case kFireEnemyBullet:
            [self handleEffectOfFireEnemyBullet];
            break;
        case kIceEnemyBullet:
            [self handleEffectOfIceEnemyBullet];
            break;
        case kShockEnemyBullet:
            [self handleEffectOfShockEnemyBullet];
            break;
        default:
            break;
    }
}

- (void)handleEffectOfPlayerBullet1 {
    // EFFECTS: Handling effect when being hit by frozen bullet
    
    if (frozenBulletCount >= numberNeededFrozenBullet) {
        SKAction *action = [self frozenEffectAction];
        [self runAction:action withKey:kFrozenEffect];
    }
}

- (void)handleEffectOfPlayerBullet2 {
    // // EFFECTS: Handling effect when being hit by slow bullet
    
    if (_isFrozen) {
        return;
    }
    
    SKAction* slowEffectAction = [self slowEffectAction];
    [self runAction:slowEffectAction withKey:kSlowEffect];
}

- (void)handleEffectOfPlayerBullet3 {
    // // EFFECTS: Handling effect when being hit by hollow bullet
}

- (void)handleEffectOfPlayerBullet4 {
    // // EFFECTS: Handling effect when being hit by wind bullet
    
    if (windBulletCount >= numberNeededWindBullet && !_isPushed) {
        double distanceToPush = self.position.y + self.size.height + 500.0;
        SKAction * positionAction = [SKAction moveByX:0.0 y:distanceToPush duration:distanceToPush / 300.0];
        SKAction * flagAction = [SKAction waitForDuration:4.0];
        SKAction * sequence = [SKAction sequence:@[positionAction, flagAction]];
        
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsBody.categoryBitMask = 0;
        self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        
        [self runAction:sequence withKey:kWindEffect];
    }
}

- (void)handleEffectOfPlayerBullet5 {
    // // EFFECTS: Handling effect when being hit by lightning bullet
}

- (void)handleEffectOfPlayerBullet6 {
    // // EFFECTS: Handling effect when being hit by fire bullet
    
    SKAction* flagAction = [self fireEffectAction];
    [self runAction:flagAction withKey:kFireEffect];
}

- (void)handleEffectOfPlayerBullet7 {
    // // EFFECTS: Handling effect when being hit by bomb bullet
}

- (void)handleEffectOfFireEnemyBullet {
    // // EFFECTS: Handling effect when being hit by enemy fire bullet
    
    SKAction *flagAction = [self fireEnemyBulletEffectAction];
    [self runAction:flagAction withKey:kFireEffect];
}

- (void)handleEffectOfIceEnemyBullet {
    // // EFFECTS: Handling effect when being hit by enemy ice bullet
    
    SKAction *action = [self iceEnemyBulletEffectAction];
    [self runAction:action withKey:kSlowFiringSpeedEffect ];
}

- (void)handleEffectOfShockEnemyBullet {
    // // EFFECTS: Handling effect when being hit by enemy shock bullet
    
    SKAction *flagAction = [self shockEnemyBulletEffectAction];
    [self runAction:flagAction withKey:kShockEffect];
}


#pragma mark - Fire
- (void)fire {
    // REQUIRES: self != nil
    // EFFECTS: Handling method when the jet fires the bullets
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    if (!self.isAbleToFire) {
        return;
    }

    self.fireCounter -= self.firingSpeed;
    if(self.fireCounter  < 0) {
        CGPoint firingPosition = CGPointMake(self.position.x, self.position.y - _radius);
        CGVector velocity = [Bullet getDefaultVelocity:_bulletType];
        Bullet *bullet = [[EnemyBullet alloc] initWithPosition:firingPosition
                                                 andBulletType:_bulletType
                                                   andVelocity:velocity
                                                    fromOrigin:kEnemyJet];
        [[self gameObjectScene] addNode:bullet atWorldLayer:kEnemyLayer];
        self.fireCounter = kDefaultFireCounter;
    }
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint
    
    // Default behavior
    // It should be overridden by subclasses
    [self fire];
}

- (void)setIsAbleToFire:(BOOL)isEnableFire {
    // MODIFIES: self
    // EFFECTS: set the jet to be unable/able to fire
    if(_isAbleToFire && !isEnableFire){
        _isAbleToFire = isEnableFire;
        SKSpriteNode * silenceNode = [[SKSpriteNode alloc] initWithTexture:[self silenceTexture]];
        silenceNode.size = CGSizeMake(50, 50);
        silenceNode.position = CGPointMake(0, self.radius);
        [self addChild:silenceNode];
    }
    
    if(!_isAbleToFire && isEnableFire){
        _isAbleToFire = isEnableFire;
        for(SKNode * node in [self children]){
            if([node isKindOfClass:[SKSpriteNode class]]){
                SKSpriteNode * childSpriteNode = (SKSpriteNode *)node;
                if(childSpriteNode.texture == [self silenceTexture]){
                    [childSpriteNode removeFromParent];
                }
            }
        }
    }
}


#pragma mark - Update
- (void)update {
    // MODIFIES: self
    // EFFECTS: Update the state of the game object, this method is called for each game loop
    
    if(self.hasStateChanged) {
        if(self.currentState == STATE_DEFAULT) {
            self.texture = [self.class sDefaultTexture];
        } else if(self.currentState == STATE_DEATH) {
            self.texture = [self.class sDeadTexture];
        } else if(self.currentState == STATE_FROZEN) {
            self.texture = [self.class sFrozenTexture];
        }
        self.hasStateChanged = NO;
    }
    
    if(shouldGeneratePowerup) {
        [self generatePowerups];
        shouldGeneratePowerup = false;
    }
    
    [self updateSpecialEffects];
}

- (void)updateSpecialEffects {
    // MODIFIES: self
    // EFFECTS: Update the special effects from the bullets on the states of the jet
    
    // Frozen effect
    if ([self actionForKey:kFrozenEffect]) {
        if (!_isFrozen) {
            previousVelocity = self.physicsBody.velocity;
            self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
            
            if (![self isKindOfClass:[BossEnemy class]]) {
                self.firingSpeed = 0.0;
            }
            _isFrozen = true;
            [self setCurrentState:STATE_FROZEN];
            
            [self removeActionForKey:kSlowEffect];
        }
    } else {
        if (_isFrozen) {
            self.physicsBody.velocity = previousVelocity;
            
            if (![self isKindOfClass:[BossEnemy class]]) {
                self.firingSpeed = self.originalFiringSpeed;
            }
                  
            [self setCurrentState:STATE_DEFAULT];
            _isFrozen = false;
        }
    }
    
    // Slow effect
    if ([self actionForKey:kSlowEffect]) {
        if (!_isSlowed) {
            self.physicsBody.velocity = CGVectorMake(self.physicsBody.velocity.dx / slowFactor, self.physicsBody.velocity.dy / slowFactor);
            
            SKEmitterNode* emitter = [[self slowEmitter]copy];
            emitter.particlePositionRange = CGVectorMake(self.frame.size.width, self.frame.size.height);
            [self addChild:emitter];
            
            _isSlowed = true;
        }
    } else {
        if (_isSlowed) {
            self.physicsBody.velocity = CGVectorMake(self.physicsBody.velocity.dx * slowFactor, self.physicsBody.velocity.dy / slowFactor);
            [self removeEmitter:[self slowEmitter]];
            _isSlowed = false;
        }
    }
    
    // Fire effect
    if ([self actionForKey:kFireEffect]) {
        if (!_isFired) {
            SKEmitterNode* emitter = [[self fireEmitter]copy];
            emitter.particlePositionRange = CGVectorMake(self.frame.size.width, self.frame.size.height);
            [self addChild:emitter];
            
            _isFired = true;
        }
    } else {
        if (_isFired) {
            [self removeEmitter:[self fireEmitter]];
            _isFired = false;
        }
    }
    
    // Wind effect
    if ([self actionForKey:kWindEffect]) {
        if (!_isPushed) {
            SKEmitterNode* emitter = [[self windEmitter]copy];
            emitter.position = CGPointMake(0.0, -self.frame.size.height/2);
            emitter.particlePositionRange = CGVectorMake(self.frame.size.width * 1.2, 0.0);
            
            [self addChild:emitter];
            
            _isPushed = true;
        }
    } else {
        if (_isPushed) {
            [self removeEmitter:[self windEmitter]];
            _isPushed = false;
        }
    }
    
    //------Effects caused by reflected enemy bullets-----
    
    // Firing slow effect
    if ([self actionForKey:kSlowFiringSpeedEffect]) {
        if (!_isFiringSpeedSlowed) {
            SKEmitterNode* emitter = [[self slowEmitter]copy];
            emitter.particlePositionRange = CGVectorMake(self.frame.size.width, self.frame.size.height);
            [self addChild:emitter];
            
            self.firingSpeed /= 2.5;
            _isFiringSpeedSlowed = true;
        }
    } else {
        if (_isFiringSpeedSlowed) {
            [self removeEmitter:[self slowEmitter]];
            
            self.firingSpeed *= 2.5;
            _isFiringSpeedSlowed = false;
        }
    }
    
    // Shock effect
    if ([self actionForKey:kShockEffect]) {
        if (!_isShocked) {
            _isShocked = true;
            SKSpriteNode *shockNode = [[SKSpriteNode alloc] initWithTexture:[self shockIconTexture]];
            shockNode.size = CGSizeMake(50, 50);
            shockNode.position = CGPointMake(0, self.radius);
            [self addChild:shockNode];
        }
    } else {
        if (_isShocked) {
            _isShocked = false;
            [self removeChildWithTexture:[self shockIconTexture]];
        }
    }
    
    _mobile = (!_isFrozen && !_isShocked);
}

- (void)updateWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // REQUIRES: self != nil, playerPosition is in the coordinnate system of self
    // EFFECTS: Update the enemy jet's state. Player position may be provided as a hint
    
    // Default behavior
    // It should be overridden by subclasses
    [self update];
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this object's physic body with another object's one
    
    if (other.categoryBitMask & kPlayerBullet) {
        Bullet *bullet = (Bullet *)(other.node);
        
        if (bullet.bulletType != kPlayerBullet3) {
            other.categoryBitMask = 0;
        }
        
        if (self.isImmuneToBullet) {
            return;
        }
        
        if (bullet.bulletType != kPlayerBullet7) {
            [self hitByBullet:bullet];
        } else {
            [[self gameObjectScene] applyDamage:[PlayerBullet damageForType:kPlayerBullet7]
                                     WithRadius:275.0
                                   FromPosition:self.position];
        }
    }
}

- (CGVector)getOriginalVelocity {
    // EFFECTS: Return the original velocity
    
    // To be overridden by subclasses
    return CGVectorMake(0.0, 0.0);
}


#pragma mark - Death
- (void)performDeath {
    // MODIFIES: self
    // EFFECTS: handling method when an enemy jet is dead
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    [super performDeath];
    
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
    
    shouldGeneratePowerup = true;
    [self runDeathEffect];
    [self updateGamescore];
    [[self gameObjectScene] increaseEnemyKilled];
}

- (void)performDeathWithEmitter {
    // MODIFIES: self
    // EFFECTS: handling method when an enemy jet is dead, add emitter to enemy jet
    
    if (self.currentState == STATE_DEATH) {
        return;
    }
    
    SKEmitterNode* emitter = [[self fireEmitter]copy];
    emitter.particlePositionRange = CGVectorMake(self.frame.size.width, self.frame.size.height);
    [self addChild:emitter];
    [self performDeath];
}

- (void)runDeathEffect {
    // EFFECTS: Run effects when an enemy jet is dead
    
    SKAction* deadthEffectAction = [self deadthEffectAction];
    if (deadthEffectAction){
        [self runAction:deadthEffectAction];
    }
}

- (void)updateGamescore {
    // EFFECTS: update game kScore after an enemy jet is dead
    
    float scoreGain = [self.class scoreGain];
    [self.gameObjectScene increaseGamescoreBy:scoreGain];
}


#pragma mark - Load Shared Assets
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        atlas = [SKTextureAtlas atlasNamed:@"enemy"];
        sSilenceTexture = [atlas textureNamed:@"silenceSymbol"];
        sWindEmitter = [Utilities createEmitterNodeWithEmitterNamed:@"WindBar"];
        sDeadthEffectAction = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.5],
                                                [SKAction removeFromParent]]];
        sFrozenEffectAction = [SKAction waitForDuration:3.0];
        sSlowEffectAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor blueColor]
                                                            colorBlendFactor:0.3
                                                                    duration:0.15],
                                                 [SKAction waitForDuration:2.5],
                                                 [SKAction colorizeWithColorBlendFactor:0.0
                                                                               duration:0.15]]];
        sFireEffectAction = [SKAction waitForDuration:3.0];
        
        sFireEnemyBulletEffectAction = [SKAction waitForDuration:3.0];
        sIceEnemyBulletEffectAciton = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor blueColor]
                                                                      colorBlendFactor:0.3
                                                                              duration:0.15],
                                                           [SKAction waitForDuration:3.0],
                                                           [SKAction colorizeWithColorBlendFactor:0.0
                                                                                         duration:0.15]]];
        sShockEnemyBulletEffectAction = [SKAction waitForDuration:1.0];
    });
}

+ (void)releaseSharedAssets
{
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    atlas = nil;
}

static SKTextureAtlas * atlas;
+ (SKTextureAtlas *)sTextureAtlas {
    // EFFECTS: Get the shared atlas for loading enemies
    
    return atlas;
}

+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Get the shared default texture
    
    return nil;
}

+ (SKTexture *)sDeadTexture {
    // EFFECTS: Get the shared default texture when the jet is dying
    
    return nil;
}

+ (SKTexture *)sFrozenTexture {
    // EFFECTS: Get the shared frozen textre when the jet is frozen
    
    return nil;
}

static SKEmitterNode * sWindEmitter = nil;
- (SKEmitterNode*)windEmitter {
    return sWindEmitter;
}

static SKTexture * sSilenceTexture = nil;
-(SKTexture *)silenceTexture {
    return sSilenceTexture;
}

static SKAction * sDeadthEffectAction = nil;
- (SKAction *)deadthEffectAction {
    return sDeadthEffectAction;
}

static SKAction * sFrozenEffectAction = nil;
- (SKAction *)frozenEffectAction {
    return sFrozenEffectAction;
}

static SKAction * sSlowEffectAction = nil;
- (SKAction *)slowEffectAction {
    return sSlowEffectAction;
}

static SKAction * sFireEffectAction = nil;
- (SKAction *)fireEffectAction {
    return sFireEffectAction;
}

static SKAction * sFireEnemyBulletEffectAction = nil;
- (SKAction *)fireEnemyBulletEffectAction {
    return sFireEnemyBulletEffectAction;
}

static SKAction * sIceEnemyBulletEffectAciton = nil;
- (SKAction *)iceEnemyBulletEffectAction {
    return sIceEnemyBulletEffectAciton;
}

static SKAction * sShockEnemyBulletEffectAction = nil;
- (SKAction *)shockEnemyBulletEffectAction {
    return sShockEnemyBulletEffectAction;
}

+ (float)scoreGain {
    return 0.0;
}

@end
