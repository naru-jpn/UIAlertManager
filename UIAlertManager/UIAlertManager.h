
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// managed action will be converted UIAlertAction
@interface UIAlertManagedAction : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIAlertActionStyle style;
@property (nonatomic, readonly) void (^handler)(UIAlertManagedAction *);

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertManagedAction *))handler;

@end

// show alert or action sheet with actions
@interface UIAlertManager : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) UIAlertControllerStyle preferredStyle;
@property (nonatomic, readonly) UIViewController *presentingViewController;

+ (instancetype)managerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style;
- (void)showInViewController:(UIViewController *)presentingViewController actions:(NSArray *)actions completion:(void (^)(void))completion;

@end
