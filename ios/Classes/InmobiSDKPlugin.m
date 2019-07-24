#import "InmobiSDKPlugin.h"

@implementation InmobiPlugin

@synthesize accountId;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"inmobi_sdk"
            binaryMessenger:[registrar messenger]];
  InmobiPlugin* instance = [[InmobiPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

/*Indicates that the interstitial is ready to be shown */
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidFinishLoading");
}

/* Indicates that the interstitial has failed to receive an ad. */
- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    NSLog(@"Interstitial failed to load ad");
    NSLog(@"Error : %@",error.description);
}
/* Indicates that the interstitial has failed to present itself. */
- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    NSLog(@"Interstitial didFailToPresentWithError");
    NSLog(@"Error : %@",error.description);
}
/* indicates that the interstitial is going to present itself. */
- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    NSLog(@"interstitialWillPresent");
}
/* Indicates that the interstitial has presented itself */
- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidPresent");
}
/* Indicates that the interstitial is going to dismiss itself. */
- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    NSLog(@"interstitialWillDismiss");
}
/* Indicates that the interstitial has dismissed itself. */
- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidDismiss");
}
/* Indicates that the user will leave the app. */
- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    NSLog(@"userWillLeaveApplicationFromInterstitial");
}
/* interstitial:didInteractWithParams: Indicates that the interstitial was interacted with. */
- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    NSLog(@"InterstitialDidInteractWithParams");
}

- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    NSLog(@"interstitialDidReceiveAd");
}

- (void)loadInterstitial {
  if(self.interstitial != nil)
    NSLog(@"New interstitial is being loaded without the previous instance having been unset. This may cause odd behaviour");
  [self.interstitial load];
}

- (void)showInterstitial {
  if(self.interstitial == nil) {
    NSLog(@"No interstitial loaded.");
    [NSException raise:@"InterstitialLoadException" format:@"No interstitial has been loaded. A single interstitial object cannot be shown more than once, and instances are unloaded after being shown. You must therefore first invoke interstitial.load, then invoke interstitial.show, every time you want to display an interstitial."];
  } else {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.interstitial showFromViewController:viewController withAnimation:kIMInterstitialAnimationTypeCoverVertical];
    self.interstitial = nil;
    NSLog(@"Loaded interstitial shown and unloaded");
  }
}

- (void)configureWithAccountId:(NSString *)accountId placementId:(NSNumber*)placementId {
    //consent value needs to be collected from the end user
    NSMutableDictionary *consentdict=[[NSMutableDictionary alloc]init];
    [consentdict setObject:@"true" forKey:IM_GDPR_CONSENT_AVAILABLE];
    [consentdict setObject:@1 forKey:@"gdpr"];
    
    //Initialize InMobi SDK with your account ID
    self.accountId = accountId;
    [IMSdk initWithAccountID:accountId consentDictionary:consentdict];
    NSLog(@"Initializing with accountId %s and placementId %@", [accountId UTF8String], placementId);
    long long placementId_long = [placementId longValue];
    NSLog(@"Initializing interstitial with placementId: %lld",placementId_long );
    self.interstitial = [[IMInterstitial alloc] initWithPlacementId:placementId_long];
    self.interstitial.delegate = self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
      if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
      } else if ([@"configure" isEqualToString:call.method]) {
        [self configureWithAccountId:call.arguments[@"accountId"] placementId:call.arguments[@"placementId"]];
        result(nil);
      } else if ([@"interstitial.load" isEqualToString:call.method]) {      
        [self loadInterstitial];
        result(nil);
      } else if ([@"interstitial.show" isEqualToString:call.method]) {
        [self showInterstitial];
        result(nil);  
      } else {
        result(FlutterMethodNotImplemented);
      }
    } @catch (NSException *exception) {
      NSLog(@"NSException : %@", exception.name);
      NSLog(@"Reason : %@", exception.reason);
      result(false);
    }
}

@end