//
//  OMColorHelper.m
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import "OMColorHelper.h"
#import "OMPlainColorWell.h"
#import "OMColorFrameView.h"

#import "objc/runtime.h"

@implementation NSTextView (ExtendMenu)
+ (void)extend
{
    if (![NSTextView instancesRespondToSelector:@selector(menuForEvent:)]) {
        Class cls = [NSTextView class];
        Method extended = class_getInstanceMethod(cls, @selector(exteded_menuForEvent:));
        SEL name = @selector(presentingViewController);
        IMP imp = method_getImplementation(extended);
        const char *types = method_getTypeEncoding(extended);
        class_addMethod(cls, name, imp, types);
    }
}

- (NSMenu *)exteded_menuForEvent:(NSEvent *)event
{
    NSMenu *menu = [self menuForEvent:event];
    
    if (self.selectedRanges.count > 0) {
        
    }
    return menu;
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    return [self exteded_menuForEvent:event];
}
@end

@implementation OMColorHelper

@synthesize colorWell = _colorWell;
@synthesize colorFrameView = _colorFrameView;
@synthesize textView = _textView;
@synthesize selectedText = _selectedText;
@synthesize selectedTextRange = _selectedTextRange;

#pragma mark - Plugin Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [NSTextView extend];
    
	NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
	if (editMenuItem) {
		[[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
		
		NSMenuItem *sendToQiitaMenuItem = [[NSMenuItem alloc] initWithTitle:@"Send to Qiita..." action:@selector(sendToQiita:) keyEquivalent:@""];
		[sendToQiitaMenuItem setTarget:self];
		[[editMenuItem submenu] addItem:sendToQiitaMenuItem];
    }
    
    [self activate];
}

#pragma mark - Preferences

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(sendToQiita:)) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
	}
    
	return YES;
}

- (void)sendToQiita:(id)sender
{
}

#pragma mark -

- (void)activate
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		}
	}
	if (self.textView) {
		NSNotification *notification = [NSNotification notificationWithName:NSTextViewDidChangeSelectionNotification object:self.textView];
		[self selectionDidChange:notification];
		
	}
}

- (void)deactivate
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextViewDidChangeSelectionNotification object:nil];
}

#pragma mark - Color Insertion

- (void)insertColor:(id)sender
{
	if (!self.textView) {
		NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
		if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]) {
			self.textView = (NSTextView *)firstResponder;
		} else {
			NSBeep();
			return;
		}
	}
}

- (void)activateColorWell
{
	[self.colorWell activate:YES];
}

#pragma mark - Text Selection Handling

- (void)selectionDidChange:(NSNotification *)notification
{
	if ([[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [[notification object] isKindOfClass:[NSTextView class]]) {
		self.textView = (NSTextView *)[notification object];
		
        NSArray *selectedRanges = self.textView.selectedRanges;
        if (selectedRanges.count > 0) {
            NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
            NSString *text = self.textView.textStorage.string;
            _selectedText = [text substringWithRange:selectedRange];
        }
        else {
            _selectedText = nil;
        }
	}
}

#pragma mark - View Initialization

#pragma mark -

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
