#import "PlayerJet.h"
#import "Utilities.h"
#import "Vector2D.h"
#import "Powerup.h"
#import "PlayerBullet.h"
#import "PlayScene.h"
#import "EnemyBullet.h"
#import "SuicideEnemy.h"
#import "LightningBolt.h"

#define kCollisionDamage 20.0
#define kFiringSpeedDefaultCounter 500.0
#define kNumberAngleForSpinFire 72
#define kManaPool 500

#define kFireEffect @"fire-effect"
#define kSlowEffect @"slow-effect"
#define kShockEffect @"shock-effect"

#define kConfuseEffect @"confuse-effect"

#define kDoubleFireEffect @"double-fire-effect"
#define kTripleFireEffect @"triple-fire-effect"
#define kPursueFireEffect @"pursue-fire-effect"
#define kQuadrupleSpinFireEffect @"quadruple-spin-fire-effect"
#define kSpecialMove @"special-move"

#define kTailEmitterName @"TailSmoke"

@interface PlayerJet ()

// Indicator whether the player jet is hit by a fire bullet
@property (nonatomic) BOOL isFired;
// Indicator whether the player jet is being slowed
@property (nonatomic) BOOL isSlowed;
// Indicator whether the player jet is being shocked
@property (nonatomic, readwrite) BOOL isShocked;
// The body size for the physics body of the player jet
@property (nonatomic, readwrite) CGSize bodySize;
// The current type of fire of the player jet
@property (nonatomic, readwrite) PlayerFireType fireType;

@end

@implementation PlayerJet {
    // The fire counter to check whether the jet is allowed to fire a bullet
    float fireCounter;
    
    // The counter to determine firing position for spin fire
    int spinFireCounter;
}

@synthesize bodySize;


#pragma mark - Initialization
- (void)initialize {
    // MODIFIES: self
    // EFFECTS: Setup the game object when it is first initialized
    
    fireCounter = kFiringSpeedDefaultCounter;
    spinFireCounter = 0;
    self.firingSpeed = 150.0;
    self.currentMana = 0.0;
    self.maxMana = kManaPool;
    
    _isFired = NO;
    _isSlowed = NO;
    _isShocked = NO;
    _isConfuseEnemy = NO;
    _isUsingSpecialMove = NO;
    
    _fireType = kDefaultFire;
    
    [self addTailSmokeEmitter];
}

- (void)addTailSmokeEmitter {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Add the tail emitter for the player jet
    
    self.tailEmitter = [[self tailSmokeEmitter]copy];
    float tailX = 0;
    float tailY = - self.frame.size.height / 2;
    self.tailEmitter.position = CGPointMake(tailX, tailY);
    self.tailEmitter.zPosition = self.zPosition - 1;
    
    self.tailEmitter.particleColorSequence = nil;
    self.tailEmitter.particleColorBlendFactor = 1.0f;
    self.tailEmitter.particleBlendMode = SKBlendModeAdd;
    self.tailEmitter.particleColor = [self.class tailEmitterColor];
    
    [self addChild:self.tailEmitter];
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the player jet when it is first initialized
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.bodySize];
    self.physicsBody.dynamic = NO;
    self.physicsBody.categoryBitMask = kPlayerJet;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = kEnemyJet | kBossJet | kEnemyBullet | kPowerup | kSuicideEnemyJet;
}


#pragma mark - Handle effects of enemy bullets
- (void)hitByBullet:(Bullet *)bullet {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Modify the attributes of the jet when it is hit by a bullet
    
    if (!self.isShield){
        [self handleSpecialEffectsByBullet:bullet];
        [self applyDamage:bullet.damage];
    }
}

- (void)handleSpecialEffectsByBullet:(Bullet *)bullet {
    // MODIFIES: self
    // REQUIRES: self != nil
    // EFFECTS: Handling special effects when the enemy jet is hit by the bullet
    
    switch (bullet.bulletType) {
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

- (void)handleEffectOfFireEnemyBullet {
    // REQUIRES: self != nil
    // EFFECTS: Handle the effect when player jet is hit by a fire bullet
    
    SKAction *flagAction = [self fireEnemyBulletEffectAction];
    [self runAction:flagAction withKey:kFireEffect];
}

- (void)handleEffectOfIceEnemyBullet {
    // REQUIRES: self != nil
    // EFFECTS: Handle the effect when player jet is hit by an ice bullet
    
    SKAction *action = [self iceEnemyBulletEffectAction];
    [self runAction:action withKey:kSlowEffect];
}

- (void)handleEffectOfShockEnemyBullet {
    // REQUIRES: self != nil
    // EFFECTS: Handle the effect when player jet is hit by a shock bullet
    
    SKAction *flagAction = [self shockEnemyBulletEffectAction];
    [self runAction:flagAction withKey:kShockEffect];
}


#pragma mark - Handle power-up collections and effects
- (void)collectPowerUp:(Powerup *)powerUp {
    // MODIFIES: self
    // EFFECTS: Handling method when the player collects a power up
    
    switch (powerUp.powerupType) {
        case kHealerPowerup:
            [self handleHealerPowerup];
            break;
        case kShieldPowerup:
            [self handleShieldPowerup];
            break;
        case kDoubleFirePowerup:
            [self handleDoubleFirePowerup];
            break;
        case kTripleFirePowerup:
            [self handleTripleFirePowerup];
            break;
        case kQuadrupleFirePowerup:
            [self handleQuadrupleSpinFirePowerup];
            break;
        case kPursuePowerup:
            [self handlePursuePowerup];
            break;
        case kConfusePowerup:
            [self handleConfusePowerup];
            break;
        case kDestructionPowerup:
            [self handleDestructionPowerup];
            break;
        default:
            break;
    }
}

- (void)handleHealerPowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the healer power-up
    
    float healAmount = [Powerup healAmount];
    self.health += healAmount;
    
    if (self.health > self.maxHealth) {
        self.health = self.maxHealth;
    }
}

- (void)handleShieldPowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the shield power-up
    
    SKAction* flagAction = [self shieldFlagAction];
    [self runAction:flagAction withKey:kShieldEffect];
}

- (void)handleDoubleFirePowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the double fire power-up
    
    if(![self actionForKey:kSpecialFireEffect]){
        SKAction* flagAction = [self doubleFireFlagAction];
        [self runAction:flagAction withKey:kDoubleFireEffect];
        
        [self removeActionForKey:kTripleFireEffect];
        [self removeActionForKey:kQuadrupleSpinFireEffect];
        [self removeActionForKey:kPursueFireEffect];
    }
}

- (void)handleTripleFirePowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the triple fire power-up
    
    if(![self actionForKey:kSpecialFireEffect]){
        SKAction* flagAction = [self tripleFireFlagAction];
        [self runAction:flagAction withKey:kTripleFireEffect];
        
        [self removeActionForKey:kDoubleFireEffect];
        [self removeActionForKey:kQuadrupleSpinFireEffect];
        [self removeActionForKey:kPursueFireEffect];
    }
}

- (void)handleQuadrupleSpinFirePowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the quarter spin fire power-up
    
    if(![self actionForKey:kSpecialFireEffect]){
        SKAction* flagAction = [self quadrupleFlagAction];
        [self runAction:flagAction withKey:kQuadrupleSpinFireEffect];
        
        [self removeActionForKey:kDoubleFireEffect];
        [self removeActionForKey:kTripleFireEffect];
        [self removeActionForKey:kPursueFireEffect];
    }
}

- (void)handlePursuePowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the quarter spin fire power-up
    
    if(![self actionForKey:kSpecialFireEffect]){
        SKAction* flagAction = [self quadrupleFlagAction];
        [self runAction:flagAction withKey:kPursueFireEffect];
        
        [self removeActionForKey:kDoubleFireEffect];
        [self removeActionForKey:kTripleFireEffect];
        [self removeActionForKey:kQuadrupleSpinFireEffect];
    }
}

- (void)handleConfusePowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the confusing power-up
    
    SKAction* flagAction = [self confuseFlagAction];
    [self runAction:flagAction withKey:kConfuseEffect];
}

- (void)handleDestructionPowerup {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handle the effect of the destruction power-up
    
    [self.gameObjectScene killAllEnemiesExceptBoss];
}


#pragma mark - Firing player bullets
- (void)fire {
    // REQUIRES: self != nil
    // EFFECTS: Handling method when the jet fires
    
    fireCounter -= self.firingSpeed;
    
    if(fireCounter < 0) {
        switch (_fireType) {
            case kDoubleFire:
                [self doubleFire];
                break;
            case kTripleFire:
                [self tripleFire];
                break;
            case kQuadrupleSpinFire:
                [self quadrupleSpinFire];
                break;
            case kPursueFire:
                [self pursueFire];
                break;
            default:
                [self defaultFire];
                break;
        }
        
        fireCounter = kFiringSpeedDefaultCounter;
    }
}

- (void)defaultFire {
    // REQUIRES: self != nil
    // EFFECTS: Handle the default firing for the player jet
    
    CGPoint firingPosition = CGPointMake(self.position.x, self.position.y + 75);
    
    PlayerBullet *bullet = [[PlayerBullet alloc] initWithPosition:firingPosition
                                                    andBulletType:self.bulletType
                                                       fromOrigin:kPlayerJet];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kPlayerLayer];
}

- (void)doubleFire {
    // REQUIRES: self != nil
    // EFFECTS: Hadle the double firing for the player jet
    
    CGPoint firingPosition = CGPointMake(self.position.x, self.position.y + 20);
    
    float dx = self.frame.size.width / 2.75;
    float shiftX = 5;
    CGPoint firstPosition = CGPointMake(firingPosition.x - dx + shiftX, firingPosition.y);
    CGPoint secondPosition = CGPointMake(firingPosition.x + dx + shiftX, firingPosition.y);
    
    [self fireFromPosition:firstPosition];
    [self fireFromPosition:secondPosition];
}

- (void)tripleFire {
    // REQUIRES: self != nil
    // EFFECTS: Handle the triple firing for the player jet
    
    CGPoint firingPosition = CGPointMake(self.position.x, self.position.y + 75);
    
    Vector2D * velocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:_bulletType]];
    for (NSInteger i = -1; i < 2; i++) {
        Vector2D * newVelocity = [velocity rotateWithAngle:(i * 15)];
        [self fireFromPosition:firingPosition withVelocity:[newVelocity toCGVector]];
    }
}

- (void)quadrupleSpinFire {
    // REQUIRES: self != nil
    // EFFECTS: handle quadruple spin firing for the player jet
    
    Vector2D * velocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:_bulletType]];
    float speed = [velocity length];
    float distanceFromCenter = 55;
    float shiftY = -25;
    
    spinFireCounter = (spinFireCounter + 1) % kNumberAngleForSpinFire;
    
    for (int i = 0; i < 4; i++) {
        CGFloat angle = spinFireCounter * 360.0 / kNumberAngleForSpinFire + i * 90.0;
        Vector2D *rotatedVelocity = [velocity rotateWithAngle:angle];
        
        CGFloat dx = distanceFromCenter * rotatedVelocity.x / speed;
        CGFloat dy = distanceFromCenter * rotatedVelocity.y / speed;
        CGPoint firingPosition = CGPointMake(self.position.x + dx, self.position.y + dy + shiftY);
        [self fireFromPosition:firingPosition withVelocity:[rotatedVelocity toCGVector]];
    }
 }

- (void)pursueFire{
    CGPoint firingPosition = CGPointMake(self.position.x, self.position.y + 75);
    [self fireFromPosition:firingPosition];
}

- (Bullet*)fireFromPosition:(CGPoint)firingPosition withVelocity:(CGVector)velocity {
    // REQUIRES: self != nil
    // EFFECTS: Fire the bullet at a specific position with given velocity
    
    Bullet * bullet = [[PlayerBullet alloc] initWithPosition:firingPosition
                                               andBulletType:self.bulletType
                                                 andVelocity:velocity
                                                  fromOrigin:kPlayerJet];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kPlayerLayer];
    
    return bullet;
}

- (Bullet*)fireFromPosition:(CGPoint)firingPosition {
    // REQUIRES: self != nil
    // EFFECTS: Fire the bullet at a specific position with default velocity
    
    Bullet * bullet = [[PlayerBullet alloc] initWithPosition:firingPosition
                                               andBulletType:self.bulletType
                                                  fromOrigin:kPlayerJet];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kPlayerLayer];
    
    return bullet;
}


#pragma mark - Special move
- (void)enableSpecialMove {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Enable the player jet to start using special move

    self.currentMana = 0;
    SKAction* flagAction = [self specialFlagAction];
    [self runAction:flagAction withKey:kSpecialMove];
}

- (void)initSpecialMove {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Initial setup when the special move is first activated
    
    // To be implemented by subclasses
}

- (void)removeSpecialMove {
    // REQUIRE: self != nil
    // MODIFIES: self
    // EFFECTS: Remove the special move, let the jet go back to default state

    // To be implemented by subclasses
}


#pragma mark - Update
- (void)update {
    // MODIFIES: self
    // EFFECTS: Update the state of the game object, this method is called for each game loop
    
    if(self.hasStateChanged){
        if(self.currentState == STATE_DEFAULT){
            self.texture = [self defaultTexture];
        } else if(self.currentState == STATE_TURN_LEFT){
            self.texture = [self turnLeftTexture];
        } else if(self.currentState == STATE_TURN_RIGHT){
            self.texture = [self turnRightTexture];
        }
        self.hasStateChanged = NO;
    }
    
    [self updateSpecialEffects];
}

- (void)updateSpecialEffects {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Update the special effects on the player jet
    
    // Fire effect
    if ([self actionForKey:kFireEffect]) {
        if (!_isFired) {
            SKEmitterNode* emitter = [[self fireEmitter]copy];
            [self addChild:emitter];
            _isFired = true;
        }
        self.health -= [EnemyBullet damageForType:kFireEnemyBullet];
    } else {
        if (_isFired) {
            [self removeEmitter:[self fireEmitter]];
            _isFired = false;
        }
    }
    
    // Slow effect
    if ([self actionForKey:kSlowEffect]) {
        if (!_isSlowed) {
            SKEmitterNode* emitter = [[self slowEmitter]copy];
            emitter.particlePositionRange = CGVectorMake(self.frame.size.width, self.frame.size.height);
            [self addChild:emitter];
            
            self.firingSpeed /= 2.5;
            _isSlowed = true;
        }
    } else {
        if (_isSlowed) {
            [self removeEmitter:[self slowEmitter]];
            
            self.firingSpeed *= 2.5;
            _isSlowed = false;
        }
    }
    
    // Shock effect
    if ([self actionForKey:kShockEffect]) {
        if (!_isShocked) {
            _isShocked = true;
            
            LightningBolt* lightningBolt = [[self gameObjectScene] addLightningBoltAimedAtPlayerWithLifetime:0.1f
                                                             andLineDrawDelay:0.00125f
                                                                andThickness:1.3f];
            
            SKAction* waitAction = [SKAction waitForDuration:lightningBolt.totalDrawTime];
            SKAction* addTextureAction = [SKAction runBlock:^{
                [self addShockTexture];
            }];
            SKAction* sequence = [SKAction sequence:@[waitAction, addTextureAction]];
            
            [self runAction:sequence];
        }
     } else {
        if (_isShocked) {
            _isShocked = false;
            [self removeChildWithTexture:[self shockIconTexture]];
        }
    }
    
    // Shield effect
    if ([self actionForKey:kShieldEffect]) {
        if (!_isShield) {
            SKSpriteNode *shieldNode = [[SKSpriteNode alloc] init];
            shieldNode.texture = [self shieldTexture];
            shieldNode.size = CGSizeMake(165, 165);
            [self addChild:shieldNode];
            shieldNode.zPosition = self.zPosition + 1;
            
            _isShield = YES;
        }
    } else {
        if (_isShield) {
            [self removeChildWithTexture:[self shieldTexture]];
            
            _isShield = NO;
        }
    }
    
    // Confuse effect
    if ([self actionForKey:kConfuseEffect]) {
        if (!_isConfuseEnemy) {
            _isConfuseEnemy = YES;
        }
    } else {
        if (_isConfuseEnemy) {
            _isConfuseEnemy = NO;
        }
    }
    
    // Double fire effect
    if ([self actionForKey:kDoubleFireEffect]) {
        if (_fireType != kDoubleFire) {
            _fireType = kDoubleFire;
        }
    } else {
        if (_fireType == kDoubleFire) {
            _fireType = kDefaultFire;
        }
    }
    
    // Triple fire effect
    if ([self actionForKey:kTripleFireEffect]) {
        if (_fireType != kTripleFire) {
            _fireType = kTripleFire;
        }
    } else {
        if (_fireType == kTripleFire) {
            _fireType = kDefaultFire;
        }
    }
    
    // Quadruple fire effect
    if ([self actionForKey:kQuadrupleSpinFireEffect]) {
        if (_fireType != kQuadrupleSpinFire) {
            _fireType = kQuadrupleSpinFire;
        }
    } else {
        if (_fireType == kQuadrupleSpinFire) {
            _fireType = kDefaultFire;
        }
    }
    
    // Pursue fire effect
    if ([self actionForKey:kPursueFireEffect]){
        if (_fireType != kPursueFire){
            _fireType = kPursueFire;
        }
    }
    else{
        if (_fireType == kPursueFire){
            _fireType = kDefaultFire;
        }
    }

    // Special move
    if ([self actionForKey:kSpecialMove]) {
        if (!_isUsingSpecialMove) {
            _isUsingSpecialMove = YES;
            [self initSpecialMove];
        }
    } else {
        if (_isUsingSpecialMove) {
            _isUsingSpecialMove = NO;
            [self removeSpecialMove];
        }
    }
}

- (void)addShockTexture{
    SKSpriteNode *shockNode = [[SKSpriteNode alloc] initWithTexture:[self shockIconTexture]];
    shockNode.size = CGSizeMake(50, 50);
    shockNode.position = CGPointMake(0, self.size.height * 2 / 3.0);
    [self addChild:shockNode];
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this object's physic body with another object's one
    
    if (other.categoryBitMask & (kEnemyJet | kBossJet | kSuicideEnemyJet)) {
        [self hitByEnemy:[other node]];
        [[self gameObjectScene] shake:10 atAmplitudeX:16 andAmplitudeY:5];
    }
    
    if (other.categoryBitMask & kEnemyBullet) {
        other.categoryBitMask = 0;
        [self hitByBullet:(Bullet*)other.node];
        [[self gameObjectScene] shake:10 atAmplitudeX:10 andAmplitudeY:2];
    }
    
    if (other.categoryBitMask & kPowerup) {
        Powerup* powerUp = (Powerup*)other.node;
        [self collectPowerUp:powerUp];
    }
}

- (void)hitByEnemy:(SKNode *)enemy {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Modify the attributes of the jet when it is hit by an enemy
    
    if (!self.isShield) {
        CGFloat collisionDamage = kCollisionDamage;
        
        if ([enemy isKindOfClass:[SuicideEnemy class]]) {
             collisionDamage *= 8.0;
        }
        
        [self applyDamage:collisionDamage];
    }
}

- (void)performDeath {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Handling method when the jet is dead
    
    // Check for revival power-up
    if([Powerup reviveStock] > 0){
        self.health = self.maxHealth;
        [[self gameObjectScene] playerDidUseRevival];
        [Powerup updateReviveStock:[Powerup reviveStock] - 1];
        return ;
    }
    
    if(self.currentState != STATE_DEATH){
        [super performDeath];
        [[self gameObjectScene] addAchievementToScore];
        
        SKAction *fadeOutMusicAction = [SKAction runBlock:^{
            [self.gameObjectScene.musicPlayer fadeOut];
        }];
        SKAction* deathEffectAction = [self deathEffectAction];
        SKAction* notifyAction = [SKAction runBlock:^{
            [self.gameObjectScene.delegate gameDidEnd];
        }];
        SKAction* deathAction = [SKAction sequence:@[deathEffectAction, notifyAction]];
        SKAction *groupAction = [SKAction group:@[fadeOutMusicAction, deathAction]];
        [self runAction:groupAction];
    }
}


#pragma mark - Load shared assets
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    
    sShieldFlagAction = [SKAction waitForDuration:[Powerup shieldDuration]];
    sDoubleFireFlagAction = [SKAction waitForDuration:[Powerup doubleFireDuration]];
    sTripleFireFlagAction = [SKAction waitForDuration:[Powerup tripleFireDuration]];
    sQuadrupleFlagAction = [SKAction waitForDuration:[Powerup quadrupleFireDuration]];
    sPursueFlagAction = [SKAction waitForDuration:[Powerup pursueDuration]];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sTailSmokeEmitter = [Utilities createEmitterNodeWithEmitterNamed:kTailEmitterName];
        sConfuseFlagAction = [SKAction waitForDuration:6.0];
        sdeathEffectAction = [SKAction fadeOutWithDuration:1.0];
        sFireEnemyBulletEffectAction = [SKAction waitForDuration:3.0];
        sIceEnemyBulletEffectAciton = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor blueColor]
                                                                      colorBlendFactor:0.3
                                                                              duration:0.15],
                                                           [SKAction waitForDuration:3.0],
                                                           [SKAction colorizeWithColorBlendFactor:0.0
                                                                                         duration:0.15]]];
        sShockEnemyBulletEffectAction = [SKAction waitForDuration:0.5];
    });
}

- (SKTexture *)turnLeftTexture {
    // EFFECTS: Get the texture for turn left state
    
    return nil;
}

- (SKTexture *)turnRightTexture {
    // EFFECTS: Get the texture for turn right state
    
    return nil;
}

- (SKTexture *)defaultTexture {
    // EFFECTS: Get the texture for the default state
    
    return nil;
}

-(SKTexture *)shieldTexture {
    // EFFECTS: Get the texture for the shield of the player jet
    
    return nil;
}

static SKEmitterNode * sTailSmokeEmitter = nil;
- (SKEmitterNode *)tailSmokeEmitter {
    // EFFECTS: Get the emitter node for the tail emitter
    
    return sTailSmokeEmitter;
}

static SKAction * sdeathEffectAction = nil;
- (SKAction *)deathEffectAction {
    // EFFECTS: Get the action to be performed when the player is dead
    
    return sdeathEffectAction;
}

static SKAction * sShieldFlagAction = nil;
- (SKAction *)shieldFlagAction {
    // EFFECTS: Get the flag action to enable the shield power-up
    
    return sShieldFlagAction;
}

static SKAction * sDoubleFireFlagAction = nil;
- (SKAction *)doubleFireFlagAction {
    // EFFECTS: Get the flag action to enable the double fire power-up
    
    return sDoubleFireFlagAction;
}

static SKAction * sTripleFireFlagAction = nil;
- (SKAction *)tripleFireFlagAction {
    // EFFECTS: Get the flag action to enable the triple fire power-up
    
    return sTripleFireFlagAction;
}

static SKAction * sQuadrupleFlagAction = nil;
- (SKAction *)quadrupleFlagAction {
    // EFFECTS: Get the flag action to enable the quad spin fire power-up
    
    return sQuadrupleFlagAction;
}


- (SKAction *)specialFlagAction {
    // EFFECTS: Get the flag action to enable the special move
    
    return nil;
}

static SKAction * sPursueFlagAction = nil;
- (SKAction *)pursueFlagAction {
    // EFFECTS: Get the flag action to enable the special move
    
    return sPursueFlagAction;
}

static SKAction * sConfuseFlagAction = nil;
- (SKAction *)confuseFlagAction {
    // EFFECTS: Get the flag action to enable the confuse power-up
    
    return sConfuseFlagAction;
}

static SKAction * sFireEnemyBulletEffectAction = nil;
- (SKAction *)fireEnemyBulletEffectAction {
    // EFFECTS: Get the action to be performed when the player is hit by fire bullet
    
    return sFireEnemyBulletEffectAction;
}

static SKAction * sIceEnemyBulletEffectAciton = nil;
- (SKAction *)iceEnemyBulletEffectAction {
    // EFFECTS: Get the action to be performed when the player is hit by ice bullet
    
    return sIceEnemyBulletEffectAciton;
}

static SKAction * sShockEnemyBulletEffectAction = nil;
- (SKAction *)shockEnemyBulletEffectAction {
    // EFFECTS: Get the action to be performed when the player is hit by shock bullet
    
    return sShockEnemyBulletEffectAction;
}

static PlayerJetType modelType = kOriginal;
+ (void)setModelType:(PlayerJetType)type {
    // EFFECTS: Set the current shared model type for player jet
    
    modelType = type;
}

+ (PlayerJetType)modelType {
    // EFFECTS: Get the current shared model type for player jet
    
    return modelType;
}

+ (UIColor *)tailEmitterColor {
    // EFFECTS: Get the color for tail emitter for player jet
    
    return [UIColor clearColor];
}

@end
