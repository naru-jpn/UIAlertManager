
#import "UIAlertManager.h"

// UIAlertView dose not retain delegate object. This class retains delegate.
@interface RetainingAlertView : UIAlertView
@end

// UIActionSheet dose not retain delegate object. This class retains delegate.
@interface RetainingActionSheet : UIActionSheet
@end

/* NicoAlertManagedAction */

@implementation UIAlertManagedAction

#pragma mark - life cycle

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertManagedAction *))handler {
    return [[UIAlertManagedAction alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertManagedAction *))handler {
    self = [super init];
    if (self) {
        _style = style;
        if (title) _title = [[NSString alloc] initWithString:title];
        if (handler) _handler = [handler copy];
    }
    return self;
}

@end

/* NicoAlertManager */

@interface UIAlertManager ()
@property (nonatomic, strong) UIAlertManagedAction *cancelAction;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, copy) void (^completion)(void);
@end

@implementation UIAlertManager

#pragma mark - handle event

- (void)executeCancelAction {
    if (_cancelAction.handler) _cancelAction.handler(_cancelAction);
}

- (void)executeActionAtIndex:(NSInteger)index {
    UIAlertManagedAction *action = (UIAlertManagedAction *)_actions[index];
    if (action.handler) action.handler(action);
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
        // - ios7
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
            [presentingViewController presentViewController:alertController animated:YES completion:completion];
        // - ios7
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
            // create alert view
            RetainingAlertView *alertView = [[RetainingAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
            for (UIAlertManagedAction *managedAction in actions) {
                if (managedAction.style != UIAlertActionStyleCancel) [alertView addButtonWithTitle:managedAction.title];
            }
            [alertView show];
        }
    }
}

// convert managed action to alert action
- (UIAlertAction *)alertActionFromManagedAction:(UIAlertManagedAction *)managedAction {
    UIAlertAction *action = [UIAlertAction actionWithTitle:managedAction.title style:(UIAlertActionStyle)managedAction.style handler:^(UIAlertAction *action) {
        if (managedAction.handler) managedAction.handler(managedAction);
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

/* RetainingAlertView */

@interface RetainingAlertView ()
@property (nonatomic, retain) id retained;
@end

@implementation RetainingAlertView

- (void)setDelegate:(id)delegate {
    [super setDelegate:delegate];
    self.retained = delegate;
}

@end

/* RetainingActionSheet */

@interface RetainingActionSheet ()
@property (nonatomic, retain) id retained;
@end

@implementation RetainingActionSheet

- (void)setDelegate:(id)delegate {
    [super setDelegate:delegate];
    self.retained = delegate;
}

@end
