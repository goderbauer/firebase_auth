#import "FirebaseAuthPlugin.h"

#import "Firebase/Firebase.h"

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError
      errorWithCode:[NSString stringWithFormat:@"Error %d", self.code]
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
    [channel setMethodCallHandler:^(FlutterMethodCall *call,
                                    FlutterResultReceiver result) {
      if ([@"signInAnonymously" isEqualToString:call.method]) {
        [[FIRAuth auth]
            signInAnonymouslyWithCompletion:^(FIRUser *user, NSError *error) {
              if (error != nil) {
                result(error.flutterError);
              } else if (user == nil) {
                result(nil);
              } else {
                result(@{
                  @"isAnonymous" : [NSNumber numberWithBool:user.isAnonymous]
                });
              }
            }];
      } else {
        NSString *message = [NSString
            stringWithFormat:@"Method not implemented: %@", call.method];
        result([FlutterError errorWithCode:message
                                   message:message
                                   details:message]);
      }
    }];
  }
  return self;
}

@end
