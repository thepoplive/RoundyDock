#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

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

		// Для iOS 10+ с blur-эффектом
		if ([backgroundView respondsToSelector:@selector(_setContinuousCornerRadius:)]) {
			[backgroundView _setContinuousCornerRadius:cornerRadius];
		}
	}
}

%end

%hook SBDockViewiOS7

- (void)layoutSubviews {
	%orig;
	if (!enabled) return;

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:[UIView class]] && subview != [self valueForKey:@"_iconListView"]) {
			subview.layer.cornerRadius = cornerRadius;
			subview.layer.masksToBounds = YES;
		}
	}
}

%end

// Для iOS 9-10 с новым доком
%hook SBDockViewController

- (void)viewDidLayoutSubviews {
	%orig;
	if (!enabled) return;

	UIView *view = self.view;
	for (UIView *subview in view.subviews) {
		if ([subview class] == [UIView class] || [NSStringFromClass([subview class]) containsString:@"Background"]) {
			subview.layer.cornerRadius = cornerRadius;
			subview.layer.masksToBounds = YES;
		}
	}
}

%end

// Настройки через PreferenceLoader
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
