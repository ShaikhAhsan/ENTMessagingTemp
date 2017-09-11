//
//  ENTINAppMessagePopup.h
//  TestView
//
//  Created by The Entertainer on 10/1/14.
//  Copyright (c) 2014 The Entertainer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTINAppMessagePopup.h"
#import "ENTInAppMessage.h"

typedef NS_ENUM (NSUInteger, ENTInAppMessageType){
    ENTInAppMessageTypeTop,
    ENTInAppMessageTypeBottom,
    ENTInAppMessageTypeMiddle,
    ENTInAppMessageTypeFull
};


@interface ENTINAppMessagePopup : UIView<UIWebViewDelegate>
{
    UIView* _dimView;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *HTMLString;

-(id)initWithFrames:(CGRect)frame messageType:(ENTInAppMessageType)type widthMargin:(int)widthMargin heightMargin:(int)heightMargin;
- (void)show;

@end
