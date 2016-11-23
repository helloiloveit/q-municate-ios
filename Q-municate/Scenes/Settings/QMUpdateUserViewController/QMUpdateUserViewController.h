//
//  QMUpdateUserViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMUpdateUserField) {
    
    QMUpdateUserFieldNone,
    QMUpdateUserFieldFullName,
    QMUpdateUserFieldEmail,
    QMUpdateUserFieldStatus,
    QMUpdateUserFieldTargetLanguage,
    QMUpdateUserFieldMyLanguage
    
};

@interface QMUpdateUserViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (assign, nonatomic) QMUpdateUserField updateUserField;

@end
