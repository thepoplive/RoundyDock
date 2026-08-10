#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// Объявляем классы для компилятора
@interface SBDockView : UIView
- (UIView *)_backgroundView;
- (UIView *)backgroundView;
@end

@interface SBDockViewiOS7 : UIView
@end

@interface SBDockViewController : UIViewController
@end

static CGFloat cornerRadius = 20.0;
static BOOL enabled = YES;

%hook SBDockView

- (void)layoutSubviews {
	%orig;
	if (!enabled) return;
	
	UIView *backgroundView = nil;
	if ([self respondsToSelector:@selector(_backgroundView)]) {
		backgroundView = [self _backgroundView];
	} else if ([self respondsToSelector:@selector(backgroundView)]) {
		backgroundView = [self backgroundView];
	}
	
	if (backgroundView) {
		backgroundView.layer.cornerRadius = cornerRadius;
		backgroundView.layer.masksToBounds = YES;
	}
}

%end

%hook SBDockViewiOS7

- (void)layoutSubviews {
	%orig;
	if (!enabled) return;
	
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UIView class]]) {
			subview.layer.cornerRadius = cornerRadius;
			subview.layer.masksToBounds = YES;
		}
	}
}

%end

%hook SBDockViewController

- (void)viewDidLayoutSubviews {
	%orig;
	if (!enabled) return;
	
	UIView *view = self.view;
	for (UIView *subview in view.subviews) {
		NSString *className = NSStringFromClass([subview class]);
		if ([subview class] == [UIView class] || [className containsString:@"Background"]) {
			subview.layer.cornerRadius = cornerRadius;
			subview.layer.masksToBounds = YES;
		}
	}
}

%end

static void loadSettings() {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/alt.blxck.roundy.plist"];
	if (settings) {
		NSNumber *enabledNum = settings[@"enabled"];
		NSNumber *radiusNum = settings[@"cornerRadius"];
		if (enabledNum) enabled = [enabledNum boolValue];
		if (radiusNum) cornerRadius = [radiusNum floatValue];
	}
}

%ctor {
	loadSettings();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)loadSettings,
		CFSTR("alt.blxck.roundy/settingschanged"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);
}
