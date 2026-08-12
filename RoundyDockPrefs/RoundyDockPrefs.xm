#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController (Private)
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end

@interface RoundyDockPrefsListController : PSListController
{
    NSArray *_specifiers;
}
@end

@implementation RoundyDockPrefsListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

@end
