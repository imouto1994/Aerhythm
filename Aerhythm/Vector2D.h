//
//  Vector2D.h
//  ps04
//
//  Created by Nguyen Truong Duy on 13/3/14.
//
//

#import <Foundation/Foundation.h>

/*
 This class represents an immutable 2-dimensional vector and supports baisc vector operations
 */

@interface Vector2D : NSObject {
    CGFloat _x;
    CGFloat _y;
}

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat length;

+ (Vector2D *)vectorWithX:(CGFloat)xCoord andY:(CGFloat)yCoord;
// EFFECTS: Factory method that creates a vector with x equals to `xCoord' and y equals to `yCoord'

+ (Vector2D *)zeroVector;
// EFFECTS: Factory method that creates a vector with x equals to 0 and y equals to 0

+ (Vector2D *)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
// EFFECTS: Factory method that creates a vector with start point `fromPoint' and end point
//          `toPoint'

+ (Vector2D *)vectorFromCGVector:(CGVector)cgVector;
// EFFECTS: Factory method that creates a vector equals to `cgVector'

- (id)init;
// MODIFIES: self
// EFFECTS: Initializes self to be a zero vector

- (id)initWithX:(CGFloat)xCoord andY:(CGFloat)yCoord;
// MODIFIES: self
// EFFECTS: Initializes self to be a vector with x equals to `xCoord' and y equals to `yCoord'

- (Vector2D *)scalarMultiply:(CGFloat)scalar;
// REQUIRES: self != nil
// EFFECTS: returns a vector which is a result of scalar multiplication of `scalar' and self

- (Vector2D *)add:(Vector2D *)anotherVector;
// REQUIRES: self != nil and anotherVector != nil
// EFFECTS: returns a vector which is a result of vector addition of `anotherVector' and self

- (Vector2D *)subtract:(Vector2D *)anotherVector;
// REQUIRES: self != nil and anotherVector != nil
// EFFECTS: returns a vector which is a result of vector subtraction of `anotherVector' and self

- (Vector2D *)negate;
// REQUIRES: self != nil
// EFFECTS: returns a vector which is a negation of self

- (CGFloat)dotProduct:(Vector2D *)anotherVector;
// REQUIRES: self != nil and anotherVector != nil
// EFFECTS: returns a dot product result of `anotherVector' and self

- (CGFloat)angleWithVector:(Vector2D *)anotherVector;
// REQUIRES: self != nil and anotherVector != nil
// EFFECTS: returns an angle (in radians) between `self' and `anotherVector'

- (Vector2D *)findProjectionOfVector:(Vector2D *) anotherVector;
// REQUIRES: self != nil and anotherVector != nil
// EFFECTS: returns a projection of `anotherVector' onto `self'

- (CGPoint)applyVectorTranslationToPoint:(CGPoint)point;
// REQUIRES: self != nil
// EFFECTS: returns a point after translating `point' with the vector self

- (Vector2D *)rotateWithAngle:(CGFloat)angleInDegree;
// REQUIRES: self != nil
// EFFECTS: returns a vector after rotating self with a counterclockwise angle `angleInDegree'

- (Vector2D *)reflectAroundMirrorVector:(Vector2D *)mirrorVector;
// REQUIRES: self != nil and mirrorVector != nil
// EFFECTS: returns a vector which is a reflection of `self' around mirror `mirrorVector'

- (BOOL)isZero;
// REQUIRES: self != nil
// EFFECTS: returns YES if `self' is a zero vector

- (CGFloat)squareLength;
// REQUIRES: self != nil
// EFFECTS: returns the square of the vector length

- (CGVector)toCGVector;
// REQUIRES: self != nil
// EFFECTS: returns a CGVector instance representing the same vector as self

- (Vector2D *)normalize;
// REQUIRES: self != nil
// EFFECTS: returns a unit vector parallel to self if self is not a zero vector
//          returns a zero vector otherwise

@end
