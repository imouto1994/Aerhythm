#import <UIKit/UIKit.h>
#import "Constant.h"

@class GameUpgrade;

@protocol UpgradeCellDelegateProtocol <NSObject>
// OVERVIEW: This is the protocol for the delegate of UpgradeCell object to conform to. It is used to update the given type of power-up indicated by the upgrade cell.

-(void) upgradePowerupForPowerupType:(PowerupType)powerupType;

@end

@interface UpgradeCell : UITableViewCell
// OVERVIEW: This is the cell used for representing the current data of a type of power-up in the table in the Upgrade screen.

// The type of power-up
@property (nonatomic) NSInteger upgradeType;
// The rate of upgrading the specific power-up
@property (nonatomic) NSInteger upgradeRate;
// The delegate for this cell
@property (weak, nonatomic) id<UpgradeCellDelegateProtocol> delegate;

-(void) updateType:(NSInteger) upgradeType forCurrentUpgrade:(GameUpgrade *) currentUpgrade;
// REQUIRES: self != nil
// MODIFIES: self.upgradeType
// EFFECTS: Set the type of power-up for upgrading in this cell. Set the necessary data for display and the cost for the next upgrade basing on the current data of upgrading.

-(void) updateRate:(NSInteger) rate;
// REQUIRES: self != nil
// MODIFIES: self.upgradeRate
// EFFECTS: Update the rate of upgrading to the given rate

@end
