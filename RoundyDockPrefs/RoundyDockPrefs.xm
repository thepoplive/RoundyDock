#import <Preferences/PSListController.h>

@interface RoundyDockPrefsListController : PSListController
@end

@implementation RoundyDockPrefsListController

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/alt.blxck.roundy.plist"];
    NSString *key = [specifier propertyForKey:@"key"];
    if (!key) return [specifier propertyForKey:@"default"];
    id value = settings[key];
    if (!value) value = [specifier propertyForKey:@"default"];
    return value;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if (!key) return;
    NSMutableDictionary *settings = [[[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/alt.blxck.roundy.plist"] mutableCopy] ?: [NSMutableDictionary dictionary] retain];
    settings[key] = value;
    [settings writeToFile:@"/var/mobile/Library/Preferences/alt.blxck.roundy.plist" atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("alt.blxck.roundy/settingschanged"), NULL, NULL, YES);
}

@end
