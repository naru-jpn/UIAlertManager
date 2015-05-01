
#import "ViewController.h"
#import "UIAlertManager.h"

@implementation ViewController

#pragma mark - action

- (void)onAlertButtonClicked:(id)sender {
    NSString *title = @"Alert title";
    NSString *message = @"Alert message";
    // actions
    UIAlertManagedAction *action1 = [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 1");
    }];
    UIAlertManagedAction *action2 = [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 2");
    }];
    UIAlertManagedAction *cancel = [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
    }];
    // create manager
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [manager showInViewController:self actions:@[action1, action2, cancel] completion:nil];
}

- (void)onTextFieldsAlertButtonClicked:(id)sender {
    NSString *title = @"Alert title";
    NSString *message = @"Alert message";
    // actions
    UIAlertManagedAction *login = [UIAlertManagedAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSArray *textFields = info[UIAlertInfoTextFields];
        NSLog(@"UserID  : %@", [textFields[0] text]);
        NSLog(@"Password: %@", [textFields[1] text]);
    }];
    UIAlertManagedAction *cancel = [UIAlertManagedAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
    }];
    // textfield configuration handler
    void (^configurationHandler)(NSArray *textFields) = ^(NSArray *textFields) {
        UITextField *textField = (UITextField *)textFields.firstObject;
        [textField setPlaceholder:@"UserID"];
    };
    // enable action handler
    BOOL (^enableActionHandler)(NSArray *textFields) = ^(NSArray *textFields) {
        UITextField *userName = (UITextField *)textFields[0];
        UITextField *password = (UITextField *)textFields[1];
        return (BOOL)((userName.text.length > 0) && (password.text.length > 0));
    };
    // create manager
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [manager setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [manager setConfigurationHandler:configurationHandler];
    [manager setEnableActionHandler:enableActionHandler];
    [manager showInViewController:self actions:@[login, cancel] completion:nil];
}

- (void)onActionSheetButtonClicked:(id)sender {
    NSString *title = @"Action sheet title";
    NSString *message = @"Action sheet message";
    // actions
    UIAlertManagedAction *destructive = [UIAlertManagedAction actionWithTitle:@"destructive" style:UIAlertActionStyleDestructive handler:^(NSDictionary *info){
        NSLog(@"destructive");
    }];
    UIAlertManagedAction *action1 = [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 1");
    }];
    UIAlertManagedAction *action2 = [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 2");
    }];
    UIAlertManagedAction *cancel = [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
    }];
    // create manager
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [manager showInViewController:self actions:@[destructive, action1, action2, cancel] completion:nil];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize buttonSize = CGSizeMake(200, 44);
    
    // add alert button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((CGRectGetWidth(self.view.frame)-buttonSize.width)/2, 80, buttonSize.width, buttonSize.height)];
    [button setTitle:@"Alert" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onAlertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // add alert (textfileds) button
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((CGRectGetWidth(self.view.frame)-buttonSize.width)/2, 160, buttonSize.width, buttonSize.height)];
    [button setTitle:@"Alert (textfields)" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTextFieldsAlertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // add action sheet button
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((CGRectGetWidth(self.view.frame)-buttonSize.width)/2, 240, buttonSize.width, buttonSize.height)];
    [button setTitle:@"Action sheet" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onActionSheetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

@end
