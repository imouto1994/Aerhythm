#import "GameObject.h"
#import "Constant.h"

#define kDefaultBulletSize 64

@interface Bullet : GameObject
// OVERIVEW: This is the class for bullet objects in the game. However, this is just an abstract class.
// To use this, we should use its subclasses which are PlayerBullet and EnemyBullet

// The bullet type
@property (nonatomic, readonly) BulletType bulletType;
// The origin of the bullet, whether it is from the player or te enmy
@property (nonatomic, readonly) NSInteger bulletOriginType;
// The damage of the bullet
@property (nonatomic, readonly) CGFloat damage;
// The radius of the bullet
@property (nonatomic, readonly) CGFloat radius;
// The original velocity of the bullet
@property (nonatomic, readonly) CGVector originalVelocity;


- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type and its origin

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
             andRadius:(CGFloat) radius
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type, radius and its origin

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity and its origin

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
             andRadius:(CGFloat) radius
           andVelocity:(CGVector)velocity
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type, radius, velocity and its origin

- (void)addSpecialVisualEffect;
// MODIFIES: self
// EFFECTS: Add special visual effect for a specific bullet according to its bullet type

+ (CGVector)getDefaultVelocity:(BulletType)bulletType;
// EFFECTS: Get the default velocity according to the bullet type

+ (CGFloat)getDefaultRadiusSize:(BulletType)bulletType;
// EFFECTS: Gets default radius size for the input bullet type

+ (CGFloat)damageForType:(BulletType)type;
// EFFECTS: Get default damage for a bullet type

- (SKTexture *) determineTexture;
// EFFECTS: Get the corresponding texture for the current bullet type of the bullet

+ (SKTextureAtlas *)sTextureAtlas;
// EFFECTS: Get the shared atlas among bullets

@end
