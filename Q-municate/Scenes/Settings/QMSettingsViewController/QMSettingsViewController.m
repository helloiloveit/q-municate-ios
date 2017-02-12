//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMColors.h"
#import "QMUpdateUserViewController.h"
#import "QMImagePicker.h"
#import "QMTasks.h"
#import "QMCore.h"
#import "QMProfile.h"
#import <QMImageView.h>
#import "UINavigationController+QMNotification.h"
#import "QMSettingsFooterView.h"

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMImagePreview.h"

static const CGFloat kQMDefaultSectionHeaderHeight = 24.0f;
static const CGFloat kQMStatusSectionHeaderHeight = 40.0f;

typedef NS_ENUM(NSUInteger, QMSettingsSection) {
    
    QMSettingsSectionFullName,
    QMSettingsSectionOption,
    QMSettingsSectionTargetLanguage,
    QMSettingsSectionStatus,
    QMSettingsSectionMyLanguage,
    QMSettingsSectionStatistic,
    QMSettingsSectionUserInfo,
    QMSettingsSectionExtra,
    QMSettingsSectionSocial,
    QMSettingsSectionLogout
};

typedef NS_ENUM(NSUInteger, QMUserInfoSection) {
    
    QMUserInfoSectionPhone,
    QMUserInfoSectionEmail,
    QMUserInfoSectionChangePassword
};

typedef NS_ENUM(NSUInteger, QMUserStatSection) {
    
    QMUserInfoTeach,
    QMUserInfoLearn
};

typedef NS_ENUM(NSUInteger, QMSocialSection) {
    
    QMSocialSectionTellFriend,
    QMSocialSectionGiveFeedback
};

@interface QMSettingsViewController ()

<
QMProfileDelegate,
QMImageViewDelegate,
QMImagePickerResultHandler,

NYTPhotosViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *myLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *teachCount;
@property (weak, nonatomic) IBOutlet UILabel *learnCount;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segControlForOption;

- (IBAction)segOptionTapped:(id)sender;


@property (weak, nonatomic) BFTask *subscribeTask;
@property (weak, nonatomic) BFTask *logoutTask;


@property (strong, nonatomic) NSMutableIndexSet *hiddenUserInfoCells;

@end

@implementation QMSettingsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenUserInfoCells = [NSMutableIndexSet indexSet];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure user data
    [self configureUserData:[QMCore instance].currentProfile.userData];
    self.pushNotificationSwitch.on = [QMCore instance].currentProfile.pushNotificationsEnabled;
    
    // determine account type
    if ([QMCore instance].currentProfile.accountType != QMAccountTypeEmail) {
        
        [self.hiddenUserInfoCells addIndex:QMUserInfoSectionEmail];
        [self.hiddenUserInfoCells addIndex:QMUserInfoSectionChangePassword];
    }
    
    // subscribe to delegates
    [QMCore instance].currentProfile.delegate = self;
    self.avatarImageView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //update first record
    /*
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"User_data"; // your Class name
    
    
    // Object fields
    [object.fields setObject:@"Vietnamese" forKey:@"My_Lang"];
    [object.fields setObject:@9.1f forKey:@"rating"];
    [object.fields setObject:@NO forKey:@"documentary"];
    [object.fields setObject:@"fantasy" forKey:@"To_learn_lang"];
    [object.fields setObject:@"Star Wars is an American epic space opera franchise consisting of a film series created by George Lucas." forKey:@"descriptions"];
    
    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // do something when object is successfully created on a server
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
    // end
     */
     
    
    
    // Update data that is not in profile
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    NSString *id_info = [[NSString alloc] initWithFormat:@"%d", [QMCore instance].currentProfile.userData.ID];
    [getRequest setObject:id_info forKey:@"user_id"];
     //[getRequest setObject:@"23762657" forKey:@"user_id"];
    // need to figure out why id_info is not correct
    
    
    // Update infor of language when app start
    [QBRequest objectsWithClassName:@"User_data" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        if ([objects count] ==0 )
        {
            NSLog(@" no element . Need to create first ");
            /*
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"User_data"; // your Class name
            
            
            // Object fields
            [object.fields setObject:@"Vietnamese" forKey:@"My_Lang"];
            [object.fields setObject:@"fantasy" forKey:@"To_learn_lang"];
            
            [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // do something when object is successfully created on a server
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
            */
        }
        QBCOCustomObject *obj = [objects objectAtIndex: 0];
        NSLog(@"print value %@",obj.fields[@"My_lang"]);
        NSDictionary *temp = obj.fields;
        // to cast to new object type to get data
        self.languageLabel.text = temp[@"To_learn_lang"];
        self.myLanguageLabel.text = temp[@"My_Lang"];
        //Teach
        if ([temp[@"Teach_Count"] length] != 0)
        {
            self.teachCount.text = temp[@"Teach_Count"];
        }
        else
        {
            self.teachCount.text = @"Teach: 0";
        }
        //Learn
        if ([temp[@"Learn_Count"] length] != 0)
        {
            self.learnCount.text = temp[@"Learn_Count"];
        }
        else
        {
            self.learnCount.text = @"Learn: 0";
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    
    // smooth rows deselection
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)configureUserData:(QBUUser *)userData {
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:userData.avatarUrl]
                              placeholder:[UIImage imageNamed:@"upic_avatarholder"]
                                  options:SDWebImageHighPriority
                                 progress:nil
                           completedBlock:nil];
    
    self.fullNameLabel.text = userData.fullName;
    
    //get data
    
   
 
    if (userData.phone.length > 0) {
        
        self.phoneLabel.text = userData.phone;
    }
    else {
        
        [self.hiddenUserInfoCells addIndex:QMUserInfoSectionPhone];
    }
    
    self.emailLabel.text = userData.email.length > 0 ? userData.email : NSLocalizedString(@"QM_STR_NONE", nil);
    
    self.statusLabel.text = userData.status.length > 0 ? userData.status : NSLocalizedString(@"QM_STR_NONE", nil);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUpdateUser]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        QMUpdateUserViewController *updateUserVC = navigationController.viewControllers.firstObject;
        updateUserVC.updateUserField = [sender unsignedIntegerValue];
    }
}

- (IBAction)pushNotificationSwitchPressed:(UISwitch *)sender {
    
    if (self.subscribeTask) {
        // task is in progress
        return;
    }
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
        
        [navigationController dismissNotificationPanel];
        
        return nil;
    };
    
    if (sender.isOn) {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager subscribeForPushNotifications] continueWithBlock:completionBlock];
    }
    else {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager unSubscribeFromPushNotifications] continueWithBlock:completionBlock];
    }
}

- (void)logout {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"QM_STR_LOGOUT_CONFIRMATION", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                      }]];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGOUT", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          @strongify(self);
                                                          if (self.logoutTask) {
                                                              // task is in progress
                                                              return;
                                                          }
                                                          
                                                          [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
                                                          
                                                          self.logoutTask = [[[QMCore instance] logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                                                              
                                                              [navigationController dismissNotificationPanel];
                                                              [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                                                              return nil;
                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMSettingsSectionUserInfo
        && [self.hiddenUserInfoCells containsIndex:indexPath.row]) {
        
        return CGFLOAT_MIN;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case QMSettingsSectionFullName:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldFullName)];
            break;
            
        case QMSettingsSectionStatus:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldStatus)];
            break;
        case QMSettingsSectionTargetLanguage:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldTargetLanguage)];
            break;
        case QMSettingsSectionMyLanguage:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldMyLanguage)];
            break;
            
        case QMSettingsSectionStatistic:
            
            switch (indexPath.row) {
                    
                case QMUserInfoTeach:
                    break;
                    
                case QMUserInfoLearn:
                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldEmail)];
                    break;
            }
            
            break;
            //[self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldMyLanguage)];
            
            break;
            
        case QMSettingsSectionUserInfo:
            
            switch (indexPath.row) {
                    
                case QMUserInfoSectionPhone:
                    break;
                    
                case QMUserInfoSectionEmail:
                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldEmail)];
                    break;
                    
                case QMUserInfoSectionChangePassword:
                    [self performSegueWithIdentifier:kQMSceneSeguePassword sender:nil];
                    break;
            }
            
            break;
            
        case QMSettingsSectionExtra:
            break;
            
        case QMSettingsSectionSocial:
            
            switch (indexPath.row) {
                    
                case QMSocialSectionTellFriend: {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    [self showShareControllerInCell:cell];
                    break;
                }
                    
                case QMSocialSectionGiveFeedback:
                    [self performSegueWithIdentifier:kQMSceneSegueFeedback sender:nil];
                    break;
            }
            
            break;
            
        case QMSettingsSectionLogout:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self logout];
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionStatus) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"Level", nil) uppercaseString];;
        
        return headerView;
    }
    if (section == QMSettingsSectionOption) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"Option", nil) uppercaseString];;
        
        return headerView;
    }
    if (section == QMSettingsSectionTargetLanguage) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"To learn", nil) uppercaseString];;
        
        return headerView;
    }
    if (section == QMSettingsSectionMyLanguage) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"My language", nil) uppercaseString];;
        
        return headerView;
    }
    if (section == QMSettingsSectionStatistic) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"Statistic", nil) uppercaseString];;
        
        return headerView;
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section {
    
    if (![self shouldShowHeaderForSection:section]) {
        
        return CGFLOAT_MIN;
    }
    
    if (section == QMSettingsSectionStatus) {
        
        return kQMStatusSectionHeaderHeight;
    }
    if (section == QMSettingsSectionOption) {
        
        return kQMStatusSectionHeaderHeight;
    }
    if (section == QMSettingsSectionTargetLanguage) {
        
        return kQMStatusSectionHeaderHeight;
    }
    if (section == QMSettingsSectionMyLanguage) {
        
        return kQMStatusSectionHeaderHeight;
    }
    if (section == QMSettingsSectionStatistic) {
        
        return kQMStatusSectionHeaderHeight;
    }
    return kQMDefaultSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionLogout) {
        
        QMSettingsFooterView *footerView = [[QMSettingsFooterView alloc]
                                            initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(tableView.frame),
                                                                     [QMSettingsFooterView preferredHeight])];
        
        return footerView;
    }
    
    return [super tableView:tableView viewForFooterInSection:section];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionLogout) {
        
        return [QMSettingsFooterView preferredHeight];
    }
    
    return CGFLOAT_MIN;
}

#pragma mark - QMProfileDelegate

- (void)profile:(QMProfile *)__unused currentProfile didUpdateUserData:(QBUUser *)userData {
    
    [self configureUserData:userData];
}

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    NSString *avatarURL = [QMCore instance].currentProfile.userData.avatarUrl;
    if (avatarURL.length > 0) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OPEN_IMAGE", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                              [QMImagePreview previewImageWithURL:[NSURL URLWithString:avatarURL] inViewController:self];
                                                          }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = imageView;
        alertController.popoverPresentationController.sourceRect = imageView.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    if (![[QMCore instance] isInternetConnected]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return;
    }
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUserImage:photo progress:nil] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.avatarImageView setImage:photo withKey:task.result.avatarUrl];
        }
        
        return nil;
    }];
}

#pragma mark - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.avatarImageView;
}

#pragma mark - Share View Controller

- (void)showShareControllerInCell:(UITableViewCell *)cell {
    
    NSArray *items = @[NSLocalizedString(@"QM_STR_SHARE_TEXT", nil)];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    if (activityViewController.popoverPresentationController) {
        // iPad support
        activityViewController.popoverPresentationController.sourceView = cell;
        activityViewController.popoverPresentationController.sourceRect = cell.bounds;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Helpers

- (BOOL)shouldShowHeaderForSection:(NSInteger)section {
    
    if (section == QMSettingsSectionFullName) {
        
        return NO;
    }
    
    if (section == QMSettingsSectionUserInfo
        && [self.hiddenUserInfoCells containsIndex:QMUserInfoSectionPhone]
        && [self.hiddenUserInfoCells containsIndex:QMUserInfoSectionEmail]) {
        
        return NO;
    }
    
    return YES;
}


- (IBAction)segOptionTapped:(id)sender {
    if(_segControlForOption.selectedSegmentIndex==0){
        NSLog(@"Set Mode To Learn");
        // save to db
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        //NSInteger *id_info = [QMCore instance].currentProfile.userData.ID;
        
        NSString *id_info = [[NSString alloc] initWithFormat:@"%d", [QMCore instance].currentProfile.userData.ID];
        
        
        [getRequest setObject:id_info forKey:@"user_id"];
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak UINavigationController *navigationController = self.navigationController;
        @weakify(self);
        [QBRequest objectsWithClassName:@"User_data" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            QBCOCustomObject *obj = [objects objectAtIndex: 0];
            
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"User_data";
            [object.fields setObject:@0 forKey:@"Operate_Mode"];
            object.ID = obj.ID;
            
            
            [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // object updated
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];

        
    }
    else if(_segControlForOption.selectedSegmentIndex==1){
         NSLog(@"Set Mode To Teach");
        // save to db
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        //NSInteger *id_info = [QMCore instance].currentProfile.userData.ID;
        
        NSString *id_info = [[NSString alloc] initWithFormat:@"%d", [QMCore instance].currentProfile.userData.ID];
        
        
        [getRequest setObject:id_info forKey:@"user_id"];
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak UINavigationController *navigationController = self.navigationController;
        @weakify(self);
        [QBRequest objectsWithClassName:@"User_data" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            QBCOCustomObject *obj = [objects objectAtIndex: 0];
            
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"User_data";
            [object.fields setObject:@1 forKey:@"Operate_Mode"];
            object.ID = obj.ID;
            
            
            [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // object updated
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];

    }
}
@end
