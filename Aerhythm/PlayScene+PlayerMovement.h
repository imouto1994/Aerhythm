//
//  PlayScene+PlayerMovement.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 11/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "PlayScene.h"

@interface PlayScene (PlayerMovement)

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
// REQUIRES: self != nil
// MODIFIES: self.jetNode
// EFFECTS: Handles user pan gesture to move the player jet

@end
