//
//  QMUpdateUserViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUpdateUserViewController.h"
#import "QMCore.h"
#import "QMProfile.h"
#import "QMShadowView.h"
#import "QMTasks.h"
#import "UINavigationController+QMNotification.h"

static const NSUInteger kQMFullNameFieldMinLength = 3;

@interface QMUpdateUserViewController ()



@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (copy, nonatomic) NSString *bottomText;
@property (weak, nonatomic) BFTask *task;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation QMUpdateUserViewController

NSArray *pickerData;

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    NSAssert(_updateUserField != QMUpdateUserFieldNone, @"Must be a valid update field.");
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    // configure appearance
    [self configureAppearance];
    
    
    // Connect data
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self.textField becomeFirstResponder];
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[row];
}


- (void)configureAppearance {
    
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    
    switch (self.updateUserField) {
            
        case QMUpdateUserFieldFullName:
            [self configureWithKeyPath:@keypath(QBUUser.new, fullName)
                                 title:NSLocalizedString(@"QM_STR_FULLNAME", nil)
                                  text:currentUser.fullName
                            bottomText:NSLocalizedString(@"QM_STR_FULLNAME_DESCRIPTION", nil)];
            break;
            
        case QMUpdateUserFieldEmail:
            [self configureWithKeyPath:@keypath(QBUUser.new, email)
                                 title:NSLocalizedString(@"QM_STR_EMAIL", nil)
                                  text:currentUser.email
                            bottomText:NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil)];
            pickerData = @[@"English",@"Vietnamese"];
            break;
            
        case QMUpdateUserFieldStatus:
            [self configureWithKeyPath:@keypath(QBUUser.new, status)
                                 title:NSLocalizedString(@"QM_STR_STATUS", nil)
                                  text:currentUser.status
                            bottomText:NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil)];
            pickerData = @[@"Beginner",@"Intermediate", @"Fluent"];
            break;
            
        case QMUpdateUserFieldNone:
            break;
    }
}

- (void)configureWithKeyPath:(NSString *)keyPath
                       title:(NSString *)title
                        text:(NSString *)text
                  bottomText:(NSString *)bottomText {
    
    self.keyPath = keyPath;
    self.title =
   // self.textField.placeholder = title;
    self.cachedValue =
  //  self.textField.text = text;
    //self.bottomText = bottomText;
    self.bottomText = @"Info about your language level";
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.task != nil) {
        // task is in progress
        return;
    }
    // Huy add. to get value of from picker
    NSInteger row;
    NSString *strPrintRepeat;
    row = [self.picker selectedRowInComponent:0];
    strPrintRepeat = [pickerData objectAtIndex:row];
    
    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    updateUserParams.customData = [QMCore instance].currentProfile.userData.customData;
    //[updateUserParams setValue:self.textField.text forKeyPath:self.keyPath];
    [updateUserParams setValue:strPrintRepeat forKeyPath:self.keyPath];
    
    //huy test code
    // Create note
    // select record by user
    // if not existed . create a record
    // if existed update info
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
     */
    
    

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"19812866" forKey:@"user_id"];

    
    [QBRequest objectsWithClassName:@"User_data" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        id obj = [objects objectAtIndex: 0];

        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"User_data";
        [object.fields setObject:@"7.90" forKey:@"rating"];
        object.ID = @"502f7c4036c9ae2163000002";
        
        
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            // object updated
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    
    /*
NSString *id_info = [[NSString alloc] initWithFormat:@"%d", 123];
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"User_data";
    [object.fields setObject:@"7.90" forKey:@"rating"];
    object.ID = @"502f7c4036c9ae2163000002";
    
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
    */
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUser:updateUserParams] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

- (IBAction)textFieldEditingChanged:(UITextField *)__unused sender {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Helpers



#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView titleForFooterInSection:(NSInteger)__unused section {
    
    return self.bottomText;
}

@end
