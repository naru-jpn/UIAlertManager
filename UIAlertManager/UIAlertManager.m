
#import "UIAlertManager.h"

NSString * const UIAlertInfoManagedAction = @"managedAction";
NSString * const UIAlertInfoTextFields = @"textFields";

// UIAlertView dose not retain delegate object. This class retains delegate.
@interface RetainingAlertView : UIAlertView
@end

// UIActionSheet dose not retain delegate object. This class retains delegate.
@interface RetainingActionSheet : UIActionSheet
@end

@implementation UIAlertManagedAction

#pragma mark - life cycle

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(NSDictionary *info))handler {
    return [[UIAlertManagedAction alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(NSDictionary *info))handler {
    self = [super init];
    if (self) {
        _style = style;
        if (title) _title = [[NSString alloc] initWithString:title];
        if (handler) _handler = [handler copy];
    }
    return self;
}

@end


@interface UIAlertManager ()
@property (nonatomic, strong) NSArray *textFields;
@property (nonatomic, strong) UIAlertManagedAction *cancelAction;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, copy) void (^completion)(void);
@end

@implementation UIAlertManager

#pragma mark - handle event

- (void)executeCancelAction {
    NSDictionary *info = @{UIAlertInfoManagedAction: _cancelAction, UIAlertInfoTextFields: (_textFields ? _textFields : @[])};
    if (_cancelAction.handler) _cancelAction.handler(info);
}

- (void)executeActionAtIndex:(NSInteger)index {
    UIAlertManagedAction *action = (UIAlertManagedAction *)_actions[index];
    NSDictionary *info = @{UIAlertInfoManagedAction: action, UIAlertInfoTextFields: (_textFields ? _textFields : @[])};
    if (action.handler) action.handler(info);
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger cancelIndex = alertView.cancelButtonIndex;
    if (buttonIndex == cancelIndex) {
        [self executeCancelAction];
    } else {
        NSInteger actionIndex = ((cancelIndex >= 0) && (cancelIndex < buttonIndex)) ? (buttonIndex-1) : buttonIndex;
        [self executeActionAtIndex:actionIndex];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    [self executeCancelAction];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_completion) self.completion();
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (_enableActionHandler) return self.enableActionHandler(_textFields);
    else return YES;
}

- (void)textFieldsDidChanged:(UITextField *)textField {
    if (_enableActionHandler) {
        for (UIAlertAction *action in _actions) {
            if (action.style == UIAlertActionStyleCancel) continue;
            else {
                [action setEnabled:_enableActionHandler(_textFields)];
                break;
            }
        }
    }
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger cancelIndex = actionSheet.cancelButtonIndex;
    if (buttonIndex == cancelIndex) {
        [self executeCancelAction];
    } else {
        NSInteger actionIndex = ((cancelIndex >= 0) && (cancelIndex < buttonIndex)) ? (buttonIndex-1) : buttonIndex;
        [self executeActionAtIndex:actionIndex];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    [self executeCancelAction];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_completion) self.completion();
}

#pragma mark - manage alert controller

- (void)showInViewController:(UIViewController *)presentingViewController actions:(NSArray *)actions completion:(void (^)(void))completion {
    BOOL existAlertController = (NSClassFromString(@"UIAlertController") != nil);
    // action sheet
    if (_preferredStyle == UIAlertControllerStyleActionSheet) {
        // ios8
        if (existAlertController) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController setModalPresentationStyle:UIModalPresentationPopover];
            for (UIAlertManagedAction *managedAction in actions) {
                [alertController addAction:[self alertActionFromManagedAction:managedAction]];
            }
            [presentingViewController presentViewController:alertController animated:YES completion:completion];
        // - ios7.
        } else {
            self.completion = completion;
            // find cancel, descructive action title
            NSString *cancel = nil, *destructive = nil;
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style == UIAlertActionStyleCancel) {
                    cancel = managedAction.title;
                    self.cancelAction = managedAction;
                }
                if (managedAction.style == UIAlertActionStyleDestructive) destructive = managedAction.title;
            }
            // set actions
            NSMutableArray *array = [NSMutableArray array];
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style != UIAlertActionStyleCancel) [array addObject:managedAction];
            }
            self.actions = [NSArray arrayWithArray:array];
            // create actionsheet
            RetainingActionSheet *actionSheet = [[RetainingActionSheet alloc] initWithTitle:_title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructive otherButtonTitles:nil];
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style == UIAlertActionStyleDefault) [actionSheet addButtonWithTitle:managedAction.title];
            }
            [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:cancel]];
            [actionSheet showInView:presentingViewController.view];
        }
    }
    // alert
    if (_preferredStyle == UIAlertControllerStyleAlert) {
        // ios8
        if (existAlertController) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleAlert];
            [alertController setModalPresentationStyle:UIModalPresentationPopover];
            for (UIAlertManagedAction *managedAction in actions) {
                [alertController addAction:[self alertActionFromManagedAction:managedAction]];
            }
            // add textfields
            if (_alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){ [textField setPlaceholder:@"Login"]; }];
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
                    [textField setPlaceholder:@"Password"];
                    [textField setSecureTextEntry:YES];
                }];
            } else if (_alertViewStyle == UIAlertViewStyleSecureTextInput) {
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){ [textField setSecureTextEntry:YES]; }];
            } else if (_alertViewStyle == UIAlertViewStylePlainTextInput) {
                [alertController addTextFieldWithConfigurationHandler:nil];
            }
            _actions = alertController.actions;
            _textFields = alertController.textFields;
            for (UITextField *textField in _textFields){
                [textField addTarget:self action:@selector(textFieldsDidChanged:) forControlEvents:UIControlEventEditingChanged];
            };
            [self textFieldsDidChanged:nil];
            if (_configurationHandler) self.configurationHandler(_textFields);
            // show
            [presentingViewController presentViewController:alertController animated:YES completion:completion];
        // - ios7.
        } else {
            self.completion = completion;
            // find cancel action title
            NSString *cancel = nil;
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style == UIAlertActionStyleCancel) {
                    cancel = managedAction.title;
                    self.cancelAction = managedAction;
                }
            }
            // set actions
            NSMutableArray *array = [NSMutableArray array];
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style != UIAlertActionStyleCancel) [array addObject:managedAction];
            }
            self.actions = [NSArray arrayWithArray:array];
            // create alert view (set first action title to call alertViewShouldEnableFirstOtherButton:)
            RetainingAlertView *alertView = nil;
            UIAlertManagedAction *firstAction = nil;
            for (UIAlertManagedAction *managedAction in _actions) {
                if (managedAction.style != UIAlertActionStyleCancel) firstAction = managedAction;
            }
            if (firstAction != nil) {
                NSString *title = firstAction.title;
                alertView = [[RetainingAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:cancel otherButtonTitles:title, nil];
            } else {
                alertView = [[RetainingAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
            }
            for (UIAlertManagedAction *managedAction in _actions) {
                if ((managedAction.style == UIAlertActionStyleCancel) || (managedAction == firstAction)) continue;
                [alertView addButtonWithTitle:managedAction.title];
            }
            // add textfileds
            [alertView setAlertViewStyle:_alertViewStyle];
            if (_alertViewStyle == UIAlertViewStyleDefault) {
                _textFields = nil;
            } else if (_alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
                _textFields = @[[alertView textFieldAtIndex:0], [alertView textFieldAtIndex:1]];
            } else {
                _textFields = @[[alertView textFieldAtIndex:0]];
            }
            if (_configurationHandler) self.configurationHandler(_textFields);
            // show
            [alertView show];
        }
    }
}

// convert managed action to alert action
- (UIAlertAction *)alertActionFromManagedAction:(UIAlertManagedAction *)managedAction {
    UIAlertAction *action = [UIAlertAction actionWithTitle:managedAction.title style:(UIAlertActionStyle)managedAction.style handler:^(UIAlertAction *action) {
        NSDictionary *info = @{UIAlertInfoManagedAction: managedAction, UIAlertInfoTextFields: (_textFields ? _textFields : @[])};
        if (managedAction.handler) managedAction.handler(info);
    }];
    return action;
}

#pragma mark - life cycle

+ (instancetype)managerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style {
    return [[UIAlertManager alloc] initWithTitle:title message:message preferredStyle:style];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style {
    self = [super init];
    if (self) {
        if (title) _title = [[NSString alloc] initWithString:title];
        if (message) _message = [[NSString alloc] initWithString:message];
        _preferredStyle = style;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"@- %@", self.class);
}

@end


@interface RetainingAlertView ()
@property (nonatomic, retain) id retained;
@end

@implementation RetainingAlertView

- (void)setDelegate:(id)delegate {
    [super setDelegate:delegate];
    self.retained = delegate;
}

@end


@interface RetainingActionSheet ()
@property (nonatomic, retain) id retained;
@end

@implementation RetainingActionSheet

- (void)setDelegate:(id)delegate {
    [super setDelegate:delegate];
    self.retained = delegate;
}

@end
