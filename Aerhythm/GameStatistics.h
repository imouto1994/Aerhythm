#import <Foundation/Foundation.h>
#import "Constant.h"

@interface GameStatistics : NSObject <NSCoding>
// OVERVIEW: This is the object used to keep track of the result the player gets for each level

// The chosen level index
@property (nonatomic) NSUInteger levelId;
// The final score
@property (nonatomic) CGFloat score;
// The name of used songs
@property (nonatomic, strong) NSString * songName;
// The artist of the used songs
@property (nonatomic, strong) NSString * songArtist;
// The type of player jet
@property (nonatomic) PlayerJetType usedModelType;
// A boolean value whether the level is cleared
@property (nonatomic) BOOL isWon;

- (id)initWithLevelId:(NSUInteger)levelId;
// MODIFIES: self
// EFFECTS: Initializes self to be an object containing game statistics for the input level.

- (id)initWithGameStatistics:(GameStatistics *)otherGameStatistics;
// REQUIRES: otherGameStatistics != nil
// MODIFIES: self
// EFFECTS: Initializes self to be an object containing the same game statistics as the input
//          object.

+ (GameStatistics *)loadHighestOfflineStatisticsForLevel:(NSUInteger)levelId;
// EFFECTS: Loads and returns the offline highest-score statistics of the input level
//          Returns nil if there is no statistics for the input level

+ (void)updateOfflineStatisticsWithNewData:(GameStatistics *)newStatistics;
// EFFECTS: Updates the stored offline highest-score statistics if the input new statistics data have
//          higher score, or if there is no stored statistics. The information whether the level
//          is won is also updated.

@end
