#import "SocialShareFlPlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//#import <TwitterKit/TWTRKit.h>
#import <ZaloSDK/ZaloSDK.h>

@implementation SocialShareFlPlugin {
    FlutterMethodChannel* _channel;
    UIDocumentInteractionController* _dic;
    FlutterResult _result;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"social_share_plugin"
            binaryMessenger:[registrar messenger]];
  SocialShareFlPlugin* instance = [[SocialShareFlPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
    self = [super init];
    if(self) {
        _channel = channel;
    }
    return self;
}

 - (BOOL)application:(UIApplication *)application
     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
   return YES;
 }

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
   return [[FBSDKApplicationDelegate sharedInstance]
             application:application
                 openURL:url
       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

 - (BOOL)application:(UIApplication *)application
               openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
            annotation:(id)annotation {
   BOOL handled =
       [[FBSDKApplicationDelegate sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:sourceApplication
                                                   annotation:annotation];
   return handled;
 }

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _result = result;
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"shareToFeedInstagram" isEqualToString:call.method]) {
      NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
      if([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
          [self instagramShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *instagramLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id389801252";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instagramLink]];
          }
          result(false);
      }
  } else if ([@"shareToFeedFacebook" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShare:call.arguments[@"path"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          }
          result(false);
      }
  } else if([@"shareToFeedFacebookLink" isEqualToString:call.method]) {
      NSURL *fbURL = [NSURL URLWithString:@"fbapi://"];
      if([[UIApplication sharedApplication] canOpenURL:fbURL]) {
          [self facebookShareLink:call.arguments[@"quote"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *fbLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id284882215";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
          }
          result(false);
      }
  } else if([@"shareToTwitterLink" isEqualToString:call.method]) {
      NSURL *twitterURL = [NSURL URLWithString:@"twitter://"];
      if([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
          [self twitterShare:call.arguments[@"text"] url:call.arguments[@"url"]];
          result(nil);
      } else {
          NSString *twitterLink = @"itms-apps://itunes.apple.com/us/app/apple-store/id333903271";
          if (@available(iOS 10.0, *)) {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterLink] options:@{} completionHandler:^(BOOL success) {}];
          } else {
              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitterLink]];
          }
          result(false);
      }
  } else if ([@"shareMessageToZalo" isEqualToString:call.method]) {
      dispatch_async(dispatch_get_main_queue(), ^{
          NSString *urlString = @"zalo://";
          NSURL *url = [NSURL URLWithString:urlString];
          if ([[UIApplication sharedApplication] canOpenURL:url]) {
              // app da install
              NSString *msg = call.arguments[@"msg"];
              NSString *link = call.arguments[@"link"];
              NSString *linkTitle = call.arguments[@"linkTitle"];
              NSString *linkSource = call.arguments[@"linkSource"];
              NSString *linkThumb = call.arguments[@"linkThumb"];
              NSString *appName = call.arguments[@"appName"];
              
              ZOFeed *feed = [
                              [ZOFeed alloc]
                              initWithLink:link
                              appName: appName
                              message: msg
                              others: nil
                              ];
              feed.linkTitle = linkTitle;
              feed.linkSource = linkSource;
              feed.linkThumb = @[linkThumb];
              
              UIViewController *navigationController = [UIViewController self];
              
              [[ZaloSDK sharedInstance] sendMessage: feed
                                       inController:navigationController
                                           callback:^(ZOShareResponseObject *response)
               {
                  NSLog(@"%@", response.message);
                  if (response.isSucess) {
                      [self->_channel invokeMethod:@"onSuccess" arguments:nil];
                  } else {
                      NSError* error = nil;
                      [self->_channel invokeMethod:@"onError" arguments:@"app_not_share"];
                  }
              }];
          }
          else {
              [self->_channel invokeMethod:@"onError" arguments:@"app_not_install"];
          }
      });
  } else if ([@"shareFeedToZalo" isEqualToString:call.method]) {
      dispatch_async(dispatch_get_main_queue(), ^{
          NSString *urlString = @"zalo://";
          NSURL *url = [NSURL URLWithString:urlString];
          if ([[UIApplication sharedApplication] canOpenURL:url]) {
              // app da install
              NSString *msg = call.arguments[@"msg"];
              NSString *link = call.arguments[@"link"];
              NSString *linkTitle = call.arguments[@"linkTitle"];
              NSString *linkSource = call.arguments[@"linkSource"];
              NSString *linkThumb = call.arguments[@"linkThumb"];
              NSString *appName = call.arguments[@"appName"];
              
              ZOFeed * feed = [
                               [ZOFeed alloc]
                               initWithLink:link
                               appName: appName
                               message: msg
                               others: nil
                               ];
              feed.linkTitle = linkTitle;
              feed.linkSource = linkSource;
              feed.linkThumb = @[linkThumb];
              
              UIViewController *navigationController = [UIViewController self];
              
              [[ZaloSDK sharedInstance] shareFeed: feed
                                     inController:navigationController
                                         callback:^(ZOShareResponseObject *response)
               {
                  NSLog(@"%@", response.message);
                  if (response.isSucess) {
                      [self->_channel invokeMethod:@"onSuccess" arguments:nil];
                  } else {
                      [self->_channel invokeMethod:@"onError" arguments:@"app_not_share"];
                  }
              }];
          }
          else {
              [self->_channel invokeMethod:@"onError" arguments:@"app_not_install"];
          }
      });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)facebookShare:(NSString*)imagePath {
    //NSURL* path = [[NSURL alloc] initWithString:call.arguments[@"path"]];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)facebookShareLink:(NSString*)quote
                      url:(NSString*)url {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.quote = quote;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [FBSDKShareDialog showFromViewController:controller withContent:content delegate:self];
}

- (void)instagramShare:(NSString*)imagePath {
    NSError *error = nil;
    UIViewController* controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    [[NSFileManager defaultManager] moveItemAtPath:imagePath toPath:[NSString stringWithFormat:@"%@.igo", imagePath] error:&error];
    NSURL *path = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@.igo", imagePath]];
    _dic = [UIDocumentInteractionController interactionControllerWithURL:path];
    _dic.UTI = @"com.instagram.exclusivegram";
    if (![_dic presentOpenInMenuFromRect:CGRectZero inView:controller.view animated:TRUE]) {
        NSLog(@"Error sharing to instagram");
    };
}

- (void)twitterShare:(NSString*)text
                 url:(NSString*)url {
    UIApplication* application = [UIApplication sharedApplication];
    NSString* shareString = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@&url=%@", text, url];
    NSString* escapedShareString = [shareString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL* shareUrl = [NSURL URLWithString:escapedShareString];
    if (@available(iOS 10.0, *)) {
        [application openURL:shareUrl options:@{} completionHandler:^(BOOL success) {
            if(success) {
                [self->_channel invokeMethod:@"onSuccess" arguments:nil];
                NSLog(@"Sending Tweet!");
            } else {
                [self->_channel invokeMethod:@"onCancel" arguments:nil];
                NSLog(@"Tweet sending cancelled");
            }
        }];
    } else {
        [application openURL:shareUrl];
        [self->_channel invokeMethod:@"onSuccess" arguments:nil];
        NSLog(@"Sending Tweet!");
    }
//    TWTRComposer *composer = [[TWTRComposer alloc] init];
//    [composer setText:text];
//    [composer setURL:[NSURL URLWithString:url]];
//    [composer showFromViewController:controller completion:^(TWTRComposerResult result) {
//        if (result == TWTRComposerResultCancelled) {
//            [self->_channel invokeMethod:@"onCancel" arguments:nil];
//            NSLog(@"Tweet composition cancelled");
//        }
//        else {
//            [self->_channel invokeMethod:@"onSuccess" arguments:nil];
//            NSLog(@"Sending Tweet!");
//        }
//    }];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    [_channel invokeMethod:@"onSuccess" arguments:nil];
    NSLog(@"Sharing completed successfully");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    [_channel invokeMethod:@"onCancel" arguments:nil];
    NSLog(@"Sharing cancelled");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    [_channel invokeMethod:@"onError" arguments:nil];
    NSLog(@"%@",error);
}

@end
