#import "HighHealthJet.h"
#import "Utilities.h"
#import "Vector2D.h"
#import "Powerup.h"

#define kHealth 5500.0f
#define kBodyWidth 40
#define kBodyHeight 90
#define kTextureWidth 128
#define kTextureHeight 128

#define kDefaultSpecialFireCounter 500
#define kSpecialMoveDuration 8.0

@interface HighHealthJet()

@property (nonatomic, readwrite) CGSize bodySize;

@end

@implementation HighHealthJet {
    CGFloat specialFireCounter;
}

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

- (void)initSpecialMove {
    // EFFECTS: Initialize when using special move
    
    SKAction* flagAction = [SKAction waitForDuration:kSpecialMoveDuration];
    [self runAction:flagAction withKey:kShieldEffect];
}

- (void)fire {
    // EFFECTS: General bullets firing method
    
    if (self.isUsingSpecialMove) {
        [self fireSpecialMove];
    } else {
        [super fire];
    }
}

- (void)fireSpecialMove {
    // EFFECTS: Fire bullets when using special move
    
    specialFireCounter -= self.firingSpeed;
    
    if (specialFireCounter > 0) {
        return;
    }
    
    CGPoint firingPosition = CGPointMake(self.position.x, self.position.y + 75);
    
    Vector2D * velocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:self.bulletType]];
    for (NSInteger i = -2; i <= 2; i++) {
        Vector2D * newVelocity = [velocity rotateWithAngle:(i * 10)];
        [self fireFromPosition:firingPosition withVelocity:[newVelocity toCGVector]];
    }
    
    specialFireCounter = kDefaultSpecialFireCounter;
}

#pragma mark - Loading texture assets

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this orginal jet
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"plane3"];
    sDefaultTexture = [atlas textureNamed:@"plane3-center"];
    sTurnLeftTexture = [atlas textureNamed:@"plane3-left"];
    sTurnRightTexture = [atlas textureNamed:@"plane3-right"];
    sShieldTexture = [atlas textureNamed:@"shield"];
    
    sTailSmoke = [Utilities createEmitterNodeWithEmitterNamed:@"TailSmoke"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSpecialFlagAction = [SKAction waitForDuration:8.0];
    });
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    sDefaultTexture = nil;
    sTurnLeftTexture = nil;
    sTurnRightTexture = nil;
    sShieldTexture = nil;
    sTailSmoke = nil;
}

static SKAction * sSpecialFlagAction = nil;
- (SKAction *) specialFlagAction{
    
    return sSpecialFlagAction;
}

static SKTexture *sDefaultTexture = nil;
- (SKTexture *)defaultTexture {
    // EFFECTS: Return the default texture
    
    return sDefaultTexture;
}

static SKTexture *sTurnLeftTexture = nil;
- (SKTexture *)turnLeftTexture {
    // EFFECTS: Return the texture for when the jet is turning left
    
    return sTurnLeftTexture;
}

static SKTexture *sTurnRightTexture = nil;
- (SKTexture *)turnRightTexture {
    // EFFECTS: Return the texture for when the jet is turning right
    return sTurnRightTexture;
}

static SKTexture *sShieldTexture = nil;
- (SKTexture *)shieldTexture {
    // EFFECTS: Return the texture for the shield
    
    return sShieldTexture;
}

static SKEmitterNode* sTailSmoke = nil;
- (SKEmitterNode*)tailSmoke {
    return sTailSmoke;
}

+ (UIColor *)tailEmitterColor {
    // EFFECTS: Return the color for the tail emitter
    
    return [UIColor colorWithRed:146 / 255.0f green:44 / 255.0f blue:6 / 255.0f alpha:1.0f];
}

@end
