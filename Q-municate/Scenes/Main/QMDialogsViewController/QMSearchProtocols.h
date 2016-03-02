//
//  QMSearchProtocols.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/2/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

@class QMTableViewDataSource;

@protocol QMSearchProtocol <NSObject>

@optional
- (QMTableViewDataSource *)searchDataSource;

@end

@protocol QMLocalSearchDataSourceProtocol <QMSearchProtocol>

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *dialogs;

@end

@protocol QMGlobalSearchDataSourceProtocol <QMSearchProtocol>

@end
