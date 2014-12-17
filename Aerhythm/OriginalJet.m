#import "OriginalJet.h"
#import "PlayScene.h"
#import "Utilities.h"
#import "Vector2D.h"

#define kHealth 3500.0f
#define kBodyWidth 40
#define kBodyHeight 90
#define kTextureWidth 128
#define kTextureHeight 128

#define kDefaultFireCounter 500.0
#define kDefaultSpecialFiringSpeed 10.0
#define kSpecialMoveDuration 8.0

@interface OriginalJet()

// The body size of the original jet
@property (nonatomic, readwrite) CGSize bodySize;

@end

@implementation OriginalJet {
    float specialFireCounter;
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
    
    SKAction* specialFlagAction = [self specialFlagAction];
    [self runAction:specialFlagAction withKey:kSpecialFireEffect];
}

- (void)fire {
    // EFFECTS: General bullets firing method
    
    if (!self.isUsingSpecialMove) {
        [super fire];
    } else {
        [self fireSpecialMove];
    }
}

- (void)fireSpecialMove {
    // EFFECTS: Fire bullets when using special move
    
    specialFireCounter -= kDefaultSpecialFiringSpeed;
    
    if (specialFireCounter > 0) {
        return;
    }
    
    Vector2D* defaultVelocity = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:self.bulletType]];
    
    int numFireOrigins = 1;
    CGFloat angleIncrement = 360 / numFireOrigins;
    CGFloat distanceFromCenter = 75;
    
    for (int i = 0; i < numFireOrigins; i++) {
        CGFloat rotateAngle = angleIncrement * i;
        
        Vector2D * velocity = [defaultVelocity rotateWithAngle:rotateAngle];
        Vector2D * unitDirection = [velocity normalize];
        CGPoint firingPosition = [[unitDirection scalarMultiply:distanceFromCenter]
                                  applyVectorTranslationToPoint:self.position];
        
        [self fireCircleOfSpecialBulletAtPosition:firingPosition numLines:42];
    }
    
    specialFireCounter = kDefaultFireCounter;
}

- (void)fireCircleOfSpecialBulletAtPosition:(CGPoint)firingPosition numLines:(CGFloat)numLines {
    // EFFECTS: Fire a circle of bullets
    
    CGFloat angleIncrement = 360 / numLines;
    
    Vector2D* velocityVector = [Vector2D vectorFromCGVector:[Bullet getDefaultVelocity:self.bulletType]];
    
    for (int i = 0; i < numLines; i++) {
        CGFloat angle = i * angleIncrement;
        Vector2D * rotatedVector = [velocityVector rotateWithAngle:angle];
        
        PlayerBullet* bullet = (PlayerBullet*) [self fireFromPosition:firingPosition
                                                         withVelocity:[rotatedVector toCGVector]];
        [bullet setIsAffectedBySpecialMove:NO];
        
        SKAction* waitAction = [SKAction waitForDuration:0.3];
        SKAction* enableSpecialMoveAction = [SKAction runBlock:^{
            [bullet setIsAffectedBySpecialMove:YES];
        }];
        SKAction* sequence = [SKAction sequence:@[waitAction, enableSpecialMoveAction]];
        [bullet runAction:sequence];
    }
}

- (Bullet *)fireFromPosition:(CGPoint)firingPosition
    isAffectedBySpecialMove:(BOOL)isAffectedBySpecialMove {
    // EFFECTS: Return a bullet to fire for a position with condition of special move

    Bullet * bullet = [[PlayerBullet alloc] initWithPosition:firingPosition
                                               andBulletType:self.bulletType
                                     isAffectedBySpecialMove:isAffectedBySpecialMove
                                                  fromOrigin:kPlayerJet
                       ];
    [[self gameObjectScene] addNode:bullet atWorldLayer:kPlayerLayer];
    
    return bullet;
}

#pragma mark - Loading texture assets

+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this orginal je
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"plane1"];
    sDefaultTexture = [atlas textureNamed:@"plane1-center"];
    sTurnLeftTexture = [atlas textureNamed:@"plane1-left"];
    sTurnRightTexture = [atlas textureNamed:@"plane1-right"];
    sShieldTexture = [atlas textureNamed:@"shield"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSpecialFlagAction = [SKAction waitForDuration:kSpecialMoveDuration];
    });
    
    sTailSmoke = [Utilities createEmitterNodeWithEmitterNamed:@"TailSmoke"];
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
    // EFFECTS: Return the special flag action
    
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

static SKEmitterNode* sTailSmoke = nil;
- (SKEmitterNode *)tailSmoke {
    // EFFECTS: Return the emitter node for the tail of the original jet
    
    return sTailSmoke;
}

+ (UIColor*)tailEmitterColor {
    // EFFECTS: Return the color for tail emitter
    
    return [UIColor colorWithRed:21 / 255.0f green:71 / 255.0f blue:7/255.0f alpha:1.0f];
}

@end
