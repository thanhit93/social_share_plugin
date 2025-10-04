import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

typedef Future<dynamic> OnCancelHandler();
typedef Future<dynamic> OnErrorHandler(String? error);
typedef Future<dynamic> OnSuccessHandler(String? postId);

class SocialSharePlugin {
  static const MethodChannel _channel = const MethodChannel('social_share_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> shareToFeedInstagram({
    String type = 'image/*',
    required String path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedInstagram', <String, dynamic>{
      'type': type,
      'path': path,
    });
  }

  static Future<void> shareToFeedFacebook({
    String? caption,
    required String path,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        case "onError":
          return onError!(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedFacebook', <String, dynamic>{
      'caption': caption,
      'path': path,
    });
  }

  static Future<dynamic> shareToFeedFacebookLink({
    String? quote,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        case "onError":
          return onError!(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToFeedFacebookLink', <String, dynamic>{
      'quote': quote,
      'url': url,
    });
  }

  static Future<bool?> shareToTwitterLink({
    String? text,
    required String url,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        //  case "onError":
        //    return onError(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareToTwitterLink', <String, dynamic>{
      'text': text,
      'url': url,
    });
  }

  static Future<dynamic> shareMessageToZalo({
    String? msg,
    required String url,
    String? linkSource,
    String? linkTitle,
    String? linkThumb,
    String? appName,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        case "onError":
          return onError!(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareMessageToZalo', <String, dynamic>{
      'msg': msg,
      'link': url,
      'linkSource': linkSource,
      'linkTitle': linkTitle,
      'linkThumb': linkThumb,
      'appName': appName,
    });
  }


  static Future<dynamic> shareFeedToZalo({
    String? msg,
    required String url,
    String? linkSource,
    String? linkTitle,
    String? linkThumb,
    String? appName,
    OnSuccessHandler? onSuccess,
    OnCancelHandler? onCancel,
    OnErrorHandler? onError,
  }) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onSuccess":
          return onSuccess!(call.arguments);
        case "onCancel":
          return onCancel!();
        case "onError":
          return onError!(call.arguments);
        default:
          throw UnsupportedError("Unknown method called");
      }
    });
    return _channel.invokeMethod('shareFeedToZalo', <String, dynamic>{
      'msg': msg,
      'link': url,
      'linkSource': linkSource,
      'linkTitle': linkTitle,
      'linkThumb': linkThumb,
      'appName': appName,
    });
  }
}
