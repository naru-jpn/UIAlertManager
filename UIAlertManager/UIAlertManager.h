
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// key strings to access info parameter of handler
OBJC_EXPORT NSString * const UIAlertInfoManagedAction;
OBJC_EXPORT NSString * const UIAlertInfoTextFields;

// managed action will be converted UIAlertAction for ios8
@interface UIAlertManagedAction : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIAlertActionStyle style;
@property (nonatomic, readonly) void (^handler)(NSDictionary *info);

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(NSDictionary *info))handler;

@end

// show alert or action sheet with actions
@interface UIAlertManager : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) UIAlertControllerStyle preferredStyle;
@property (nonatomic, readonly) UIViewController *presentingViewController;

// text fields
@property (nonatomic) UIAlertViewStyle alertViewStyle;
@property (nonatomic, copy) void (^configurationHandler)(NSArray *textFields);
@property (nonatomic, copy) BOOL (^enableActionHandler)(NSArray *textFields);

+ (instancetype)managerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style;
- (void)showInViewController:(UIViewController *)presentingViewController actions:(NSArray *)actions completion:(void (^)(void))completion;

@end
