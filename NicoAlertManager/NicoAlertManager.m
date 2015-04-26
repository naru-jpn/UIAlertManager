
#import "NicoAlertManager.h"

/* NicoAlertManagedAction */

@implementation NicoAlertManagedAction

#pragma mark - life cycle

+ (instancetype)actionWithTitle:(NSString *)title style:(ManagedActionStyle)style handler:(void (^)(NicoAlertManagedAction *))handler {
    return [[[NicoAlertManagedAction alloc] initWithTitle:title style:style handler:handler] autorelease];
}

- (instancetype)initWithTitle:(NSString *)title style:(ManagedActionStyle)style handler:(void (^)(NicoAlertManagedAction *))handler {
    self = [super init];
    if (self) {
        _style = style;
        if (title) _title = [[NSString alloc] initWithString:title];
        if (handler) _handler = Block_copy(handler);
    }
    return self;
}

- (void)dealloc {
    if (_title) [_title release];
    if (_handler) Block_release(_handler);
    [super dealloc];
}

@end

/* NicoAlertManager */

@interface NicoAlertManager ()
@property (nonatomic, retain) NicoAlertManagedAction *cancelAction;
@property (nonatomic, retain) NSArray *actions;
@property (nonatomic, copy) void (^completion)(void);
@end

@implementation NicoAlertManager

#pragma mark - handle event

- (void)executeCancelAction {
    if (_cancelAction.handler) _cancelAction.handler(_cancelAction);
}

- (void)executeActionAtIndex:(NSInteger)index {
    NicoAlertManagedAction *action = (NicoAlertManagedAction *)_actions[index];
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

- (void)showWithPresentingController:(UIViewController *)presentingControllerController actions:(NSArray *)actions completion:(void (^)(void))completion {
    BOOL existAlertController = (NSClassFromString(@"UIAlertController") != nil);
    // action sheet
    if (_preferredStyle == NicoAlertStyleActionSheet) {
        // ios8
        if (existAlertController) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleActionSheet];
            for (NicoAlertManagedAction *managedAction in actions) {
                [alertController addAction:[self alertActionFromManagedAction:managedAction]];
            }
            [presentingControllerController presentViewController:alertController animated:YES completion:completion];
        // - ios7
        } else {
            self.completion = completion;
            // find cancel, descructive action title
            NSString *cancel = nil, *destructive = nil;
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style == ManagedActionStyleCancel) {
                    cancel = managedAction.title;
                    self.cancelAction = managedAction;
                }
                if (managedAction.style == ManagedActionStyleDestructive) destructive = managedAction.title;
            }
            // set actions
            NSMutableArray *array = [NSMutableArray array];
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style != ManagedActionStyleCancel) [array addObject:managedAction];
            }
            self.actions = [NSArray arrayWithArray:array];
            // create actionsheet
            RetainingActionSheet *actionSheet = [[RetainingActionSheet alloc] initWithTitle:_title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructive otherButtonTitles:nil];
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style == ManagedActionStyleDefault) [actionSheet addButtonWithTitle:managedAction.title];
            }
            [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:cancel]];
            [actionSheet.autorelease showInView:presentingControllerController.view];
        }
    }
    // alert
    if (_preferredStyle == NicoAlertStyleAlert) {
        // ios8
        if (existAlertController) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleAlert];
            for (NicoAlertManagedAction *managedAction in actions) {
                [alertController addAction:[self alertActionFromManagedAction:managedAction]];
            }
            [presentingControllerController presentViewController:alertController animated:YES completion:completion];
        // - ios7
        } else {
            self.completion = completion;
            // find cancel action title
            NSString *cancel = nil;
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style == ManagedActionStyleCancel) {
                    cancel = managedAction.title;
                    self.cancelAction = managedAction;
                }
            }
            // set actions
            NSMutableArray *array = [NSMutableArray array];
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style != ManagedActionStyleCancel) [array addObject:managedAction];
            }
            self.actions = [NSArray arrayWithArray:array];
            // create alert view
            RetainingAlertView *alertView = [[RetainingAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
            for (NicoAlertManagedAction *managedAction in actions) {
                if (managedAction.style != ManagedActionStyleCancel) [alertView addButtonWithTitle:managedAction.title];
            }
            [alertView.autorelease show];
        }
    }
}

// convert managed action to alert action
- (UIAlertAction *)alertActionFromManagedAction:(NicoAlertManagedAction *)managedAction {
    UIAlertAction *action = [UIAlertAction actionWithTitle:managedAction.title style:(UIAlertActionStyle)managedAction.style handler:^(UIAlertAction *action) {
        if (managedAction.handler) managedAction.handler(managedAction);
    }];
    return action;
}

#pragma mark - life cycle

+ (instancetype)managerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(NicoAlertStyle)style {
    return [[[NicoAlertManager alloc] initWithTitle:title message:message preferredStyle:style] autorelease];
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(NicoAlertStyle)style {
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
    self.actions = nil;
    self.cancelAction = nil;
    self.completion = nil;
    if (_title) [_title release];
    if (_message) [_message release];
    [super dealloc];
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

- (void)dealloc {
    self.retained = nil;
    [super dealloc];
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

- (void)dealloc {
    self.retained = nil;
    [super dealloc];
}

@end
