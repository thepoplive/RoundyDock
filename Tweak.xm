#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SBDockView : UIView
- (UIView *)_backgroundView;
- (UIView *)backgroundView;
@end

@interface SBDockViewiOS7 : UIView
@end

@interface SBDockViewController : UIViewController
@end

static CGFloat cornerRadius = 5.0;
static CGFloat dockScale = 1.0;
static BOOL hideLabels = NO;
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
	
	for (UIView *subview in self.subviews) {
		if (subview == backgroundView) continue;
		
		NSString *className = NSStringFromClass([subview class]);
		if ([className containsString:@"Label"]) {
			subview.hidden = hideLabels;
		}
		
		if (dockScale != 1.0) {
			subview.transform = CGAffineTransformMakeScale(dockScale, dockScale);
		}
		
		subview.layer.cornerRadius = cornerRadius;
		subview.layer.masksToBounds = YES;
	}
}

%end

%hook SBDockViewiOS7

- (void)layoutSubviews {
	%orig;
	if (!enabled) return;
	
	for (UIView *subview in self.subviews) {
		NSString *className = NSStringFromClass([subview class]);
		if ([className containsString:@"Label"]) {
			subview.hidden = hideLabels;
		}
		
		if ([subview isKindOfClass:[UIView class]]) {
			if (dockScale != 1.0) {
				subview.transform = CGAffineTransformMakeScale(dockScale, dockScale);
			}
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
		NSNumber *scaleNum = settings[@"dockScale"];
		NSNumber *hideLabelsNum = settings[@"hideLabels"];
		if (enabledNum) enabled = [enabledNum boolValue];
		if (radiusNum) {
			float raw = [radiusNum floatValue];
			cornerRadius = 5.0 + (raw - 1.0) * (45.0 / 99.0);
		}
		if (scaleNum) {
			float raw = [scaleNum floatValue];
			dockScale = 0.2 + (raw / 100.0) * 1.6;
		}
		if (hideLabelsNum) hideLabels = [hideLabelsNum boolValue];
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
