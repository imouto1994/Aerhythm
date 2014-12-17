#import "GameStatistics.h"

static NSString * const kLevelIdKey = @"levelId";
static NSString * const kScoreKey = @"score";
static NSString * const kSongNameKey = @"songName";
static NSString * const kSongArtistKey = @"songArtist";
static NSString * const kUsedModelTypeKey = @"usedModelType";
static NSString * const kIsWonKey = @"isWon";
static NSString * const kOfflineStatisticsKey = @"offlineStatistics";

@implementation GameStatistics

- (id)initWithLevelId:(NSUInteger)levelId {
    // MODIFIES: self
    // EFFECTS: Initializes self to be an object containing game statistics for the input level.
    
    self = [super init];
    
    if (self) {
        self.levelId = levelId;
        self.score = 0;
        self.songName = @"";
        self.songArtist = @"";
        self.usedModelType = kOriginal;
        self.isWon = NO;
    }
    
    return self;
}

- (id)initWithGameStatistics:(GameStatistics *)otherGameStatistics {
    // REQUIRES: otherGameStatistics != nil
    // MODIFIES: self
    // EFFECTS: Initializes self to be an object containing the same game statistics as the input
    //          object.
    
    self = [super init];
    if (self) {
        if (otherGameStatistics) {
            self.levelId = otherGameStatistics.levelId;
            self.score = otherGameStatistics.score;
            self.songName = otherGameStatistics.songName;
            self.songArtist = otherGameStatistics.songArtist;
            self.usedModelType = otherGameStatistics.usedModelType;
            self.isWon = otherGameStatistics.isWon;
        } else {
            self = [self initWithLevelId:1];
        }
    }
    
    return self;
}

+ (NSString*)statisticsFilePathForLevel:(NSInteger)levelId{
    // EFFECTS: Gets the path of file containing the offline statistics of the input level
    
    NSArray * pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    NSString * documentPath = [pathList objectAtIndex:0];
    NSString * filePath = [documentPath stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"Stat-Level-%lu.td", (unsigned long) levelId]];
    return filePath;
}

- (id)initWithCoder:(NSCoder *)decoder{
    // MODIFIES: self
    // EFFECTS: Initializes a new GameStatistics object with input decoder
    
    self = [super init];
    
    if (self) {
        self.levelId = [decoder decodeIntegerForKey:kLevelIdKey];
        self.score = [decoder decodeFloatForKey:kScoreKey];
        self.songName = [decoder decodeObjectForKey:kSongNameKey];
        self.songArtist = [decoder decodeObjectForKey:kSongArtistKey];
        self.usedModelType = (PlayerJetType)[decoder decodeIntegerForKey:kUsedModelTypeKey];
        self.isWon = [decoder decodeBoolForKey:kIsWonKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    // REQUIRES: self != nil
    // EFFECTS: encodes the GameStatistics object self
    
    [coder encodeInteger:self.levelId forKey:kLevelIdKey];
    [coder encodeFloat:self.score forKey:kScoreKey];
    [coder encodeObject:self.songName forKey:kSongNameKey];
    [coder encodeObject:self.songArtist forKey:kSongArtistKey];
    [coder encodeInteger:(NSUInteger)self.usedModelType forKey:kUsedModelTypeKey];
    [coder encodeBool:self.isWon forKey:kIsWonKey];
}

+ (GameStatistics *)loadHighestOfflineStatisticsForLevel:(NSUInteger)levelId{
    // EFFECTS: Loads and returns the offline highest-score statistics of the input level
    //          Returns nil if there is no statistics for the input level
    
    NSString * path = [GameStatistics statisticsFilePathForLevel:levelId];
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (!data) {
        return nil;
    }
    
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GameStatistics * offlineStat = [unarchiver decodeObjectForKey:kOfflineStatisticsKey];
    [unarchiver finishDecoding];
    
    return offlineStat;
}

+ (void)updateOfflineStatisticsWithNewData:(GameStatistics *)newStatistics{
    // EFFECTS: Updates the stored offline highest-score statistics if the input new statistics data have
    //          higher score of if there is no stored statistics. The information whether the level
    //          is won is also updated.
    
    BOOL shouldUpdate = NO;
    NSUInteger levelId = newStatistics.levelId;
    GameStatistics * currentOfflineStat = [GameStatistics loadHighestOfflineStatisticsForLevel:levelId];
    GameStatistics * statForUpdate = [[GameStatistics alloc] initWithGameStatistics:currentOfflineStat];
    
    if (currentOfflineStat) {
        if (newStatistics.score > currentOfflineStat.score) {
            statForUpdate = [[GameStatistics alloc] initWithGameStatistics:newStatistics];
            shouldUpdate = YES;
        }
        
        if (!currentOfflineStat.isWon && newStatistics.isWon) {
            statForUpdate.isWon = newStatistics.isWon;
            shouldUpdate = YES;
        }
    }

    if (!shouldUpdate) {
        return;
    }
    
    NSMutableData * data = [[NSMutableData alloc]init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:statForUpdate forKey:kOfflineStatisticsKey];
    [archiver finishEncoding];
    NSString * path = [GameStatistics statisticsFilePathForLevel:levelId];
    [data writeToFile:path atomically:YES];
}

@end
