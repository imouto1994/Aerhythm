//
//  Connectivity.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 12/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "Connectivity.h"

@implementation Connectivity

+ (BOOL) hasInternetConnection {
    // EFFECTS: Returns true if the internet connection appears to be online
    //          Returns false otherwise
    
    Reachability * reachTest = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachTest currentReachabilityStatus];
    if (internetStatus != ReachableViaWiFi && internetStatus != ReachableViaWWAN) {
        return NO;
    }

    return YES;
}

@end
