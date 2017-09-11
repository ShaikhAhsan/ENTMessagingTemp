//
//  ENTMessaging.h
//  EntertainerMessaging
//
//  Created by Muhammad Ahsan on 9/5/17.
//  Copyright © 2017 THE ENTERTAINER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENTMessaging : NSObject

@property(nonatomic, retain) NSString* base_url;
@property(nonatomic, retain) NSString* location_id;
@property(nonatomic, retain) NSString* user_id;
@property(nonatomic, retain) NSString* user_email;
@property(nonatomic, retain) NSString* user_country_code;
@property(nonatomic, retain) NSString* device_language;
@property(nonatomic, retain) NSString* device_token;
@property(nonatomic, retain) NSString* company_code;
@property(nonatomic, retain) NSMutableArray *inAppMessages;

@property (nonatomic, copy) void(^didRecivePushMessagewithMessage)(NSString* message, NSURL* url);
@property (nonatomic, copy) void(^didClickedOnInAppMessageLink)(NSURL* url);

+(ENTMessaging *)sharedManager;

-(void)updateDeviceToken;
-(void)handelPushNotifications:(NSDictionary*)userInfo;
-(void)handelPushNotificationWithMessage:(NSString*)message link:(NSString*)urlString;
-(void)showInAppMeesageWithTagetId:(NSInteger)trg_pnt;

@end
