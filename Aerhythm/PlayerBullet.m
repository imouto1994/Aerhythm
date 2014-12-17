#import "PlayerBullet.h"
#import "PlayScene.h"
#import "Constant.h"
#import "Vector2D.h"
#import "PlayerJet.h"
#import "EnemyJet.h"

#define kRippleDurationIndex 0
#define kRippleNumIndex 1
#define kRippleScaleIndex 2

#define kOriginalModelIndex 0
#define kHighDamageModelIndex 1
#define kHighHealthModelIndex 2

#define kSpreadOffset 10

@interface PlayerBullet()

// The spreading property of lightning bullet
@property (nonatomic, readwrite) BOOL canSpread;

// The damage of bullet
@property (nonatomic, readwrite) CGFloat damage;

// The indicator whether the bullet has hit enemy or not
@property (nonatomic) BOOL hasHitEnemy;

@end

@implementation PlayerBullet

@dynamic damage;

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
             canSpread:(BOOL)canSpread
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity, canSpread property and its origin
    
    CGFloat defaultRadius = [PlayerBullet getDefaultRadiusSize:bulletType];
    self = [super initWithPosition:position
                     andBulletType:bulletType
                         andRadius:defaultRadius
                       andVelocity:velocity
                        fromOrigin:originType];
    if (self) {
        self.canSpread = canSpread;
    }
    return self;
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
isAffectedBySpecialMove:(BOOL)isAffectedBySpecialMove
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type with condition of being affected by special move and its origin

    CGFloat defaultRadius = [PlayerBullet getDefaultRadiusSize:bulletType];
    self = [super initWithPosition:position
                     andBulletType:bulletType
                         andRadius:defaultRadius
                        fromOrigin:originType];
    if (self) {
        self.isAffectedBySpecialMove = isAffectedBySpecialMove;
    }
    return self;
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type and its origin
    
    CGFloat defaultRadius = [PlayerBullet getDefaultRadiusSize:bulletType];
    return [self initWithPosition:position andBulletType:bulletType andRadius:defaultRadius fromOrigin:originType];
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity and its origin
    
    CGFloat defaultRadius = [PlayerBullet getDefaultRadiusSize:bulletType];
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
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, radius, velocity and its origin
    
    [self checkOriginType:originType];
    self = [super initWithPosition:position
                     andBulletType:bulletType
                         andRadius:radius
                       andVelocity:velocity
                        fromOrigin:originType];
    if(self) {
        self.canSpread = YES;
        self.damage = [PlayerBullet damageForType:bulletType];
        self.hasHitEnemy = NO;
        self.isAffectedBySpecialMove = YES;
    }
    return self;
}

- (void)checkOriginType:(NSInteger) originType{
    // EFFECTS: Check if the given origin type is from PLAYER_JET. If it is not, an exception wil be raised.
    
    if (originType != kPlayerJet) {
        [NSException raise:@"Invalid origin" format:@"The origin of this bullet is not from player jet"];
    }
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physicsBody
    // EFFECTS: Configure the physic body of the game object when it is first initialized
    
    [super configurePhysicsBody];
    self.physicsBody.categoryBitMask = kPlayerBullet;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = kEnemyJet | kBossJet;
}

- (void)removeBitMask {
    // REQUIRES: self != nil
    // MODIFIES: self.physicsBody
    // EFFECTS: Remove collision detection from the bullet
    
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
}

- (SKTexture *)determineTexture {
    // EFFECTS: Get the corresponding texture for the current bullet type of the bullet
    
    switch (self.bulletType) {
        case kPlayerBullet1:
            return [self sPlayerBullet1Texture];
            break;
        case kPlayerBullet2:
            return [self sPlayerBullet2Texture];
            break;
        case kPlayerBullet3:
            return [self sPlayerBullet3Texture];
            break;
        case kPlayerBullet4:
            return [self sPlayerBullet4Texture];
            break;
        case kPlayerBullet5:
            return [self sPlayerBullet5Texture];
            break;
        case kPlayerBullet6:
            return [self sPlayerBullet6Texture];
            break;
        case kPlayerBullet7:
            return [self sPlayerBullet7Texture];
            break;
        default:
            return nil;
            break;
    }
}

- (SKTexture *)determineRippleTexture {
    // EFFECTS: Get the corresponding ripple texture for the current bullet type of the bullet
    
    switch (self.bulletType) {
        case kPlayerBullet1:
            return [self sPlayerBullet1RippleTexture];
            break;
        case kPlayerBullet2:
            return [self sPlayerBullet2RippleTexture];
            break;
        case kPlayerBullet3:
            return [self sPlayerBullet3RippleTexture];
            break;
        case kPlayerBullet4:
            return [self sPlayerBullet4RippleTexture];
            break;
        case kPlayerBullet5:
            return [self sPlayerBullet5RippleTexture];
            break;
        case kPlayerBullet6:
            return [self sPlayerBullet6RippleTexture];
            break;
        case kPlayerBullet7:
            return [self sPlayerBullet7RippleTexture];
            break;
        default:
            return nil;
            break;
    }
}

- (SKAction *)getRippleEffect {
    // EFFECTS: Get the corresponding creating ripple action according to the bullet type
    
    NSArray *rippleInfo = [PlayerBullet getRippleInfoForBulletType:self.bulletType];
    NSTimeInterval singleRippleDuration = [rippleInfo[kRippleDurationIndex] doubleValue];
    NSUInteger numberOfRipples = [rippleInfo[kRippleNumIndex] integerValue];
    CGFloat ripleEndScale = [rippleInfo[kRippleScaleIndex] doubleValue];
    NSTimeInterval timeBetweenRipples = 0.1f;
    
    SKAction* scaleUpAction = [SKAction scaleTo:ripleEndScale duration:singleRippleDuration];
    SKAction* fadeOutAction = [SKAction fadeOutWithDuration:singleRippleDuration];
    SKAction* rippleAction = [SKAction sequence:@[[SKAction group:@[scaleUpAction,fadeOutAction]], [SKAction removeFromParent]]];
    
    SKAction* createRipple = [SKAction runBlock:^{
        //Create ripple node
        SKSpriteNode *rippleNode = [[SKSpriteNode alloc] init];
        rippleNode.texture = [self determineRippleTexture];
        rippleNode.size = CGSizeMake(50, 50);
        rippleNode.position = self.position;
        
        //Set scale to 0 so it scales from point
        [rippleNode setScale:0.0f];
        [rippleNode runAction:rippleAction];
        [self.gameObjectScene addNode:rippleNode atWorldLayer:kPlayerLayer];
    }];
    
    SKAction* wait = [SKAction waitForDuration:timeBetweenRipples];
    return [SKAction repeatAction:[SKAction sequence:@[createRipple,wait]] count:numberOfRipples];
}

+ (NSArray *)getRippleInfoForBulletType:(BulletType)bulletType {
    // EFFECTS: Get the ripple info according to the given bullet type
    
    switch (bulletType) {
        case kPlayerBullet1:
            return @[@0.5, @5, @2.0];
            break;
        case kPlayerBullet2:
            return @[@0.5, @5, @3.0];
            break;
        case kPlayerBullet3:
            return @[@0.4, @2, @4.0];
            break;
        case kPlayerBullet4:
            return @[@0.4, @4, @5.0];
            break;
        case kPlayerBullet5:
            return @[@0.15, @1, @5.0];
            break;
        case kPlayerBullet6:
            return @[@0.3, @3, @7.0];
            break;
        case kPlayerBullet7:
            return @[@0.2, @3, @8.0];
        default:
            return nil;
            break;
    }
}

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    
    SKTextureAtlas *atlas = [Bullet sTextureAtlas];
        
    sPlayerBullet1Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-1", (long)[PlayerJet modelType] + 1]];
    sPlayerBullet2Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-2", (long)[PlayerJet modelType] + 1]];
    sPlayerBullet3Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-3",(long) [PlayerJet modelType] + 1]];
    sPlayerBullet4Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-4",(long) [PlayerJet modelType] + 1]];
    sPlayerBullet5Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-5",(long) [PlayerJet modelType] + 1]];
    sPlayerBullet6Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-6",(long)[PlayerJet modelType] + 1]];
    sPlayerBullet7Texture = [atlas textureNamed:[NSString stringWithFormat:@"note%ld-7",(long) [PlayerJet modelType] + 1]];
        
    sPlayerBullet1RippleTexture = [atlas textureNamed:@"ripple-note-1"];
    sPlayerBullet2RippleTexture = [atlas textureNamed:@"ripple-note-2"];
    sPlayerBullet3RippleTexture = [atlas textureNamed:@"ripple-note-3"];
    sPlayerBullet4RippleTexture = [atlas textureNamed:@"ripple-note-4"];
    sPlayerBullet5RippleTexture = [atlas textureNamed:@"ripple-note-5"];
    sPlayerBullet6RippleTexture = [atlas textureNamed:@"ripple-note-6"];
    sPlayerBullet7RippleTexture = [atlas textureNamed:@"ripple-note-7"];
}

+ (CGFloat)damageForType:(BulletType)type {
    // EFFECTS: Get default damage for a bullet type
    
    NSArray *damageList = [Constant damageList:[PlayerJet modelType]];
    switch (type) {
        case kPlayerBullet1:
            return [damageList[0] doubleValue];
            break;
        case kPlayerBullet2:
            return [damageList[1] doubleValue];
            break;
        case kPlayerBullet3:
            return [damageList[2] doubleValue];
            break;
        case kPlayerBullet4:
            return [damageList[3] doubleValue];
            break;
        case kPlayerBullet5:
            return [damageList[4] doubleValue];
            break;
        case kPlayerBullet6:
            return [damageList[5] doubleValue];
            break;
        case kPlayerBullet7:
            return [damageList[6] doubleValue];
            break;
        default:
            return 0;
            break;
    }
}

+ (CGFloat)getDefaultRadiusSize:(BulletType) bulletType {
    // EFFECTS: Gets default radius size for the input bullet type
    
    PlayerJetType modelType = [PlayerJet modelType];
    if(modelType == kOriginalModelIndex) {
        return 36.0;
    } else if (modelType == kHighDamageModelIndex) {
        return 25.0;
    } else {
        return 36.0;
    }
}


+ (void)releaseSharedAssets {
    // EFFECTS: Release texture at the end of play scene
    
    sPlayerBullet1Texture = nil;
    sPlayerBullet2Texture = nil;
    sPlayerBullet3Texture = nil;
    sPlayerBullet4Texture = nil;
    sPlayerBullet5Texture = nil;
    sPlayerBullet6Texture = nil;
    sPlayerBullet7Texture = nil;
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // MODIFIES: self
    // EFFECTS: Handling method when there is a collision from this object's physic body with another object's one
    
    BOOL isEnemyHitByPlayerBullet = (other.categoryBitMask & (kEnemyJet | kBossJet));
    
    self.hasHitEnemy = YES;
    
    if (self.bulletType == kPlayerBullet3) {
        [self runAction:[self getRippleEffect]];
        return;
    }
    
    [self removeBitMask];
    
    // Handle spreading of bullet 5
    if (self.bulletType == kPlayerBullet5 && self.canSpread) {
        for (int dx = -1; dx <= 1; dx += 2) {
            for (int dy = -1; dy <= 1; dy += 2) {
                CGFloat newSpeed = [[Vector2D vectorFromCGVector:self.originalVelocity] length] / sqrt(2.0);
                CGVector newVelocity = CGVectorMake(newSpeed * dx, newSpeed * dy);
                CGPoint position = [self.gameObjectScene convertPoint:other.node.position fromNode:other.node.parent];
                position = [self.gameObjectScene convertPoint:position toNode:self.parent];
                CGFloat otherSize = other.node.frame.size.height / 2.0 + kSpreadOffset;
                CGPoint newPosition = CGPointMake(position.x + otherSize * dx, position.y + otherSize * dy);
                Bullet * newBullet = [[PlayerBullet alloc] initWithPosition:newPosition
                                                              andBulletType:kPlayerBullet5
                                                                andVelocity:newVelocity
                                                                  canSpread:false
                                                                 fromOrigin:self.bulletOriginType];
                [self.gameObjectScene addNode:newBullet atWorldLayer:kPlayerLayer];
                [newBullet configurePhysicsBody];
                [newBullet.physicsBody setVelocity:newVelocity];
            }
        }
    }
    
    // Shake screen for bullet 7
    if (self.bulletType == kPlayerBullet7) {
        [[self gameObjectScene] shake:5 atAmplitudeX:25 andAmplitudeY:2];
    }
    
    // Remove bullet from scene
    if (isEnemyHitByPlayerBullet) {
        SKAction *rippleEffect = [SKAction group:@[[SKAction fadeOutWithDuration:0.3],[self getRippleEffect]]];
        SKAction *sequence = [SKAction sequence:@[rippleEffect, [SKAction removeFromParent]]];
        [self runAction:sequence];
        self.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    } else {
        [self removeFromScene];
    }
    
}

- (void)updateWithHint:(BOOL)hasHint andEnemyPositionHint:(CGPoint)enemyPosition {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Update the bullet to move toward enemy

    if (self.bulletType == kPlayerBullet3 && self.hasHitEnemy == YES){
        return;
    }
    if (self.bulletType == kPlayerBullet5 && self.canSpread == NO){
        return;
    }
    
    CGPoint enemyWorldPosition = [[self gameObjectScene] convertPoint:enemyPosition
                                                             fromNode:self];
    CGPoint bulletWorldPosition = [[self gameObjectScene] convertPoint:self.position
                                                              fromNode:self.parent];
    Vector2D* unitDirection = [[Vector2D vectorFromPoint:bulletWorldPosition toPoint:enemyWorldPosition] normalize];
    Vector2D* currentVelocity = [Vector2D vectorFromCGVector:self.physicsBody.velocity];
    CGFloat speed = [currentVelocity length];
    Vector2D* newVelocity = [unitDirection scalarMultiply:speed];
    
    self.physicsBody.velocity = [newVelocity toCGVector];
}

static SKTexture* sPlayerBullet1RippleTexture = nil;
-(SKTexture *) sPlayerBullet1RippleTexture{
    // EFFECTS: Get the shared texture for ripple effect for player first bullet
    
    return sPlayerBullet1RippleTexture;
}

static SKTexture* sPlayerBullet2RippleTexture = nil;
-(SKTexture *) sPlayerBullet2RippleTexture{
    // EFFECTS: Get the shared texture for ripple effect for player second bullet
    
    return sPlayerBullet2RippleTexture;
}

static SKTexture* sPlayerBullet3RippleTexture = nil;
-(SKTexture *) sPlayerBullet3RippleTexture {
    // EFFECTS: Get the shared texture for ripple effect for player third bullet
    
    return sPlayerBullet3RippleTexture;
}

static SKTexture* sPlayerBullet4RippleTexture = nil;
-(SKTexture *) sPlayerBullet4RippleTexture {
    // EFFECTS: Get the shared texture for ripple effect for player fourth bullet
    
    return sPlayerBullet4RippleTexture;
}

static SKTexture* sPlayerBullet5RippleTexture = nil;
-(SKTexture *) sPlayerBullet5RippleTexture {
    // EFFECTS: Get the shared texture for ripple effect for player fifth bullet
    
    return sPlayerBullet5RippleTexture;
}

static SKTexture* sPlayerBullet6RippleTexture = nil;
-(SKTexture *) sPlayerBullet6RippleTexture{
    // EFFECTS: Get the shared texture for ripple effect for player sixth bullet
    
    return sPlayerBullet6RippleTexture;
}

static SKTexture* sPlayerBullet7RippleTexture = nil;
-(SKTexture *) sPlayerBullet7RippleTexture{
    // EFFECTS: Get the shared texture for ripple effect for player seventh bullet
    
    return sPlayerBullet7RippleTexture;
}

static SKTexture* sPlayerBullet1Texture = nil;
-(SKTexture *) sPlayerBullet1Texture{
    // EFFECTS: Get shared texture for the first bullet type
    
    return sPlayerBullet1Texture;
}

static SKTexture* sPlayerBullet2Texture = nil;
- (SKTexture *) sPlayerBullet2Texture{
    // EFFECTS: Get shared texture for the second bullet type
    
    return sPlayerBullet2Texture;
}

static SKTexture* sPlayerBullet3Texture = nil;
- (SKTexture *) sPlayerBullet3Texture{
    // EFFECTS: Get shared texture for the third bullet type
    
    return sPlayerBullet3Texture;
}

static SKTexture* sPlayerBullet4Texture = nil;
- (SKTexture *) sPlayerBullet4Texture{
    // EFFECTS: Get shared texture for the fourth bullet type
    
    return sPlayerBullet4Texture;
}

static SKTexture* sPlayerBullet5Texture = nil;
- (SKTexture *) sPlayerBullet5Texture{
    // EFFECTS: Get shared texture for the fifth bullet type
    
    return sPlayerBullet5Texture;
}

static SKTexture* sPlayerBullet6Texture = nil;
- (SKTexture *) sPlayerBullet6Texture{
    // EFFECTS: Get shared texture for the sixth bullet type
    
    return sPlayerBullet6Texture;
}

static SKTexture* sPlayerBullet7Texture = nil;
- (SKTexture *) sPlayerBullet7Texture{
    // EFFECTS: Get shared texture for the seventh bullet type
    
    return sPlayerBullet7Texture;
}

static SKAction* sPlayerBullet1RippleAction = nil;
- (SKAction*) playerBullet1RippleAction{
    // EFFECTS: Get shared ripple action for the first bullet type
    
    return sPlayerBullet1RippleAction;
}


static SKAction* sPlayerBullet2RippleAction = nil;
- (SKAction*) playerBullet2RippleAction{
    // EFFECTS: Get shared ripple action for the second bullet type
    
    return sPlayerBullet2RippleAction;
}


static SKAction* sPlayerBullet3RippleAction = nil;
- (SKAction*) playerBullet3RippleAction{
    // EFFECTS: Get shared ripple action for the third bullet type
    
    return sPlayerBullet3RippleAction;
}


static SKAction* sPlayerBullet4RippleAction = nil;
- (SKAction*) playerBullet4RippleAction{
    // EFFECTS: Get shared ripple action for the forth bullet type
    
    return sPlayerBullet4RippleAction;
}

static SKAction* sPlayerBullet5RippleAction = nil;
- (SKAction*) playerBullet5RippleAction{
    // EFFECTS: Get shared ripple action for the fifth bullet type
    
    return sPlayerBullet5RippleAction;
}


static SKAction* sPlayerBullet6RippleAction = nil;
- (SKAction*) playerBullet6RippleAction{
    // EFFECTS: Get shared ripple action for the sixth bullet type
    
    return sPlayerBullet6RippleAction;
}


static SKAction* sPlayerBullet7RippleAction = nil;
- (SKAction*) playerBullet7RippleAction{
    // EFFECTS: Get shared ripple action for the seventh bullet type
    
    return sPlayerBullet7RippleAction;
}

@end
