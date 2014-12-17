//
//  DesignLevelCell.h
//  Aerhythm
//
//  Created by Bui Trong Nhan on 6/23/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DesignLevelCellDelegate <NSObject>
@required
- (void)setEnemyTypeAtRow:(NSNumber *)row AndColumn:(NSNumber *)column;
@end

@interface DesignLevelCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) id <DesignLevelCellDelegate> delegate;
@property (nonatomic) NSInteger row;
@property (nonatomic) NSInteger column;

@end
