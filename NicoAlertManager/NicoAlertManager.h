
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ManagedActionStyle) {
    ManagedActionStyleDefault = 0,
    ManagedActionStyleCancel,
    ManagedActionStyleDestructive
};

typedef NS_ENUM(NSInteger, NicoAlertStyle) {
    NicoAlertStyleActionSheet = 0,
    NicoAlertStyleAlert
};

// managed action will be converted UIAlertAction
@interface NicoAlertManagedAction : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) ManagedActionStyle style;
@property (nonatomic, readonly) void (^handler)(NicoAlertManagedAction *);

+ (instancetype)actionWithTitle:(NSString *)title style:(ManagedActionStyle)style handler:(void (^)(NicoAlertManagedAction *))handler;

@end

// show alert or action sheet with actions
@interface NicoAlertManager : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NicoAlertStyle preferredStyle;
@property (nonatomic, readonly) UIViewController *presentingViewController;

+ (instancetype)managerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(NicoAlertStyle)style;
- (void)showWithPresentingController:(UIViewController *)presentingController actions:(NSArray *)actions completion:(void (^)(void))completion;

@end

// UIAlertView dose not retain delegate object. This class retains delegate.
@interface RetainingAlertView : UIAlertView
@end

// UIActionSheet dose not retain delegate object. This class retains delegate.
@interface RetainingActionSheet : UIActionSheet
@end
