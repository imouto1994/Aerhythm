//
//  PlayScene+PlayerMovement.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 11/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "PlayScene+PlayerMovement.h"
#import "PlayerJet.h"
#import "Vector2D.h"

#define kBoundaryTolerance 5
#define kLeftOffset 15
#define kRightOffset 15
#define kBottomOffset 15
#define kTopOffset 15

typedef NS_ENUM(NSUInteger, MoveDirection) {
    kTowardLeft,
    kTowardRight,
    kNearlyVertical,
};

@implementation PlayScene (PlayerMovement)

CGPoint _prevPanPoint;

#pragma mark - Pan Gesture Handler
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // REQUIRES: self != nil, self.playerJet != nil
    // MODIFIES: self.playerJet
    // EFFECTS: Handles user pan gesture to move the player jet
    
    if (recognizer.state == UIGestureRecognizerStateBegan || self.playerJet.isShocked) {
        _prevPanPoint = [recognizer locationInView:self.view];
        _prevPanPoint = [self convertPointFromView:_prevPanPoint];
        // Player jet can't move when being shocked
        if (self.playerJet.isShocked) {
            return;
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint currentLocation = [recognizer locationInView:self.view];
        currentLocation = [self convertPointFromView:currentLocation];
        Vector2D * translationVector = [Vector2D vectorFromPoint:_prevPanPoint toPoint:currentLocation];
        MoveDirection moveDirection = [self getMoveDirection:translationVector];
        if (moveDirection == kTowardLeft) {
            self.playerJet.currentState = STATE_TURN_LEFT;
        } else if (moveDirection == kTowardRight) {
            self.playerJet.currentState = STATE_TURN_RIGHT;
        }
        
        translationVector = [self preprocessTranslationVector:translationVector];
        
        CGPoint newPosition = [translationVector applyVectorTranslationToPoint:self.playerJet.position];
        if (![self isEntirePlayerJetVisible:newPosition]) {
            translationVector = [self handleBoundaryMovementWithTranslationVector:translationVector];
            newPosition = [translationVector applyVectorTranslationToPoint:self.playerJet.position];
        }
        
        self.playerJet.position = newPosition;
        [self acceleratePlayerTailEmitterWithMovementVector:translationVector];
        _prevPanPoint = currentLocation;
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.playerJet.currentState = STATE_DEFAULT;
        [self resetPlayerTailEmitterAcceleration];
    }
}

- (BOOL)isEntirePlayerJetVisible:(CGPoint)newPosition
{
    // REQUIRES: self != nil
    // EFFECTS: Returns true if the player jet centers at the input position, the entire player jet
    //          will be visible in the game scene
    
    newPosition = [self convertPoint:newPosition fromNode:[self getWorldLayer:kPlayerLayer]];
    CGFloat rightMost = newPosition.x + self.playerJet.bodySize.width / 2;
    CGFloat leftMost = newPosition.x - self.playerJet.bodySize.width / 2;
    CGFloat topMost = newPosition.y + self.playerJet.bodySize.height / 2;
    CGFloat bottomMost = newPosition.y - self.playerJet.bodySize.height / 2;
    
    if (leftMost < kLeftOffset || bottomMost < kBottomOffset ||
        rightMost > self.view.frame.size.width - kRightOffset ||
        topMost > self.view.frame.size.height - kHeightHPBar - kTopOffset) {
        return NO;
    }
    
    return YES;
}

- (Vector2D *)handleBoundaryMovementWithTranslationVector:(Vector2D *)translationVector {
    // REQUIRES: self != nil, self.playerJet != nil
    // EFFECTS: Recalculates the movement translation vector of a player jet around scene boundary
    //          so that the entire jet is still visible and the movement is smooth
    
    CGPoint newPosition = [translationVector applyVectorTranslationToPoint:self.playerJet.position];
    newPosition = [self convertPoint:newPosition fromNode:[self getWorldLayer:kPlayerLayer]];
    CGFloat rightMost = newPosition.x + self.playerJet.bodySize.width / 2;
    CGFloat leftMost = newPosition.x - self.playerJet.bodySize.width / 2;
    CGFloat topMost = newPosition.y + self.playerJet.bodySize.height / 2;
    CGFloat bottomMost = newPosition.y - self.playerJet.bodySize.height / 2;
    
    CGPoint correctedPosition = newPosition;
    if (leftMost < kLeftOffset) {
        correctedPosition.x = self.playerJet.bodySize.width / 2 + kLeftOffset;
    }
    if (rightMost > self.view.frame.size.width - kRightOffset) {
        correctedPosition.x = self.view.frame.size.width - kRightOffset - self.playerJet.bodySize.width / 2;
    }
    if (bottomMost < kBottomOffset) {
        correctedPosition.y = self.playerJet.bodySize.height / 2 + kBottomOffset;
    }
    if (topMost > self.view.frame.size.height - kHeightHPBar - kTopOffset) {
        correctedPosition.y = self.view.frame.size.height - kHeightHPBar - kTopOffset -
                              self.playerJet.bodySize.height / 2;
    }
    
    correctedPosition = [[self getWorldLayer:kPlayerLayer] convertPoint:correctedPosition fromNode:self];
    
    return [Vector2D vectorFromPoint:self.playerJet.position toPoint:correctedPosition];
}

- (MoveDirection)getMoveDirection:(Vector2D *)direction
{
    // REQUIRES: self != nil
    // EFFECTS: Determines the player jet movement direction (either left, right, or vertical)
    
    if ([direction isZero]) {
        return kNearlyVertical;
    }
    
    Vector2D * unitDirection = [direction scalarMultiply:1.0 / direction.length];
    
    CGFloat COS_70 = cos(M_PI / 180.0 * 70);
    CGFloat COS_110 = cos(M_PI / 180.0 * 110);
    
    Vector2D * rightUnitVector = [Vector2D vectorWithX:1 andY:0];
    CGFloat dotProduct = [rightUnitVector dotProduct:unitDirection];
    
    if (dotProduct > COS_110 && dotProduct < COS_70) {
        return kNearlyVertical;
    }
    if (dotProduct > 0) {
        return kTowardRight;
    }
    
    return kTowardLeft;
}

- (Vector2D *)preprocessTranslationVector:(Vector2D *)translationVector
{
    // REQUIRES: self != nil
    // EFFECTS: Preprocesses the input translation vector (e.g. increases its length by some factor,
    //          makes it vertical or horizontal if it is nearly vertical or nearly horizontal)
    
    if ([translationVector isZero]) {
        return translationVector;
    }
    
    CGFloat length = translationVector.length;
    length = 1.3 * length;
    
    Vector2D * unitDirection = [translationVector normalize];
    Vector2D * leftVector = [Vector2D vectorWithX:-1 andY:0];
    Vector2D * rightVector = [Vector2D vectorWithX:1 andY:0];
    Vector2D * upVector = [Vector2D vectorWithX:0 andY:1];
    Vector2D * downVector = [Vector2D vectorWithX:0 andY:-1];
    
    CGFloat COS_10 = cos(M_PI / 180.0 * 10);
    if ([leftVector dotProduct:unitDirection] > COS_10) {
        return [leftVector scalarMultiply:length];
    }
    if ([rightVector dotProduct:unitDirection] > COS_10) {
        return [rightVector scalarMultiply:length];
    }
    if ([upVector dotProduct:unitDirection] > COS_10) {
        return [upVector scalarMultiply:length];
    }
    if ([downVector dotProduct:unitDirection] > COS_10) {
        return [downVector scalarMultiply:length];
    }
    
    return [[translationVector normalize] scalarMultiply:length];
}

- (void)acceleratePlayerTailEmitterWithMovementVector:(Vector2D*)transitionVector {
    CGFloat amplifyFactor = 100;
    
    CGFloat xAmplifyTerm = 0;
    CGFloat yAmplifyTerm = 0;
    if (self.playerJet.currentState == STATE_TURN_LEFT){
        xAmplifyTerm = -4;
        yAmplifyTerm = -4;
    }
    else if (self.playerJet.currentState == STATE_TURN_RIGHT){
        xAmplifyTerm = 4;
        yAmplifyTerm = -4;
    }
    
    self.playerJet.tailEmitter.xAcceleration = -(transitionVector.x + xAmplifyTerm) * amplifyFactor;
    self.playerJet.tailEmitter.yAcceleration = -(transitionVector.y + yAmplifyTerm) * amplifyFactor;
    
}

- (void)resetPlayerTailEmitterAcceleration {
    self.playerJet.tailEmitter.xAcceleration = 0;
    self.playerJet.tailEmitter.yAcceleration = 0;
}

@end
