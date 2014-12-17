#import "SuicideEnemy.h"
#import "PlayScene.h"
#import "Vector2D.h"
#import "Utilities.h"

#define kFiringSpeed 0.0
#define kHealth 500.0f
#define kHorizontalVelocity 400.0f
#define kSlowFactor 3.0f
#define kNumberNeededFrozenBullet 10
#define kNumberNeededWindBullet 17
#define kFireDamage 2
#define kRadius 72
#define MAX_DISTANCE_TO_SUICIDE 700.0f
#define MAX_HEALTH_TO_SUICIDE 501.0f
#define SUICIDE_SPEED 1300.0f
#define kScore 80

@interface SuicideEnemy()

@property (nonatomic, readwrite) CGFloat originalFiringSpeed;

@property (nonatomic, readwrite) BOOL runningToPlayer;

@end

@implementation SuicideEnemy {
}

@dynamic originalFiringSpeed;

- (id)initAtPosition:(CGPoint)position {
    return [self initAtPosition:position enableFire:YES];
}

- (id)initAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire {
    // MODIFIES: self
    // EFFECTS: Initialize the sprite node at an assigned position
    
    self = [super initAtPosition:position withRadius:kRadius enableFire:isEnableFire];
    
    if (self) {
        self.texture = sDefaultTexture;
        self.health = kHealth;
        self.firingSpeed = kFiringSpeed;
        self.originalFiringSpeed = kFiringSpeed;
        self.physicsBody.velocity = CGVectorMake(kHorizontalVelocity, 0.0);
        self.jetSpeed = kHorizontalVelocity;
        self->slowFactor = kSlowFactor;
        self->numberNeededFrozenBullet = kNumberNeededFrozenBullet;
        self->numberNeededWindBullet = kNumberNeededWindBullet;
        self->fireDamage = kFireDamage;
        self.physicsBody.collisionBitMask = kPlayerJet | kWallLeft | kWallRight | kWallTop;
        self.physicsBody.categoryBitMask = kSuicideEnemyJet;
        self.runningToPlayer = NO;
    }
    return self;
}

- (void)updateWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // EFFECTS: Set direction towards player position
    
    [super update];
    
    if (hasHint) {
        if (self.currentState == STATE_FROZEN) {
            self.runningToPlayer = NO;
        }
        
        if (self.isPushed || self.currentState == STATE_DEATH ||
            self.currentState == STATE_FROZEN || self.runningToPlayer || self.isMovingToScene) {
            return;
        }
        
        CGPoint playerWorldPoint = [[self gameObjectScene] convertPoint:playerPosition
                                                               fromNode:self];
        CGPoint enemyWordPoint = [[self gameObjectScene] convertPoint:self.position
                                                             fromNode:self.parent];
        Vector2D * distanceVector = [Vector2D vectorFromPoint:enemyWordPoint toPoint:playerWorldPoint];
        if (self.health < MAX_HEALTH_TO_SUICIDE ||
            [distanceVector squareLength] < MAX_DISTANCE_TO_SUICIDE * MAX_DISTANCE_TO_SUICIDE) {
            self.physicsBody.velocity = [[[distanceVector normalize] scalarMultiply:SUICIDE_SPEED] toCGVector];
            self.jetSpeed = SUICIDE_SPEED;
            self.runningToPlayer = YES;
        }
    }
}

- (void)fire {
    // Suicide enemy doesn't fire
}

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition {
    // Suicide enemy doesn't fire
}

- (CGVector)getOriginalVelocity {
    // EFFECTS: Return original velocity
    
    return CGVectorMake(kHorizontalVelocity, 0.0);
}

- (void)collidedWith:(SKPhysicsBody *)other {
    // EFFECTS: Handling when colliding with other object
    
    [super collidedWith:other];
    
    if (other.categoryBitMask & kPlayerJet) {
        [self performDeath];
        [self performExplosion];
    }
}

- (void)performExplosion {
    // EFFECTS: Explode when colliding with player jet
    
    SKEmitterNode* explosionEmitter = [[self.class explosionEmitter] copy];
    if (explosionEmitter){
        [self addChild:explosionEmitter];
    }
}

#pragma mark - Load Shared Asset Texture
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that will be used for all objects from this jet
    sDefaultTexture = [[self sTextureAtlas] textureNamed:@"enemy5"];
    sDeadTexture = [[self sTextureAtlas] textureNamed:@"enemy5-dead"];
    sFrozenTexture = [[self sTextureAtlas] textureNamed:@"enemy5-frozen"];
    
    sExplosionEmitter = [Utilities createEmitterNodeWithEmitterNamed:@"Explosion"];
}

+ (void)releaseSharedAssets {
    // EFFECTS: Releases all shared assets that any instances of this class have loaded
    
    sDeadTexture = nil;
    sDefaultTexture = nil;
    sFrozenTexture = nil;
}

static SKTexture *sDefaultTexture = nil;
+ (SKTexture *)sDefaultTexture {
    // EFFECTS: Get the shared default texture
    
    return sDefaultTexture;
}

static SKTexture *sDeadTexture = nil;
+ (SKTexture *)sDeadTexture {
    // EFFECTS: Get the shared default texture when the jet is dying
    
    return sDeadTexture;
}

static SKTexture *sFrozenTexture = nil;
+ (SKTexture *)sFrozenTexture {
    // EFFECTS: Gets the shared default texture when the jet is frozen
    
    return sFrozenTexture;
}

static SKEmitterNode* sExplosionEmitter = nil;
+ (SKEmitterNode*)explosionEmitter{
    // EFFECTS: Gets the shared explosion emitter when the bomb is exploded
    
    return sExplosionEmitter;
}

+ (float)scoreGain {
    return kScore;
}

@end
