# UIAlertManager  
- Objective-C, ARC  

アラートやアクションシートを出す際の、 ios7以下への対応を助けます。  

## 使い方

UIAlertManager.h(.m) はコピーしてプロジェクトに追加して下さい。  

__アラートを表示する例__  
UIAlertController の使い方と同様です。  

    NSString *title = @"Alert title";
    NSString *message = @"Alert message";
    NSArray *actions = @[
      // 選択肢1
      [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 1");
      }],
      // 選択肢2
      [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 2");
      }],
      // キャンセル
      [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
      }]
    ];
    // アラートの場合は preferredStyle に UIAlertControllerStyleAlert を指定
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [manager showInViewController:viewController actions:actions completion:nil];
　  
__アクションシートを表示する例__  
こちらも UIAlertController の使い方と同様です。  

    NSString *title = @"Action sheet title";
    NSString *message = @"Action sheet message";
    NSArray *actions = @[
      // 選択肢1 (UIAlertActionStyleDestructive は赤文字で表示されます)
      [UIAlertManagedAction actionWithTitle:@"destructive" style:UIAlertActionStyleDestructive handler:^(NSDictionary *info)){
        NSLog(@"destructive");
      }],
      // 選択肢2
      [UIAlertManagedAction actionWithTitle:@"title1" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 1");
      }],
      // 選択肢3
      [UIAlertManagedAction actionWithTitle:@"title2" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
        NSLog(@"clicked 2");
      }],
      // キャンセル
      [UIAlertManagedAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
      }]
    ];
    // アクションシートの場合は preferredStyle に UIAlertControllerStyleActionSheet を指定
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [manager showInViewController:self actions:actions completion:nil];
　  
__アラートにテキストフィールドを追加する場合__  
テキストビューの追加の方法には ios7 以前の方法を採用しました。ios8 の方が自由度が高い為に挙動は制限はされますが、ios7 で予期しない動作になる事を防ぎます。  

    NSString *title = @"Alert title";
    NSString *message = @"Alert message";
    // 選択肢1 ('Login')
    UIAlertManagedAction *login = [UIAlertManagedAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(NSDictionary *info){
      // info[UIAlertInfoTextFields] でテキストフィールドの配列を取得出来ます。
      NSArray *textFields = info[UIAlertInfoTextFields];
      NSLog(@"UserID  : %@", [textFields[0] text]);
      NSLog(@"Password: %@", [textFields[1] text]);
    }];
    // キャンセル
    UIAlertManagedAction *cancel = [UIAlertManagedAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(NSDictionary *info){
        NSLog(@"canceled");
    }];
    // テキストフィールドのプレイスホルダー等を指定出来ます。
    void (^configurationHandler)(NSArray *textFields) = ^(NSArray *textFields) {
        UITextField *textField = (UITextField *)textFields.firstObject;
        [textField setPlaceholder:@"UserID"];
    };
    // 選択肢1にあたるボタン(この例では'Login')の有効・無効を切り替える事が出来ます。
    // 指定しない場合は常に有効になります。
    BOOL (^enableActionHandler)(NSArray *textFields) = ^(NSArray *textFields) {
        UITextField *userName = (UITextField *)textFields[0];
        UITextField *password = (UITextField *)textFields[1];
        return (BOOL)((userName.text.length > 0) && (password.text.length > 0));
    };
    // AlertViewStyle と上記で記述した処理を指定します。
    UIAlertManager *manager = [UIAlertManager managerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [manager setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [manager setConfigurationHandler:configurationHandler];
    [manager setEnableActionHandler:enableActionHandler];
    [manager showInViewController:self actions:@[login, cancel] completion:nil];

## License
Distributed under the [MIT License][mit].

[MIT]: http://www.opensource.org/licenses/mit-license.php
