#import "Bullet.h"
#import <stdlib.h>
#import "Vector2D.h"
#import "PlayerJet.h"

@interface Bullet()

// The bullet type
@property (nonatomic, readwrite) BulletType bulletType;
// The origin of the bullet, whether it is from the player or te enmy
@property (nonatomic, readwrite) NSInteger bulletOriginType;
// The damage of the bullet
@property (nonatomic, readwrite) CGFloat damage;
// The radius of the bullet
@property (nonatomic, readwrite) CGFloat radius;
// The original velocity of the bullet
@property (nonatomic, readwrite) CGVector originalVelocity;


@end

@implementation Bullet


#pragma mark - Initialization
- (void)checkInit {
    // EFFECTS: Check if the object using this method is a Bullet object. If it is, this will raise an exception.
    
    if([self class] == [Bullet class]){
        [NSException raise:@"Abstract class Violation" format:@"You cannot use init method for this abstract class. Please subclass it"];
    }
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type and its origin
    
    CGFloat defaultRadius = [Bullet getDefaultRadiusSize:bulletType];
    return [self initWithPosition:position andBulletType:bulletType andRadius:defaultRadius fromOrigin:originType];
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
             andRadius:(CGFloat)radius
            fromOrigin:(NSInteger)originType {
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, radius and its origin
    
    CGVector defaultVelocity = [Bullet getDefaultVelocity:bulletType];
    return [self initWithPosition:position
                    andBulletType:bulletType
                        andRadius:radius
                      andVelocity:defaultVelocity
                       fromOrigin:originType];
}

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType{
    // MODIFIES: self
    // EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity and its origin
    
    CGFloat defaultRadius = [Bullet getDefaultRadiusSize:bulletType];
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
    
    [self checkInit];
    self = [super init];
    if(self){
        _bulletType = bulletType;
        _bulletOriginType = originType;
        
        self.texture = [self determineTexture];
        self.radius = radius;
        self.size = CGSizeMake(self.radius * 2, self.radius * 2);
        self.name = @"bullet";
        self.position = position;
        self.zPosition = -1;
        [self configurePhysicsBody];
        self.physicsBody.velocity = velocity;
        self.originalVelocity = velocity;
        [self setDamage:[Bullet damageForType:bulletType]];
        [self addSpecialVisualEffect];
    }
    return self;
}

- (void)addSpecialVisualEffect {
    // MODIFIES: self
    // EFFECTS: Add special visual effect for a specific bullet according to its bullet type
}

- (void)configurePhysicsBody {
    // MODIFIES: self.physisBody
    // EFFECTS: Configure the physic body of the game object when it is first initialized
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius - 10];
    self.physicsBody.friction = 0;
    self.physicsBody.linearDamping = 0;
    self.physicsBody.angularDamping = 0;
    self.physicsBody.affectedByGravity = 0;
    self.physicsBody.restitution = 0;
    self.physicsBody.angularVelocity = 0;
}


#pragma mark - Update
- (void)collidedWithWall:(WallType)wall {
    // REQUIRE: self != nil
    // EFFECTS: Handle when the enemy jet is colliding with the wall
    
    // Only do reflection for kPlayerBullet3
    if (self.bulletType != kNinjaEnemyBullet) {
        return;
    }
    
    Vector2D * velocityVector = [Vector2D vectorFromCGVector:self.physicsBody.velocity];
    Vector2D * newVelocityVector = velocityVector;
    
    if (wall == kLeftWall && velocityVector.x < 0){
        Vector2D * wallVector = [Vector2D vectorWithX:1 andY:0];
        newVelocityVector = [velocityVector reflectAroundMirrorVector:wallVector];
    }
    else if (wall == kRightWall && velocityVector.x > 0){
        Vector2D * wallVector = [Vector2D vectorWithX:1 andY:0];
        newVelocityVector = [velocityVector reflectAroundMirrorVector:wallVector];
    }
    
    self.originalVelocity = [newVelocityVector toCGVector];
}

- (void)removeFromScene {
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Remove this node from the current game scene that it is in
    
    SKAction* removeFromSceneAction = [self removeFromSceneAction];
    if (removeFromSceneAction){
        [self runAction:removeFromSceneAction];
    }
}


#pragma mark - Getter methods
- (SKTexture *)determineTexture {
    // EFFECTS: Get the corresponding texture for the current bullet type of the bullet
    
    return  nil;
}

+ (CGFloat)getDefaultRadiusSize:(BulletType) bulletType {
    // EFFECTS: Gets default radius size for the input bullet type
    
    return 0;
}

+ (CGVector)getDefaultVelocity:(BulletType) bulletType {
    // EFFECTS: Get the default velocity according to the bullet type
    
    switch (bulletType) {
        case kPlayerBullet1:
            return CGVectorMake(0.0, 300.0);
            break;
        case kPlayerBullet2:
            return CGVectorMake(0.0, 350.0);
            break;
        case kPlayerBullet3:
            return CGVectorMake(0.0, 450.0);
            break;
        case kPlayerBullet4:
            return CGVectorMake(0.0, 700.0);
            break;
        case kPlayerBullet5:
            return CGVectorMake(0.0, 850);
            break;
        case kPlayerBullet6:
            return CGVectorMake(0.0, 975.0);
            break;
        case kPlayerBullet7:
            return CGVectorMake(0.0, 975.0);
            break;
        case kFireEnemyBullet:
            return CGVectorMake(0.0, -300.0);
            break;
        case kDefaultEnemyBullet:
            return CGVectorMake(0.0, -150.0);
            break;
        case kNinjaEnemyBullet:
            return CGVectorMake(0.0, -400.0);
            break;
        case kIceEnemyBullet:
            return CGVectorMake(0.0, -200.0);
            break;
        case kRockEnemyBullet:
            return CGVectorMake(0.0, -300.0);
            break;
        case kShockEnemyBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kFirstBossNormalIntensedBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kFirstBossHighIntensedBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kSecondBossNormalIntensedBullet:
            return CGVectorMake(0.0, -400.0);
            break;
        case kSecondBossHighIntensedBullet:
            return CGVectorMake(0.0, -450.0);
            break;
        case kSecondBossExtremeIntensedBullet:
            return CGVectorMake(0.0, -400.0);
            break;
        case kThirdBossNormalIntensedBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kThirdBossHighIntensedBullet:
            return CGVectorMake(0.0, -300.0);
            break;
        case kFourthBossNormalIntensedBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kFourthBossHighIntensedBullet:
            return CGVectorMake(0.0, -800.0);
            break;
        case kFourthBossExtremeIntensedBullet:
            return CGVectorMake(0.0, -350.0);
            break;
        case kFourthBossUltimateIntensedBullet:
            return CGVectorMake(0.0, -450.0);
            break;
    }
}

+ (CGFloat)damageForType:(BulletType)type {
    // EFFECTS: Get default damage for a bullet type
    
    return 0;
}

#pragma mark - Load shared assets
+ (void)loadSharedAssets {
    // EFFECTS: Load all the shared assets that any instances of this class will use
    
    [super loadSharedAssets];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        atlas = [SKTextureAtlas atlasNamed:@"bullet"];
        sRemoveFromSceneAction = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.3],
                                                      [SKAction removeFromParent]]];
    });
}

static SKTextureAtlas *atlas;
+ (SKTextureAtlas *)sTextureAtlas {
    // EFFECTS: Get the shared atlas for loading enemies
    
    return atlas;
}

static SKAction* sRemoveFromSceneAction = nil;
- (SKAction*)removeFromSceneAction{
    return sRemoveFromSceneAction;
}

@end
