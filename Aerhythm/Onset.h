#import <Foundation/Foundation.h>

// The strength of the onset
typedef NS_ENUM(NSInteger, OnsetStrength){
    VERY_WEAK = 0,
    WEAK,
    WEAKER_MEDIUM,
    MEDIUM,
    STRONGER_MEDIUM,
    STRONG,
    VERY_STRONG
};

@interface Onset : NSObject
// OVERVIEW: This is an instance of the onset data at a particular time in the song

// The time that the onset data is processed
@property (nonatomic, readonly) double time;
// The rate of the processed data
@property (nonatomic, readonly) OnsetStrength strength;

-(id) initWithTime:(double)time andRate:(NSArray *)onsetRate;
// MODIFIES: self
// EFFECTS: Initialize method with the given time and onset rate

@end
