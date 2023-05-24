//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<zego_effects_plugin/ZegoEffectsPlugin.h>)
#import <zego_effects_plugin/ZegoEffectsPlugin.h>
#else
@import zego_effects_plugin;
#endif

#if __has_include(<zego_express_engine/ZegoExpressEnginePlugin.h>)
#import <zego_express_engine/ZegoExpressEnginePlugin.h>
#else
@import zego_express_engine;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [ZegoEffectsPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoEffectsPlugin"]];
  [ZegoExpressEnginePlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoExpressEnginePlugin"]];
}

@end
