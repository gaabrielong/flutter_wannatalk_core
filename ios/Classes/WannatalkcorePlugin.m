#import "WannatalkcorePlugin.h"
#import <WTExternalSDK/WTExternalSDK.h>
#import "WTConfigHandler.h"


@interface WannatalkcorePlugin() <WTLoginManagerDelegate, WTSDKManagerDelegate> {
    BOOL _hasListeners;



}
@property (nonatomic, strong) FlutterResult loginResult;
@property (nonatomic, strong) FlutterResult logoutResult;
@property (nonatomic, strong) FlutterResult orgProfileResult;
@property (nonatomic, strong) FlutterResult chatListResult;
@property (nonatomic, strong) FlutterResult userListResult;


@property (nonatomic, strong) FlutterMethodChannel *wtEventChannel;

@end

@implementation WannatalkcorePlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    WannatalkcorePlugin* instance = [[WannatalkcorePlugin alloc] init];
    instance.wtEventChannel = [FlutterMethodChannel methodChannelWithName:@"wannatalkcore" binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:instance channel:instance.wtEventChannel];
    [instance initialize];

}

- (void) initialize {
    _hasListeners = YES;
    [[WTSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];

    [WTLoginManager sharedInstance].delegate = self;
    [WTSDKManager sharedInstance].delegate = self;
}


#pragma mark - Constants

static const  NSString * _Nonnull _cWTDefaultMethod= @"wannatalkDefaultMethod";
static const  NSString * _Nonnull _cWTUpdateConfig= @"updateConfig";
static const  NSString * _Nonnull _cWTIsUserLoggedIn= @"isUserLoggedIn";


static const  NSString * _Nonnull _cWTMethodType= @"methodType";
static const  NSString * _Nonnull _cWTArgs= @"args";
static const  NSString * _Nonnull _cWTUsername= @"username";
static const  NSString * _Nonnull _cWTLocalImagePath= @"localImagePath";

static const  NSString * _Nonnull _cWTAutoOpenChat= @"autoOpenChat";
static const  NSString * _Nonnull _cWTUserIdentifier= @"userIdentifier";
static const  NSString * _Nonnull _cWTUserInfo= @"userInfo";


static const  int _kWTLoginMethod= 1001;
static const  int _kWTSilentLoginMethod= 1002;
static const  int _kWTLogoutMethod= 1003;
static const  int _kWTOrgProfileMethod= 1004;
static const  int _kWTChatListMethod= 1005;
static const  int _kWTUserListMethod= 1006;
static const  int _kWTUpdateUserNameMethod= 1007;
static const  int _kWTUpdateUserImageMethod= 1008;
static const  int _kWTIsUserLoggedIn= 1009;


// OUT

static const  NSString * _Nonnull _cMethod= @"wt_event";
static const  NSString * _Nonnull _cEventType= @"eventType";
static const  NSString * _Nonnull _cSuccess= @"success";
static const  NSString * _Nonnull _cError= @"error";

static const  int _kWTEventTypeLogin= 2001;
static const  int _kWTEventTypeLogout= 2002;


#pragma mark -

- (void) handleMethodType:(NSInteger) methodType arguments:(NSDictionary *) args result:(FlutterResult)result {
    switch (methodType) {
        case _kWTLoginMethod: {
            [self login:result];
            break;
        }
        case _kWTSilentLoginMethod: {
            NSString *identifier = args[_cWTUserIdentifier];
            NSDictionary *userInfo = args[_cWTUserInfo];
            [self silentLogin:identifier userInfo:userInfo result:result];

            break;
        }
        case _kWTLogoutMethod: {
            [self logout:result];
            break;
        }
        case _kWTOrgProfileMethod: {
            BOOL autoOpenChat = [args[_cWTAutoOpenChat] boolValue];
            [self loadOrganizationProfile:autoOpenChat result:result];

            break;
        }
        case _kWTChatListMethod: {
            [self loadChatList:result];
            break;
        }
        case _kWTUserListMethod: {
            [self loadUsers:result];
            break;
        }
        case _kWTUpdateUserNameMethod: {
            NSString *username = args[_cWTUsername];
            [self updateUserName:username result:result];
            break;
        }
        case _kWTUpdateUserImageMethod: {
            NSString *localImagePath = args[_cWTLocalImagePath];
            [self updateUserImage:localImagePath result:result];

            break;
        }
        default: {

            break;
        }
    }
}

- (void) handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;

    if ([method isEqualToString:_cWTDefaultMethod]) {

        NSInteger methodType = [call.arguments[_cWTMethodType] integerValue];
        NSDictionary *args = call.arguments[_cWTArgs];
        [self handleMethodType:methodType arguments:args result:result];

    }
    else if ([method isEqualToString:_cWTUpdateConfig]) {
        NSInteger methodType = [call.arguments[_cWTMethodType] integerValue];
        NSDictionary *args = call.arguments[_cWTArgs];
        [WTConfigHandler handleConfigMethodType:methodType arguments:args];
        result(@(YES));
    }
    else if ([method isEqualToString:_cWTIsUserLoggedIn]) {
        BOOL loggedIn = [self isUserLoggedIn];
        result(@(loggedIn));
    }
}



#pragma mark -

+ (UIViewController *) GetWindowRootViewController {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *_rootViewController = (UIViewController *)window.rootViewController;
    return _rootViewController;
}

+ (void) RunMainThread:(void (^)(void))onMainThread {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onMainThread) {
                onMainThread();
            }
        });
    });

}

+ (void) GetBaseViewController:(void (^)(UIViewController *baseViewController)) onCompletion {

    [self RunMainThread:^{
        UIViewController *_rootViewController = [self GetWindowRootViewController];

        if (onCompletion) {
            onCompletion(_rootViewController);
        }
    }];


}
#pragma mark -

- (BOOL) isUserLoggedIn {
    return [WTLoginManager sharedInstance].isUserLoggedIn;
}

- (void) logout:(FlutterResult) result {
    self.logoutResult = result;

    [WannatalkcorePlugin RunMainThread:^{
        [[WTLoginManager sharedInstance] logout];
    }];
}

- (void)silentLogin:(NSString *) identifier userInfo:(NSDictionary *) userInfo result:(FlutterResult) result {
    self.loginResult = result;

    [WannatalkcorePlugin GetBaseViewController:^(UIViewController *baseViewController) {
        [[WTLoginManager sharedInstance] silentLoginWithIdentifier:identifier userInfo:userInfo fromVC:baseViewController];

    }];
}


-(void) login:(FlutterResult) result {

    self.loginResult = result;

    [WannatalkcorePlugin GetBaseViewController:^(UIViewController *baseViewController) {
        [[WTLoginManager sharedInstance] loginFromVC:baseViewController];

    }];

}

#pragma mark -

- (void)loadOrganizationProfile:(BOOL) autoOpenChat result:(FlutterResult) result {
    self.orgProfileResult = result;

    [WannatalkcorePlugin GetBaseViewController:^(UIViewController *baseViewController) {
        [baseViewController presentOrgProfileVCWithAutoOpenChat:autoOpenChat delegate:self animated:YES completion:nil];
    }];

}

-(void) loadChatList:(FlutterResult) result {
    self.chatListResult = result;
    [WannatalkcorePlugin GetBaseViewController:^(UIViewController *baseViewController) {
        [baseViewController presentChatListVCWithDelegate:self animated:YES completion:nil];
    }];
}


- (void)loadUsers:(FlutterResult) result {
    self.userListResult = result;

    [WannatalkcorePlugin GetBaseViewController:^(UIViewController *baseViewController) {
        [baseViewController presentUsersVCWithDelegate:self animated:YES completion:nil];
    }];
}

#pragma mark -

- (void) updateUserImage:(NSString *) localImagePath result:(FlutterResult) result {
    [[WTLoginManager sharedInstance] uploadUserImageAtPath:localImagePath onCompletion:^(BOOL success, NSString *error) {

        if (result) {
            result(error);
        }

    }];
}

- (void) updateUserName:(NSString *) userName result:(FlutterResult) result {
    [[WTLoginManager sharedInstance] updateUserProfileName:userName onCompletion:^(BOOL success, NSString *error) {

        if (result) {
            result(error);
        }
    }];
}


#pragma mark -


- (void) sendWannatalkEvent:(NSInteger ) eventType error:(NSString *) error {
    if (_hasListeners) {
        NSMutableDictionary *args = [NSMutableDictionary new];
        args[_cEventType] = @(eventType);
        args[_cSuccess] = @(error == nil);
        args[_cError] = error;

        [self.wtEventChannel invokeMethod:_cMethod arguments:args];
    }
}

- (void) sendLoginCallback:(NSString *) error {
    if (self.loginResult) {
        self.loginResult(error);
    }
    self.loginResult = nil;
}

- (void) sendLogoutCallback:(NSString *) error {
    if (self.logoutResult) {
        self.logoutResult(error);
    }
    self.logoutResult = nil;
}


- (void) sendOrgProfileCallback:(NSString *) error {
    if (self.orgProfileResult) {
        self.orgProfileResult(error);
    }
    self.orgProfileResult = nil;
}


- (void) sendChatListCallback:(NSString *) error {
    if (self.chatListResult) {
        self.chatListResult(error);
    }
    self.chatListResult = nil;
}


- (void) sendUserListallback:(NSString *) error {
    if (self.userListResult) {
        self.userListResult(error);
    }
    self.userListResult = nil;
}


#pragma mark - WTLoginManager Delegate Methods

// This method will be invoked when user sign in successfully
- (void) wtAccountDidLoginSuccessfully {
    [self sendLoginCallback:nil];
    [self sendWannatalkEvent:_kWTEventTypeLogin error:nil];
}
// This method will be invoked when user sign out successfully
- (void) wtAccountDidLogOutSuccessfully {
    [self sendLogoutCallback:nil];
    [self sendWannatalkEvent:_kWTEventTypeLogout error:nil];
}

// If implemented, this method will be invoked when login fails
- (void) wtAccountDidLoginFailWithError:(NSString *) error {
    [self sendLoginCallback:error];
    [self sendWannatalkEvent:_kWTEventTypeLogin error:error];
}
// If implemented, this method will be invoked when logout fails
- (void) wtAccountDidLogOutFailedWithError:(NSString *) error {
    [self sendLogoutCallback:error];
    [self sendWannatalkEvent:_kWTEventTypeLogout error:error];
}

#pragma mark - WTSDKManager Delegate Methods

- (UINavigationController *) prepareViewHierachiesToLoadChatRoom:(BOOL) aiTopic {
    // Get view controller on which to present the flow
    UINavigationController *_rootViewController = (UINavigationController *) [WannatalkcorePlugin GetWindowRootViewController];
    return _rootViewController;
}


// If implemented, this method will be invoked when organization profile loads successfully
- (void) wtsdkOrgProfileDidLoadSuccesfully {
    [self sendOrgProfileCallback:nil];
}

// If implemented, this method will be invoked when organization profile fails to load
- (void) wtsdkOrgProfileDidLoadFailWithError:(NSString *) error {
    [self sendOrgProfileCallback:error];
}

// If implemented, this method will be invoked when chat list page loads successfully
- (void) wtsdkChatListDidLoadSuccesfully {
    [self sendChatListCallback:nil];

}

// If implemented, this method will be invoked when chat list page fails to load
- (void) wtsdkChatListDidLoadFailWithError:(NSString *) error {
    [self sendChatListCallback:error];
}

// If implemented, this method will be invoked when user list page loads successfully
- (void) wtsdkUsersDidLoadSuccesfully {
    [self sendUserListallback:nil];
}

// If implemented, this method will be invoked when user list page fails to load
- (void) wtsdkUsersDidLoadFailWithError:(NSString *) error {
    [self sendUserListallback:error];
}
@end
