//
//  Connectivity.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 12/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface Connectivity : NSObject

+ (BOOL) hasInternetConnection;
// EFFECTS: Returns true if the internet connection appears to be online
//          Returns false otherwise

@end
