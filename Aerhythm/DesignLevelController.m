#import <QuartzCore/QuartzCore.h>
#import "DesignLevelController.h"
#import "DesignLevelCell.h"
#import "Utilities.h"
#import "EnemyFactory.h"

#define NUM_ROWS_PER_PAGE 16
#define NUM_COLS_PER_PAGE 12
#define NUM_PAGES 6

#define DEFAULT_ENEMY_INDEX 0
#define FIRE_ENEMY_INDEX 1
#define ICE_ENEMY_INDEX 2
#define NINJA_ENEMY_INDEX 3
#define BOMB_ENEMY_INDEX 4
#define GEM_ENEMY_INDEX 5
#define LIGHTNING_ENEMY_INDEX 6
#define REMOVE_ENEMY_INDEX 7

static NSString * const DesignLevelCellIdentifier = @"DesignLevelCellIdentifier";


@interface DesignLevelController ()

@end

@implementation DesignLevelController{
    UIImageView *backgroundImageView;
    NSMutableArray *selectImageViews;
    EnemyType currentEnemyType;
}

- (void) viewDidLoad{
    [super viewDidLoad];
    [self.cellsCollectionView registerClass:[DesignLevelCell class] forCellWithReuseIdentifier:DesignLevelCellIdentifier];
    self.saveButton.transform = CGAffineTransformMakeRotation(M_PI);
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIImage *backImage = [Utilities loadImageWithName:@"blueBackButton"];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.saveButton setImage:backImage forState:UIControlStateNormal];
    
    NSInteger randomLevel = arc4random() % 4 + 1;
    NSInteger randomPage = arc4random() % 6 + 1;
    
    UIImage *backgroundImage = [Utilities loadImageWithName:[NSString stringWithFormat:@"level%ld-%ld", randomLevel, randomPage]];
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    [backgroundImageView setImage:backgroundImage];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    selectImageViews = [NSMutableArray array];
    for(int i = 0; i < 8; i++){
        UIImage *selectImage;
        switch (i) {
            case DEFAULT_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-default"];
                break;
            case FIRE_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-fire"];
                break;
            case ICE_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-ice"];
                break;
            case NINJA_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-ninja"];
                break;
            case BOMB_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-bomb"];
                break;
            case GEM_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-gem"];
                break;
            case LIGHTNING_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"enemy-lightning"];
                break;
            case REMOVE_ENEMY_INDEX:
                selectImage = [Utilities loadImageWithName:@"removeButton"];
                break;
            default:
                selectImage = nil;
                break;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 75, 0, 75, 75)];
        [imageView setImage:selectImage];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectEnemyType:)];
        [imageView setUserInteractionEnabled:true];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        [self.selectPanel addSubview:imageView];
        [selectImageViews addObject:imageView];
    }
    
    currentEnemyType = kNoEnemy;
    self.map = [[NSMutableArray alloc] init];
    for (int i = 0; i < NUM_PAGES * NUM_ROWS_PER_PAGE; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        for (int j = 0; j < NUM_COLS_PER_PAGE; j++) {
            [row addObject:@0];
        }
        [self.map addObject:row];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.saveButton setImage:nil forState:UIControlStateNormal];
    
    [backgroundImageView setImage:nil];
    [backgroundImageView removeFromSuperview];
    
    for(UIImageView *imageView in selectImageViews){
        [imageView setImage:nil];
        [imageView removeFromSuperview];
    }
}

#pragma mark - Data Source Protocol

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return NUM_COLS_PER_PAGE * NUM_ROWS_PER_PAGE * NUM_PAGES;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DesignLevelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DesignLevelCellIdentifier forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.delegate = self;
    
    NSInteger row = indexPath.section / NUM_COLS_PER_PAGE;
    NSInteger column = indexPath.section % NUM_COLS_PER_PAGE;
    cell.row = row;
    cell.column = column;
    
    EnemyType enemyType = [[[self.map objectAtIndex:row] objectAtIndex:column] intValue];
    UIImage *image;
    
    switch (enemyType) {
        case kDefaultEnemy:
            image = [Utilities loadImageWithName:@"enemy-default"];
            break;
        case kFireEnemy:
            image = [Utilities loadImageWithName:@"enemy-fire"];
            break;
        case kIceEnemy:
            image = [Utilities loadImageWithName:@"enemy-ice"];
            break;
        case kNinjaEnemy:
            image = [Utilities loadImageWithName:@"enemy-ninja"];
            break;
        case kSuicideEnemy:
            image = [Utilities loadImageWithName:@"enemy-bomb"];
            break;
        case kRockEnemy:
            image = [Utilities loadImageWithName:@"enemy-gem"];
            break;
        case kShockEnemy:
            image = [Utilities loadImageWithName:@"enemy-lightning"];
            break;
        default:
            image = nil;
            break;
    }
    
    [cell.imageView setImage:image];

    return cell;
}

#pragma mark - Gesture handlers

- (void)selectEnemyType:(UITapGestureRecognizer *)gesture {
    UIView *lastTappedView = gesture.view;
    for (int i = 0; i < 7; i++) {
        if (selectImageViews[i] == lastTappedView) {
            switch (i) {
                case 0:
                    currentEnemyType = kDefaultEnemy;
                    break;
                case 1:
                    currentEnemyType = kFireEnemy;
                    break;
                case 2:
                    currentEnemyType = kIceEnemy;
                    break;
                case 3:
                    currentEnemyType = kNinjaEnemy;
                    break;
                case 4:
                    currentEnemyType = kSuicideEnemy;
                    break;
                case 5:
                    currentEnemyType = kRockEnemy;
                    break;
                case 6:
                    currentEnemyType = kShockEnemy;
                    break;
                default:
                    break;
            }
        }
    }
}


#pragma mark - Delegate Protocol

- (void)setEnemyTypeAtRow:(NSNumber *)row AndColumn:(NSNumber *)column {
    [[self.map objectAtIndex:[row intValue]] setObject:[NSNumber numberWithInteger:currentEnemyType] atIndex:[column intValue]];
    NSIndexSet *sections = [[NSIndexSet alloc] initWithIndex:[row intValue] * NUM_COLS_PER_PAGE + [column intValue]];
    [self.cellsCollectionView reloadSections:sections];
}

@end
