#import "EnemyBullet.h"
#import "Utilities.h"
#import "HighDamageJet.h"

@interface EnemyBullet()

@property (nonatomic, readwrite) CGFloat damage;

@end

@implementation EnemyBullet

@dynamic damage;

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type and its origin
    
    CGFloat defaultRadius = [EnemyBullet getDefaultRadiusSize:bulletType];
    return [self initWithPosition:position
                    andBulletType:bulletType
                        andRadius:defaultRadius
                       fromOrigin:originType];
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity and its origin
    
    CGFloat defaultRadius = [EnemyBullet getDefaultRadiusSize:bulletType];
    return [self initWithPosition:position
                    andBulletType:bulletType
                        andRadius:defaultRadius
                      andVelocity:velocity
                       fromOrigin:originType];
}


- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
             andRadius:(CGFloat)radius
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType{
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, radius, velocity and its origin

    [self checkOriginType:originType];
    self = [super initWithPosition:position
                     andBulletType:bulletType
                         andRadius:radius
                       andVelocity:velocity
                        fromOrigin:originType];
    if(self){
        self.damage = [EnemyBullet damageForType:bulletType];
    }
    return self;
}

- (void)checkOriginType:(NSInteger)originType {
    // EFFECTS: Check if the given origin type is from ENEMY_JET. If it is not, an exception will be raised.
    
    if (originType != kEnemyJet) {
        [NSException raise:@"Invalid origin" format:@"The origin of this bullet is not from enemy"];
    }
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the game object when it is first initialized

    [super configurePhysicsBody];
    self.physicsBody.categoryBitMask = kEnemyBullet;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = kPlayerJet;
}

- (void)reflectFromPlayerJet{
    // MODIFIES: self.physicsBody
    // EFFECTS: Change this bullet to be player jet's bullet
    
    self.physicsBody.categoryBitMask = kPlayerBullet;
    self.physicsBody.contactTestBitMask = kEnemyJet;
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this object's physic body with another object's one
    
    BOOL isPlayerHitByEnemyBullet = (other.categoryBitMask & kPlayerJet);
    
    if (isPlayerHitByEnemyBullet) {
        
        PlayerJet *playerJet = (PlayerJet *)[other node];
        
        if ([playerJet isKindOfClass:[HighDamageJet class]] && playerJet.isUsingSpecialMove) {
            CGFloat dx = self.physicsBody.velocity.dx;
            CGFloat dy = self.physicsBody.velocity.dy;
            self.physicsBody.velocity = CGVectorMake(-dx, -dy);
            [self reflectFromPlayerJet];
        } else {
            [self removeBitMask];
            SKEmitterNode* emitter = [sBulletSparkEmitter copy];
            self.zPosition += 2;
            self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
            [self addChild:emitter];
            [self removeFromScene];
        }
    }
    
    BOOL isEnemyHitByEnemyBullet = (other.categoryBitMask & kEnemyJet);
    if (isEnemyHitByEnemyBullet) {
        [self removeBitMask];
        SKEmitterNode* emitter = [sBulletSparkEmitter copy];
        self.zPosition++;
        self.physicsBody.velocity = CGVectorMake(0.0, 50.0);
        [self addChild:emitter];
        [self removeFromScene];
    }
}

- (void)removeBitMask {
    // MODIFIES: self.physicsBody
    // EFFECTS: Remove collision detection from this bullet
    
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
}

- (SKTexture *)determineTexture {
    // EFFECTS: Get the corresponding texture for the current bullet type of the bullet

    switch (self.bulletType) {
        case kFireEnemyBullet:
            return [self sEnemyBulletFireTexture];
            break;
        case kDefaultEnemyBullet:
            return [self sEnemyBulletDefaultTexture];
            break;
        case kNinjaEnemyBullet:
            return [self sEnemyBulletNinjaTexture];
            break;
        case kIceEnemyBullet:
            return [self sEnemyBulletIceTexture];
            break;
        case kRockEnemyBullet:
            return [self sEnemyBulletRockTexture];
            break;
        case kShockEnemyBullet:
            return [self sEnemyBulletShockTexture];
            break;
        case kFirstBossNormalIntensedBullet:
            return [self sFirstBossNormalIntensedBullet];
            break;
        case kFirstBossHighIntensedBullet:
            return [self sFirstBossHighIntensedBullet];
            break;
        case kSecondBossNormalIntensedBullet:
            return [self sSecondBossNormalIntensedBullet];
            break;
        case kSecondBossHighIntensedBullet:
            return [self sSecondBossHighIntensedBullet];
            break;
        case kSecondBossExtremeIntensedBullet:
            return [self sSecondBossExtremeIntensedBullet];
            break;
        case kThirdBossNormalIntensedBullet:
            return [self sThirdBossNormalIntensedBullet];
            break;
        case kThirdBossHighIntensedBullet:
            return [self sThirdBossHighIntensedBullet];
            break;
        case kFourthBossNormalIntensedBullet:
            return [self sFourthBossNormalIntensedBullet];
            break;
        case kFourthBossHighIntensedBullet:
            return [self sFourthBossHighIntensedBullet];
            break;
        case kFourthBossExtremeIntensedBullet:
            return [self sFourthBossExtremeIntensedBullet];
            break;
        case kFourthBossUltimateIntensedBullet:
            return [self sFourthBossUltimateIntensedBullet];
            break;
        default:
            return nil;
            break;
    }
}

- (void)addSpecialVisualEffect{
    // MODIFIES: self
    // EFFECTS: Add special visual effect for a specific bullet according to its bullet type
    
    switch (self.bulletType) {
        case kNinjaEnemyBullet: case kFirstBossHighIntensedBullet: case kThirdBossHighIntensedBullet:
            [self rotateBulletExtremelyFast];
            break;
            
        default:
            break;
    }
}

- (void)rotateBulletExtremelyFast {
    // EFFECTS: Rotate bullet around itself
    
    SKAction* rotateAction = [self rotateExtremelyFastAction];
    if (rotateAction){
        [self runAction:rotateAction];
    }
}

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [Bullet sTextureAtlas];
        sEnemyBulletFireTexture = [atlas textureNamed:@"enemy-bullet-fire"];
        sEnemyBulletDefaultTexture = [atlas textureNamed:@"enemy-bullet-default"];
        sEnemyBulletNinjaTexture = [atlas textureNamed:@"enemy-bullet-ninja"];
        sEnemyBulletIceTexture = [atlas textureNamed:@"enemy-bullet-ice"];
        sEnemyBulletRockTexture = [atlas textureNamed:@"enemy-bullet-rock"];
        sEnemyBulletShockTexture = [atlas textureNamed:@"enemy-bullet-shock"];
        sFirstBossNormalIntensedBullet = [atlas textureNamed:@"boss1-bullet-1"];
        sFirstBossHighIntensedBullet= [atlas textureNamed:@"boss1-bullet-2"];
        sSecondBossNormalIntensedBullet = [atlas textureNamed:@"boss2-bullet-1"];
        sSecondBossHighIntensedBullet = [atlas textureNamed:@"boss2-bullet-2"];
        sSecondBossExtremeIntensedBullet = [atlas textureNamed:@"boss2-bullet-3"];
        sThirdBossNormalIntensedBullet = [atlas textureNamed:@"boss3-bullet-1"];
        sThirdBossHighIntensedBullet = [atlas textureNamed:@"boss3-bullet-2"];
        sFourthBossNormalIntensedBullet = [atlas textureNamed:@"boss4-bullet-3"];
        sFourthBossHighIntensedBullet = [atlas textureNamed:@"boss4-bullet-1"];
        sFourthBossExtremeIntensedBullet = [atlas textureNamed:@"boss4-bullet-2"];
        sFourthBossUltimateIntensedBullet = [atlas textureNamed:@"boss4-bullet-4"];
        
        sBulletSparkEmitter = [Utilities createEmitterNodeWithEmitterNamed:@"BulletSpark"];
        
        sRotateExtremelyFastAction = [SKAction repeatActionForever:[SKAction rotateByAngle:M_2_PI duration:0.05]];
    });
}

+ (CGFloat)damageForType:(BulletType)type {
    // EFFECTS: Get default damage for a bullet type
    
    switch (type) {
        case kFireEnemyBullet:
            return 0.6;
            break;
        case kDefaultEnemyBullet:
            return 14.0;
            break;
        case kNinjaEnemyBullet:
            return 16.0;
            break;
        case kIceEnemyBullet:
            return 17.0;
            break;
        case kRockEnemyBullet:
            return 18.0;
            break;
        case kShockEnemyBullet:
            return 14.0;
            break;
        case kFirstBossNormalIntensedBullet:
            return 22.0;
            break;
        case kFirstBossHighIntensedBullet:
            return 22.0;
            break;
        case kSecondBossNormalIntensedBullet:
            return 18.0;
            break;
        case kSecondBossHighIntensedBullet:
            return 22.0;
            break;
        case kSecondBossExtremeIntensedBullet:
            return 24.0;
            break;
        case kThirdBossNormalIntensedBullet:
            return 24.0;
            break;
        case kThirdBossHighIntensedBullet:
            return 22.0;
            break;
        case kFourthBossNormalIntensedBullet:
            return 28.0;
            break;
        case kFourthBossHighIntensedBullet:
            return 30.0;
            break;
        case kFourthBossExtremeIntensedBullet:
            return 34.0;
            break;
        case kFourthBossUltimateIntensedBullet:
            return 30.0;
            break;
        default:
            return 0;
            break;
    }
}

+ (CGFloat)getDefaultRadiusSize:(BulletType)bulletType {
    // EFFECTS: Gets default radius size for the input bullet type
    
    switch (bulletType) {
        case kFireEnemyBullet:
            return 48;
            break;
        case kDefaultEnemyBullet:
            return 16;
            break;
        case kNinjaEnemyBullet:
            return 48;
            break;
        case kIceEnemyBullet:
            return 48;
            break;
        case kRockEnemyBullet:
            return 40;
            break;
        case kShockEnemyBullet:
            return 24;
            break;
        case kFirstBossNormalIntensedBullet:
            return 16;
            break;
        case kFirstBossHighIntensedBullet:
            return 48;
            break;
        case kSecondBossNormalIntensedBullet:
            return 22;
            break;
        case kSecondBossHighIntensedBullet:
            return 32;
            break;
        case kSecondBossExtremeIntensedBullet:
            return 48;
            break;
        case kThirdBossNormalIntensedBullet:
            return 48;
            break;
        case kThirdBossHighIntensedBullet:
            return 48;
            break;
        case kFourthBossNormalIntensedBullet:
            return 24;
            break;
        case kFourthBossHighIntensedBullet:
            return 72;
            break;
        case kFourthBossExtremeIntensedBullet:
            return 30;
            break;
        case kFourthBossUltimateIntensedBullet:
            return 30;
            break;
        default:
            return 0;
            break;
    }
}

static SKTexture* sEnemyBulletFireTexture = nil;
- (SKTexture*) sEnemyBulletFireTexture{
    // EFFECTS: Get the shared texture for first enemy bullet
    return sEnemyBulletFireTexture;
}

static SKTexture* sEnemyBulletDefaultTexture = nil;
- (SKTexture*) sEnemyBulletDefaultTexture{
    // EFFECTS: Get the shared texture for second enemy bullet
    return sEnemyBulletDefaultTexture;
}

static SKTexture* sEnemyBulletNinjaTexture = nil;
- (SKTexture*) sEnemyBulletNinjaTexture{
    // EFFECTS: Get the shared texture for third enemy bullet
    
    return sEnemyBulletNinjaTexture;
}

static SKTexture* sEnemyBulletIceTexture = nil;
- (SKTexture*) sEnemyBulletIceTexture{
    // EFFECTS: Get the shared texture for fourth enemy bullet
    
    return sEnemyBulletIceTexture;
}

static SKTexture* sEnemyBulletRockTexture = nil;
- (SKTexture*) sEnemyBulletRockTexture{
    // EFFECTS: Get the shared texture for sixth enemy bullet
    
    return sEnemyBulletRockTexture;
}

static SKTexture* sEnemyBulletShockTexture = nil;
- (SKTexture*) sEnemyBulletShockTexture{
    // EFFECTS: Get the shared texture for seventh enemy bullet
    
    return sEnemyBulletShockTexture;
}

static SKTexture* sFirstBossNormalIntensedBullet = nil;
-(SKTexture *) sFirstBossNormalIntensedBullet {
    // EFFECTS: Get the shared texture for first boss's normal intensed bullet
    
    return sFirstBossNormalIntensedBullet;
}

static SKTexture* sFirstBossHighIntensedBullet = nil;
-(SKTexture *) sFirstBossHighIntensedBullet {
    // EFFECTS: Get the shared texture for first boss's high intensed bullet
    
    return sFirstBossHighIntensedBullet;
}

static SKTexture* sSecondBossNormalIntensedBullet = nil;
- (SKTexture*) sSecondBossNormalIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's normal intensed bullet
    
    return sSecondBossNormalIntensedBullet;
}

static SKTexture* sSecondBossHighIntensedBullet = nil;
- (SKTexture*) sSecondBossHighIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's high intensed bullet
    
    return sSecondBossHighIntensedBullet;
}

static SKTexture* sSecondBossExtremeIntensedBullet = nil;
- (SKTexture*) sSecondBossExtremeIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's extreme intensed bullet
    
    return sSecondBossExtremeIntensedBullet;
}

static SKTexture* sThirdBossNormalIntensedBullet = nil;
- (SKTexture*) sThirdBossNormalIntensedBullet {
    // EFFECTS: Get the shared texture for third boss's normal intensed bullet
    
    return sThirdBossNormalIntensedBullet;
}

static SKTexture* sThirdBossHighIntensedBullet = nil;
- (SKTexture*) sThirdBossHighIntensedBullet {
    // EFFECTS: Get the shared texture for third boss's high intensed bullet
    
    return sThirdBossHighIntensedBullet;
}

static SKTexture* sFourthBossNormalIntensedBullet = nil;
- (SKTexture*) sFourthBossNormalIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's normal intensed bullet
    
    return sFourthBossNormalIntensedBullet;
}

static SKTexture* sFourthBossHighIntensedBullet = nil;
- (SKTexture*) sFourthBossHighIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's high intensed bullet
    
    return sFourthBossHighIntensedBullet;
}

static SKTexture* sFourthBossExtremeIntensedBullet = nil;
- (SKTexture*) sFourthBossExtremeIntensedBullet {
    // EFFECTS: Get the shared texture for second boss's extreme intensed bullet
    
    return sFourthBossExtremeIntensedBullet;
}

static SKTexture* sFourthBossUltimateIntensedBullet = nil;
- (SKTexture*) sFourthBossUltimateIntensedBullet {
    // EFFECTS: Get the shared texture for fourth boss's intensed bullet
    
    return sFourthBossUltimateIntensedBullet;
}

static SKEmitterNode* sBulletSparkEmitter = nil;
- (SKEmitterNode*) sBulletSparkEmitter{
    // EFFECTS: Get the bullet spark emitter
    
    return sBulletSparkEmitter;
}

static SKAction* sRotateExtremelyFastAction = nil;
- (SKAction*) rotateExtremelyFastAction{
    // EFFECTS: Get the action for bullet rotation
    
    return sRotateExtremelyFastAction;
}

@end
