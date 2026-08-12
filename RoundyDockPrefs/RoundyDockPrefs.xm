#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController (Private)
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface RoundyDockPrefsListController : PSListController
@end

@implementation RoundyDockPrefsListController

- (NSArray *)specifiers {
    if (![self valueForKey:@"_specifiers"]) {
        [self setValue:[self loadSpecifiersFromPlistName:@"Root" target:self] forKey:@"_specifiers"];
    }
    return [self valueForKey:@"_specifiers"];
}

@end
