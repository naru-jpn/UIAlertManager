# UIAlertManager  
- Objective-C, ARC  

簡単なアラートやアクションシートを出す際の、 ios7以下とios8以上の場合分けを自動的に行います。  
(※アラートにテキストフィールドを追加する等の処理には対応していません。(2015.4.26))

## 使い方

UIAlertManager.h(.m) はコピーしてプロジェクトに追加して下さい。  
使い方は UIAlertController に似ています。

アラートを表示する例  

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
    [manager showInViewController:viewController actions:actions completion:nil];

アクションシートを表示する例  

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

## License
Distributed under the [MIT License][mit].

[MIT]: http://www.opensource.org/licenses/mit-license.php
