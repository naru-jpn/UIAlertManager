
#import "ViewController.h"
#import "UIAlertManager.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - action

- (void)onAlertButtonClicked:(id)sender {
    NSString *title = @"Alert title";
    NSString *message = @"Alert message";
    NSArray *actions = @[
        [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(UIAlertManagedAction *action){
            NSLog(@"clicked 1");
        }],
        [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(UIAlertManagedAction *action){
            NSLog(@"clicked 2");
        }],
        [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertManagedAction *action){
            NSLog(@"canceled");
        }]
    ];
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [manager showInViewController:self actions:actions completion:nil];
}

- (void)onActionSheetButtonClicked:(id)sender {
    NSString *title = @"Action sheet title";
    NSString *message = @"Action sheet message";
    NSArray *actions = @[
        [UIAlertManagedAction actionWithTitle:@"destructive" style:UIAlertActionStyleDestructive handler:^(UIAlertManagedAction *action){
            NSLog(@"destructive");
        }],
        [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(UIAlertManagedAction *action){
            NSLog(@"clicked 1");
        }],
        [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(UIAlertManagedAction *action){
            NSLog(@"clicked 2");
        }],
        [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertManagedAction *action){
            NSLog(@"canceled");
        }]
    ];
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [manager showInViewController:self actions:actions completion:nil];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize buttonSize = CGSizeMake(200, 44);
    // add alert button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((CGRectGetWidth(self.view.frame)-buttonSize.width)/2, 100, buttonSize.width, buttonSize.height)];
    [button setTitle:@"alert" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onAlertButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // add action sheet button
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((CGRectGetWidth(self.view.frame)-buttonSize.width)/2, 200, buttonSize.width, buttonSize.height)];
    [button setTitle:@"action sheet" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onActionSheetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
