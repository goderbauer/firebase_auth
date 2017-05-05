#import "FirebaseAuthPlugin.h"

#import "Firebase/Firebase.h"

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError
      errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
            message:self.domain
            details:self.localizedDescription];
}
@end

@implementation FirebaseAuthPlugin {
}

- (instancetype)initWithController:(FlutterViewController *)controller {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"firebase_auth"
                                    binaryMessenger:controller];
    [channel
        setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
          if ([@"signInAnonymously" isEqualToString:call.method]) {
            [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *user,
                                                              NSError *error) {
              [self sendResult:result forUser:user error:error];
            }];
          } else {
            result(FlutterMethodNotImplemented);
          }
        }];
  }
  return self;
}

- (void)sendResult:(FlutterResult)result
           forUser:(FIRUser *)user
             error:(NSError *)error {
  if (error != nil) {
    result(error.flutterError);
  } else if (user == nil) {
    result(nil);
  } else {
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
        [NSMutableArray arrayWithCapacity:user.providerData.count];
    for (id<FIRUserInfo> userInfo in user.providerData) {
      [providerData addObject:@{
        @"providerId" : userInfo.providerID,
        @"displayName" : userInfo.displayName,
        @"uid" : userInfo.uid,
        @"photoUrl" : userInfo.photoURL,
        @"email" : userInfo.email,
      }];
    }
    id userData = @{
      @"isAnonymous" : [NSNumber numberWithBool:user.isAnonymous],
      @"isEmailVerified" : [NSNumber numberWithBool:user.isEmailVerified],
      @"providerData" : providerData,
    };
    result(userData);
  }
}

@end
