//
//  ENTINAppMessagePopup.m
//  TestView
//
//  Created by The Entertainer on 10/1/14.
//  Copyright (c) 2014 The Entertainer. All rights reserved.
//

#import "ENTINAppMessagePopup.h"
#import "AppDelegate.h"
#import "ENTMessaging.h"

@interface ENTINAppMessagePopup ()

- (void)show;

@end

@implementation ENTINAppMessagePopup

-(id)initWithFrames:(CGRect)frame messageType:(ENTInAppMessageType)type widthMargin:(int)widthMargin heightMargin:(int)heightMargin{
    
    switch (type) {
        case ENTInAppMessageTypeTop:
        {
            if ((self = [super initWithFrame:frame])) {
                self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-widthMargin*2, 64)];
                self.webView.delegate=self;
                self.webView.scrollView.scrollEnabled = NO;
                self.webView.scrollView.bounces = NO;
                [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.webView.frame.size.width-40, 10, 40, 40)];
                [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setImage:[UIImage imageNamed:@"popup-close-inApp"] forState:UIControlStateNormal];
                [self.webView addSubview:closeButton];
                [self topAnimation];
            }
        }
        break;
        case ENTInAppMessageTypeBottom:
        {
            if ((self = [super initWithFrame:frame])) {
                self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0 ,self.frame.size.width-widthMargin*2, self.frame.size.height-heightMargin*2)];
                self.webView.delegate=self;
                self.webView.scrollView.scrollEnabled = NO;
                self.webView.scrollView.bounces = NO;
                [self setClipsToBounds:YES];
                [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.webView.frame.size.width-40, 0, 40, 40)];
                [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setImage:[UIImage imageNamed:@"popup-close-inApp"] forState:UIControlStateNormal];
                [self.webView addSubview:closeButton];
                [self bottomAnimation];
            }
        }
        break;
        case ENTInAppMessageTypeFull:
        {
            if ((self = [super initWithFrame:frame])) {
                self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(widthMargin, heightMargin, self.frame.size.width-widthMargin*2, self.frame.size.height-heightMargin*2)];
                self.webView.delegate=self;
                //self.webView.scrollView.contentInset = UIEdgeInsetsMake(13,5.0,0.0,0.0);
                [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.webView.frame.size.width-40, 10, 40, 40)];
                [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setImage:[UIImage imageNamed:@"popup-close-inApp"] forState:UIControlStateNormal];
                [self.webView addSubview:closeButton];
                [self topAnimation];
            }
        }
        break;
        case ENTInAppMessageTypeMiddle:
        {
            if ((self = [super initWithFrame:frame])) {
                self.webView=[[UIWebView alloc]initWithFrame:CGRectMake(widthMargin, heightMargin, self.frame.size.width-widthMargin*2, self.frame.size.height-heightMargin*2)];
                self.webView.delegate=self;
                
                [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
                UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.webView.frame.size.width-40, 0, 40, 40)];
                [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setImage:[UIImage imageNamed:@"popup-close-inApp"] forState:UIControlStateNormal];
                [self.webView addSubview:closeButton];
                //[self.webView addSubview:closeButton];
                [self topAnimation];
            }
        }
        break;
        default:
        break;
    }
    return self;
}

- (void)setHTMLString:(NSString *)htmlString {
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    UIView *patternView = [self ENTPatternViewWithFrame:self.webView.frame];
    patternView.clipsToBounds = YES;
    patternView.layer.cornerRadius = 5.0;
    [self addSubview:patternView];
    [self addSubview:self.webView];
}

- (void)show{
    [[self topMostController].view addSubview:self];
}

- (UIViewController*) topMostController{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


-(void)dismiss{
    [self removeFromSuperview];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        //[[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:^(BOOL success) {
        //}];
        [ENTMessaging sharedManager].didClickedOnInAppMessageLink(request.URL);
        //[[ENTMessaging sharedManager].delegate didClickedOnInAppMessageLink:request.URL];
        return NO;
    }
    return YES;
}

-(BOOL)containsStringInMainString:(NSString*)MainString subString:(NSString*)subString{
    BOOL result=FALSE;
    if ([MainString rangeOfString:subString].location == NSNotFound) {
        result=FALSE;
    } else {
        result=TRUE;
    }
    return result;
}

-(void)bottomAnimation{
    float y=self.webView.frame.origin.y;
    self.webView.frame=CGRectMake(self.webView.frame.origin.x, self.webView.frame.size.height-self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
    [UIView animateWithDuration:.4 animations:^{
        self.webView.frame=CGRectMake(self.webView.frame.origin.x, y, self.webView.frame.size.width, self.webView.frame.size.height);
    }];
}

-(void)topAnimation{
    float y=self.webView.frame.origin.y;
    self.webView.frame=CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y-self.webView.frame.size.height, self.webView.frame.size.width, self.webView.frame.size.height);
    [UIView animateWithDuration:.4 animations:^{
        self.webView.frame=CGRectMake(self.webView.frame.origin.x, y, self.webView.frame.size.width, self.webView.frame.size.height);
    }];
}

-(void)triggerPoint:(NSInteger)targetPoint location_id:(int)loc_id usingBool:(BOOL)isInAppMessage{
    
}

-(UIView *)ENTPatternViewWithFrame:(CGRect)frame {
    return [self ENTPatternViewWithFrame:frame gradient:NO];
}

-(UIView *)ENTPatternViewWithFrame:(CGRect)frame gradient:(BOOL)useGradient {
    UIImage *patternImage = [[UIImage imageNamed:@"entertainer-pattern"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    UIImageView *patternView = [[UIImageView alloc] initWithFrame:frame];
    patternView.image = patternImage;
    
    if(useGradient){
        CAGradientLayer *gradiantMask = [CAGradientLayer layer];
        gradiantMask.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        gradiantMask.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
        gradiantMask.startPoint = CGPointMake(0.0, 0.0);
        gradiantMask.endPoint = CGPointMake(0.0, .25);
        patternView.layer.mask = gradiantMask;
    }
    
    return patternView;
}
@end
