#import "DesignLevelLayout.h"

static NSString * const DesignLevelLayoutInfo = @"DesignLevelLayoutInfo";

@interface DesignLevelLayout()

@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation DesignLevelLayout

-(id) init{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}


-(void) setup{
    self.itemSize = CGSizeMake(64.0f, 64.0f);
    self.interItemSpacingY = 0.0;
    self.interItemSpacingX = 0.0;
    self.numColumns = 12;
}

#pragma mark - Layout Cells

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[DesignLevelLayoutInfo] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

-(CGRect) frameForCellAtIndexPath:(NSIndexPath *) indexPath{
    
    NSInteger row = indexPath.section / self.numColumns;
    NSInteger column = indexPath.section % self.numColumns;

    CGFloat originX = floorf(self.itemSize.width * column);
    
    CGFloat originY = floor(self.itemSize.height * row);
    
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

-(NSArray *) layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[DesignLevelLayoutInfo][indexPath];
}

- (CGSize)collectionViewContentSize{
    NSInteger rowCount = [self.collectionView numberOfSections] / self.numColumns;
    // make sure we count another row if one is only partially filled
    if ([self.collectionView numberOfSections] % self.numColumns) rowCount++;
    
    CGFloat height = rowCount * self.itemSize.height;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

@end
