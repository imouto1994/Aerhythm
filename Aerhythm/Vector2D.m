//
//  Vector2D.m
//  ps04
//
//  Created by Nguyen Truong Duy on 13/3/14.
//
//

#import "Vector2D.h"

@interface Vector2D ()

@property (nonatomic, readwrite) CGFloat x;
@property (nonatomic, readwrite) CGFloat y;
@property (nonatomic, readwrite) CGFloat length;

@end

@implementation Vector2D

+ (Vector2D *)vectorWithX:(CGFloat)xCoord andY:(CGFloat)yCoord {
    // EFFECTS: Factory method that creates a vector with x equals to `xCoord' and y equals to `yCoord'
    return [[Vector2D alloc] initWithX:xCoord andY:yCoord];
}

+ (Vector2D *)zeroVector {
    // EFFECTS: Factory method that creates a vector with x equals to 0 and y equals to 0
    return [[Vector2D alloc] init];
}

+ (Vector2D *)vectorFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    // EFFECTS: Factory method that creates a vector with start point `fromPoint' and end point
    //          `toPoint'
    CGFloat x = toPoint.x - fromPoint.x;
    CGFloat y = toPoint.y - fromPoint.y;
    return [Vector2D vectorWithX:x andY:y];
}

+ (Vector2D *)vectorFromCGVector:(CGVector)cgVector {
    // EFFECTS: Factory method that creates a vector equals to `cgVector'
    return [Vector2D vectorWithX:cgVector.dx andY:cgVector.dy];
}

- (id)init {
    // MODIFIES: self
    // EFFECTS: Initializes self to be a zero vector
    return [self initWithX:0 andY:0];
}

- (id)initWithX:(CGFloat)xCoord andY:(CGFloat)yCoord {
    // MODIFIES: self
    // EFFECTS: Initializes self to be a vector with x equals to `xCoord' and y equals to `yCoord'
    self = [super init];
    if (self) {
        self.x = xCoord;
        self.y = yCoord;
        self.length = sqrt(xCoord * xCoord + yCoord * yCoord);
    }
    return self;
}

- (Vector2D *)scalarMultiply:(CGFloat)scalar {
    // REQUIRES: self != nil
    // EFFECTS: returns a vector which is a result of scalar multiplication of `scalar' and self
    return [Vector2D vectorWithX:(scalar * self.x) andY:(scalar * self.y)];
}

- (Vector2D *)add:(Vector2D *)anotherVector {
    // REQUIRES: self != nil and anotherVector != nil
    // EFFECTS: returns a vector which is a result of vector addition of `anotherVector' and self
    return [Vector2D vectorWithX:(self.x + anotherVector.x)
                            andY:(self.y + anotherVector.y)];
}

- (Vector2D *)subtract:(Vector2D *)anotherVector {
    // REQUIRES: self != nil and anotherVector != nil
    // EFFECTS: returns a vector which is a result of vector subtraction of `anotherVector' and self
    return [Vector2D vectorWithX:(self.x - anotherVector.x)
                            andY:(self.y - anotherVector.y)];
}

- (Vector2D *)negate {
    // REQUIRES: self != nil
    // EFFECTS: returns a vector which is a negation of self
    return [Vector2D vectorWithX:-self.x andY:-self.y];
}

- (CGFloat)dotProduct:(Vector2D *)anotherVector {
    // REQUIRES: self != nil and anotherVector != nil
    // EFFECTS: returns a dot product result of `anotherVector' and self
    return self.x * anotherVector.x + self.y * anotherVector.y;
}

- (CGFloat)angleWithVector:(Vector2D *)anotherVector {
    // REQUIRES: self != nil and anotherVector != nil
    // EFFECTS: returns an angle (in radians) between `self' and `anotherVector'
    
    if ([self isZero] || [anotherVector isZero])
        return 0;
    return acos([self dotProduct:anotherVector] / (self.length * anotherVector.length));
}

- (Vector2D *)findProjectionOfVector:(Vector2D *) anotherVector {
    // REQUIRES: self != nil and anotherVector != nil
    // EFFECTS: returns a projection of `anotherVector' onto `self'
    if ([self isZero])
        return [Vector2D zeroVector];
    
    CGFloat scalar = [self dotProduct:anotherVector] / [self squareLength];
    return [self scalarMultiply:scalar];
}

- (CGPoint)applyVectorTranslationToPoint:(CGPoint)point {
    // REQUIRES: self != nil
    // EFFECTS: returns a point after translating `point' with the vector self
    return CGPointMake(point.x + self.x, point.y + self.y);
}

- (Vector2D *)reflectAroundMirrorVector:(Vector2D *)mirrorVector {
    // REQUIES: self != nil and mirrorVector != nil
    // EFFECTS: returns a vector which is a reflection of `self' around mirror `mirrorVector'
    
    if ([mirrorVector isZero])
        return [Vector2D vectorWithX:self.x andY:self.y];
    
    CGFloat reflectionScalar = 2.0 * [self dotProduct:mirrorVector] / ([mirrorVector squareLength]);
    return [self subtract:[mirrorVector scalarMultiply:reflectionScalar]];
}

- (BOOL)isZero {
    // REQUIRES: self != nil
    // EFFECTS: returns YES if `self' is a zero vector
    CGFloat EPSILON = 0.000001;
    return (self.length < EPSILON) ? YES : NO;
}

- (CGFloat)squareLength {
    // REQUIRES: self != nil
    // EFFECTS: returns the square of the vector length
    return self.x * self.x + self.y * self.y;
}

- (CGVector)toCGVector {
    // REQUIRES: self != nil
    // EFFECTS: returns a CGVector instance representing the same vector as self
    return CGVectorMake(self.x, self.y);
}

- (Vector2D *)normalize {
    // REQUIRES: self != nil
    // EFFECTS: returns a unit vector parallel to self if self is not a zero vector
    //          returns a zero vector otherwise
    if ([self isZero]) {
        return [Vector2D zeroVector];
    }
    
    return [self scalarMultiply:1 / self.length];
}

- (Vector2D *)rotateWithAngle:(CGFloat)angleInDegree {
    // REQUIRES: self != nil
    // EFFECTS: returns a vector after rotating self with a counterclockwise angle `angleInDegree'
    
    CGFloat newX = 0;
    CGFloat newY = 0;
    CGFloat radAngle = [self convertDegreeToRadian:angleInDegree];
    
    newX = self.x * cos(radAngle) - self.y * sin(radAngle);
    newY = self.x * sin(radAngle) + self.y * cos(radAngle);
    return [Vector2D vectorWithX:newX andY:newY];
}

- (CGFloat)convertDegreeToRadian:(CGFloat)degree {
    // REQUIRES: self != nil
    // EFFECTS: returns an equivalent angle in radians based on the input value in degrees
    
    return degree * M_PI / 180.0;
}

@end

