#import "Onset.h"

#define MINIMUM_RATE 0
#define VERY_WEAK_UPPER 12500
#define WEAK_UPPER 25000
#define WEAKER_MEDIUM_UPPER 42500
#define MEDIUM_UPPER 72500
#define STRONGER_MEDIUM_UPPER 100000
#define STRONG_UPPER 125000

@interface Onset()

// The time of the onset in the audio file
@property (nonatomic, readwrite) double time;
// The strength of the onset
@property (nonatomic, readwrite) OnsetStrength strength;

@end

@implementation Onset

- (id)init{
    // MODIFIES: self
    // EFFECTS: Override the init() method from the superclass
    
    return [self initWithTime:0 andRate:0];
}

- (id)initWithTime:(double)time andRate:(NSArray *)onsetRate{
    // MODIFIES: self
    // EFFECTS: Initialize method with the given time and onset rate
    
    self = [super init];
    if(self){
        _time = time;
       _strength = [Onset getAverageStrength:onsetRate];
    }
    return self;
}

+ (OnsetStrength)getAverageStrength:(NSArray *)onsetRate{
    // EFFECTS: Second method to determine strength for an onset
    
    double rate = 0;
    double total = 0;
    for(NSNumber *rate in onsetRate){
        total += [rate doubleValue];
    }
    if((int)[onsetRate count] > 0){
        rate = total / [onsetRate count];
    }

    return [Onset getStrength:rate];
}

+ (OnsetStrength)getStrength:(double) rate{
    // EFFECTS: Get the strength according to the given rate
    
    if(MINIMUM_RATE <= rate && rate < VERY_WEAK_UPPER){
        return VERY_WEAK;
    } else if(rate < WEAK_UPPER){
        return WEAK;
    } else if(rate < WEAKER_MEDIUM_UPPER){
        return WEAKER_MEDIUM;
    } else if(rate < MEDIUM_UPPER){
        return MEDIUM;
    } else if(rate < STRONGER_MEDIUM_UPPER){
        return STRONGER_MEDIUM;
    } else if(rate < STRONG_UPPER){
        return STRONG;
    } else{
        return VERY_STRONG;
    }
}

@end
