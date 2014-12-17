#import "HighDamageJet.h"
#import "Utilities.h"

#define kHealth 2250.0f
#define kBodyWidth 40
#define kBodyHeight 90
#define kTextureWidth 128
#define kTextureHeight 128

#define kSpecialMoveDuration 13.0
#define kSpecialShieldSize 165

@interface HighDamageJet()

@property (nonatomic, readwrite) CGSize bodySize;

@end

@implementation HighDamageJet

@dynamic bodySize;

- (id)initAtPosition:(CGPoint)position {
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position
    
    self = [super initWithTexture:sDefaultTexture];
    if (self) {
        self.position = position;
        self.health = kHealth;
        self.maxHealth = kHealth;
        self.bodySize = CGSizeMake(kBodyWidth, kBodyHeight);
        self.size = CGSizeMake(kTextureWidth, kTextureHeight);
        [self configurePhysicsBody];
        [self initialize];
    }
    return self;
}

- (void)hitByBullet:(Bullet *)bullet {
    // EFFECTS: Handling when the player jet is hit by bullet
    
    if (!self.isUsingSpecialMove) {
        [super hitByBullet:bullet];
    }
}

- (void)hitByEnemy:(SKNode *)enemy {
    // EFFECTS: Handling when the player jet is hit by enemy
    
    if (!self.isUsingSpecialMove) {
        [super hitByEnemy:enemy];
    }
}

- (void)handleShieldPowerup {
    // EFFECTS: Handling when collecting a shield powerup
    
    if (!self.isUsingSpecialMove) {
        [super handleShieldPowerup];
    }
}

- (void)initSpecialMove {
    // EFFECTS: Initialize when using special move
    
    SKSpriteNode * shieldNode = [[SKSpriteNode alloc] init];
    shieldNode.texture = [self specialShieldTexture];
    shieldNode.size = CGSizeMake(kSpecialShieldSize, kSpecialShieldSize);
    [self addChild:shieldNode];
    shieldNode.zPosition = self.zPosition + 1;
}

- (void)removeSpecialMove {
    // EFFECTS: Remove texture when finish special move
    
    [self removeChildWithTexture:[self specialShieldTexture]];
}

#pragma mark - Loading texture assets

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this orginal jet
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"plane2"];
    sDefaultTexture = [atlas textureNamed:@"plane2-center"];
    sTurnLeftTexture = [atlas textureNamed:@"plane2-left"];
    sTurnRightTexture = [atlas textureNamed:@"plane2-right"];
    sShieldTexture = [atlas textureNamed:@"shield"];
    sSpecialShieldTexture = [atlas textureNamed:@"shieldSpecial"];
    sTailSmoke = [Utilities createEmitterNodeWithEmitterNamed:@"TailSmoke"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSpecialFlagAction = [SKAction waitForDuration:kSpecialMoveDuration];
    });
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    sDefaultTexture = nil;
    sTurnLeftTexture = nil;
    sTurnRightTexture = nil;
    sShieldTexture = nil;
    sSpecialShieldTexture = nil;
    sTailSmoke = nil;
}

static SKAction * sSpecialFlagAction = nil;
- (SKAction *) specialFlagAction{
    
    return sSpecialFlagAction;
}

static SKTexture * sDefaultTexture = nil;
- (SKTexture *)defaultTexture {
    // EFFECTS: Return the default texture
    
    return sDefaultTexture;
}

static SKTexture * sTurnLeftTexture = nil;
- (SKTexture *)turnLeftTexture {
    // EFFECTS: Return the texture for when the jet is turning left
    
    return sTurnLeftTexture;
}

static SKTexture * sTurnRightTexture = nil;
- (SKTexture *)turnRightTexture {
    // EFFECTS: Return the texture for when the jet is turning right
    return sTurnRightTexture;
}

static SKTexture * sShieldTexture = nil;
- (SKTexture *)shieldTexture {
    // EFFECTS: Return the texture for the shield
    
    return sShieldTexture;
}

static SKTexture * sSpecialShieldTexture = nil;
- (SKTexture *)specialShieldTexture {
    // EFFECTS: Return the texture for the special shield
    
    return sSpecialShieldTexture;
}

static SKEmitterNode* sTailSmoke = nil;
- (SKEmitterNode *)tailSmoke {
    return sTailSmoke;
}

+(UIColor *)tailEmitterColor {
    return [UIColor colorWithRed:55 / 255.0f green:213 / 255.0f blue:239 / 255.0f alpha:1.0f];
}

@end
