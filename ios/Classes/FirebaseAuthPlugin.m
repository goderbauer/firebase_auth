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

NSDictionary *toDictionary(id<FIRUserInfo> userInfo) {
  return @{
    @"providerId" : userInfo.providerID,
    @"displayName" : userInfo.displayName ?: [NSNull null],
    @"uid" : userInfo.uid,
    @"photoUrl" : userInfo.photoURL.absoluteString ?: [NSNull null],
    @"email" : userInfo.email ?: [NSNull null],
  };
}

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
          } else if ([@"signInWithGoogle" isEqualToString:call.method]) {
            NSString *idToken = call.arguments[@"idToken"];
            NSString *accessToken = call.arguments[@"accessToken"];
            FIRAuthCredential *credential =
                [FIRGoogleAuthProvider credentialWithIDToken:idToken
                                                 accessToken:accessToken];
            [[FIRAuth auth]
                signInWithCredential:credential
                          completion:^(FIRUser *user, NSError *error) {
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
      [providerData addObject:toDictionary(userInfo)];
    }
    NSMutableDictionary *userData = [toDictionary(user) mutableCopy];
    userData[@"isAnonymous"] = [NSNumber numberWithBool:user.isAnonymous];
    userData[@"isEmailVerified"] =
        [NSNumber numberWithBool:user.isEmailVerified];
    userData[@"providerData"] = providerData;
    result(userData);
  }
}

@end
