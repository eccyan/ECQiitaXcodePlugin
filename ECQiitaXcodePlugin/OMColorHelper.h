//
//  OMColorHelper.h
//  OMColorHelper
//
//  Created by Ole Zorn on 09/07/12.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class OMColorFrameView, OMPlainColorWell;

@interface OMColorHelper : NSObject

@property (nonatomic, strong) OMPlainColorWell *colorWell;
@property (nonatomic, strong) OMColorFrameView *colorFrameView;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic) NSString *selectedText;
@property (nonatomic) NSRange selectedTextRange;

- (void)activate;
- (void)deactivate;

@end
