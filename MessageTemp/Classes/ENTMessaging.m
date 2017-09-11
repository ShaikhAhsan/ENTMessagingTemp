//
//  ENTMessaging.m
//  EntertainerMessaging
//
//  Created by Muhammad Ahsan on 9/5/17.
//  Copyright © 2017 THE ENTERTAINER. All rights reserved.
//

#import "ENTMessaging.h"
#import <AFHTTPClient.h>
#import "ENTInAppMessage.h"
#import "ENTINAppMessagePopup.h"


/*
 @protocol ENTMessagingDelegate <NSObject>
 
 -(void)didRecivePushMessagewithMessage:(NSString*)message link:(NSURL*)url;
 -(void)didClickedOnInAppMessageLink:(NSURL*)url;
 
 @end
 
 @property (nonatomic, weak) id<ENTMessagingDelegate> delegate;
 
 */

@implementation ENTMessaging

static ENTMessaging *_sharedUserDefaultsManagerInstance;


+ (ENTMessaging *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUserDefaultsManagerInstance = [[ENTMessaging alloc] init];
    });
    return _sharedUserDefaultsManagerInstance;
}


-(void)configureInAppMessages{
    if (_user_id || _location_id) {
        
        AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@%@", _base_url, @"get_CustomerMessages"]]];
        [client getPath:nil
             parameters:@{
                          @"customer_id":_user_id,
                          @"platform_id":@(3),
                          @"location_id":_location_id,
                          @"lang":_device_language,
                          @"language": _device_language,
                          @"wlcompany" : _company_code
                          } success:^(AFHTTPRequestOperation *operation, id responseObject){
                              NSDictionary *inAppMessages = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                              _inAppMessages = [[NSMutableArray alloc]init];
                              if(inAppMessages&&[inAppMessages valueForKey:@"message"]&&[[inAppMessages valueForKey:@"message"] isEqualToString:@"Customer Message Retrieved."]&&[[inAppMessages valueForKey:@"messages"] isKindOfClass:[NSArray class]]){
                                  [_inAppMessages removeAllObjects];
                                  NSArray* inAppMessagesArray= [[NSArray alloc]initWithArray:[inAppMessages valueForKey:@"messages"]];
                                  NSDateFormatter *sDateFormatter = [[NSDateFormatter alloc] init];
                                  [sDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                  
                                  NSDateFormatter *eDateformatter = [[NSDateFormatter alloc] init];
                                  [eDateformatter setDateFormat:@"yyyy-MM-dd"];
                                  
                                  for(int i=0; i < inAppMessagesArray.count; i++){
                                      ENTInAppMessage *inAppMessageObject=[[ENTInAppMessage alloc]init];
                                      inAppMessageObject.msg_id=[[[inAppMessagesArray objectAtIndex:i] valueForKey:@"msg_id"]intValue];
                                      inAppMessageObject.trg_pnt=[[[inAppMessagesArray objectAtIndex:i] valueForKey:@"trg_pnt"]intValue];
                                      inAppMessageObject.s_date=[sDateFormatter dateFromString:[[inAppMessagesArray objectAtIndex:i] valueForKey:@"s_date"]];
                                      inAppMessageObject.e_date=[eDateformatter dateFromString:[[inAppMessagesArray objectAtIndex:i] valueForKey:@"e_date"]];
                                      [_inAppMessages addObject:inAppMessageObject];
                                  }
                                  //                                  [self showInAppMeesageWithTagetId:1];
                              }
                          }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                              NSLog(@"Error %@",error);
                          }];
    }
}

-(void)updateDeviceToken{
    [self configureInAppMessages];
    id location_id = _location_id;
    
    if (!_user_id || !_location_id) {
        return ;
    }
    
    NSString *country = _user_country_code ? _user_country_code : @"unknown";
    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    params[@"testing_type"] = DEBUG_MODE ? @"1" : @"0";//mentioned by Raheel
    NSLog(@"Testing Type: %@",params[@"testing_type"]);
    params[@"language"] = _device_language ;
    params[@"lang"] = _device_language ;
    params[@"device_token_type"] = @"iphone";
    params[@"device_token_type"] = @"iphone";
    params[@"wlcompany"] = _company_code;
    
    if(_user_id)
    params[@"magento_customer_id"] = _user_id;
    if(_user_email)
    params[@"email"] = _user_email;
    if(location_id)
    params[@"location_id"] = _location_id;
    if(location_id)
    params[@"location"] = _location_id;
    if(country)
    params[@"country"] = country;
    if(_device_token)
    params[@"device_token"] = _device_token;
    
    AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_base_url,@"save_device_token"]]];
    [client getPath:nil parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"Success");
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if(response&&[response valueForKey:@"success"]&&[[response valueForKey:@"success"] integerValue]){
            
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Failure");
    }];
}

-(void)showInAppMeesageWithTagetId:(NSInteger)trg_pnt{
    NSLog(@"showInAppMeesageWithTagetID  %@",@(trg_pnt));
    if ( !_user_id || !_location_id ) {
        return ;
    }
    
    NSArray* inAppMessages = _inAppMessages;
    NSComparisonResult start_Date_result,end_date_result;
    
    for(int i=0;i<inAppMessages.count;i++){
        ENTInAppMessage* inAppMessage=[inAppMessages objectAtIndex:i];
        if(inAppMessage.trg_pnt==trg_pnt){
            start_Date_result = [[NSDate date] compare:inAppMessage.s_date]; // comparing two dates
            end_date_result = [[NSDate date] compare:inAppMessage.e_date]; // comparing two dates
            
            if(end_date_result==NSOrderedAscending && start_Date_result==NSOrderedDescending){
                AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _base_url, @"get_inApp_MessageById"]]];
                [client getPath:nil parameters:@{@"message_id" : @(inAppMessage.msg_id),
                                                 @"language" : _device_language,
                                                 @"location_id" : _location_id,
                                                 @"lang" : _device_language ,
                                                 @"platform_id" : @(3),
                                                 @"wlcompany" : _company_code
                                                 } success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                     NSDictionary *inAppMessages = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                                     //THIS CHECK NEEDS TO BE UPDATED ON MULTI LAGUAGE
                                                     if(inAppMessages&&[inAppMessages valueForKey:@"message"]&&[[inAppMessages valueForKey:@"message"] isEqualToString:@"In App Message Retrieved."]&&[[inAppMessages valueForKey:@"messages"] isKindOfClass:[NSDictionary class]]){
                                                         inAppMessages=[inAppMessages valueForKey:@"messages"];
                                                         
                                                         ENTInAppMessageType type= ENTInAppMessageTypeMiddle;
                                                         if([[inAppMessages valueForKey:@"position"] isEqualToString:@"top"])
                                                         type= ENTInAppMessageTypeTop;
                                                         if([[inAppMessages valueForKey:@"position"] isEqualToString:@"bottom"])
                                                         type= ENTInAppMessageTypeBottom;
                                                         if([[inAppMessages valueForKey:@"position"] isEqualToString:@"middle"])
                                                         type= ENTInAppMessageTypeMiddle;
                                                         if([[inAppMessages valueForKey:@"position"] isEqualToString:@"full"])
                                                         type= ENTInAppMessageTypeFull;
                                                         
                                                         
                                                         switch (type) {
                                                             case ENTInAppMessageTypeTop:
                                                             {
                                                                 ENTINAppMessagePopup *popup = [[ENTINAppMessagePopup alloc] initWithFrames:CGRectMake(0, 0, 320, 64)messageType:ENTInAppMessageTypeTop widthMargin:0 heightMargin:0];
                                                                 [popup setHTMLString:[inAppMessages valueForKey:@"m_en"]];
                                                                 [popup show];
                                                             }
                                                             break;
                                                             case ENTInAppMessageTypeBottom:
                                                             {
                                                                 ENTINAppMessagePopup *popup = [[ENTINAppMessagePopup alloc] initWithFrames:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-58, 320, 58)messageType:ENTInAppMessageTypeBottom widthMargin:0 heightMargin:0];
                                                                 [popup setHTMLString:[inAppMessages valueForKey:@"m_en"]];
                                                                 [popup show];
                                                             }
                                                             break;
                                                             case ENTInAppMessageTypeFull:
                                                             {
                                                                 ENTINAppMessagePopup *popup = [[ENTINAppMessagePopup alloc] initWithFrames:[[UIScreen mainScreen] bounds]messageType:ENTInAppMessageTypeFull widthMargin:0 heightMargin:0];
                                                                 [popup setHTMLString:[NSString stringWithFormat:@"%@",[inAppMessages valueForKey:@"m_en"]]];
                                                                 [popup show];
                                                             }
                                                             break;
                                                             case ENTInAppMessageTypeMiddle:
                                                             {
                                                                 ENTINAppMessagePopup *popup = [[ENTINAppMessagePopup alloc] initWithFrames:[[UIScreen mainScreen] bounds] messageType:ENTInAppMessageTypeMiddle widthMargin:0 heightMargin:40];
                                                                 [popup setHTMLString:[inAppMessages valueForKey:@"m_en"]];
                                                                 [popup show];
                                                             }
                                                             break;
                                                             default:
                                                             break;
                                                         }
                                                     }
                                                 }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                     
                                                 }];
                
            }
            //            AFHTTPClient *client = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_base_url,@"inapp_Message_Seen"]]];
            //            [client getPath:nil parameters:@{@"message_id":@(inAppMessage.msg_id),
            //                                             @"language":_device_language ,
            //                                             @"lang":_device_language ,
            //                                             @"os":@"ios",
            //                                             @"customer_id":_user_id,
            //                                             @"wlcompany" : _company_code
            //                                             } success:^(AFHTTPRequestOperation *operation, id responseObject){
            //
            //                                             }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            //                                             }];
            //            [_inAppMessages removeObjectAtIndex:i];
            break;
        }
    }
}

-(void)handelPushNotifications:(NSDictionary*)userInfo{
    if(userInfo && [userInfo isKindOfClass:[NSDictionary class]] && [userInfo valueForKey:@"ab_uri"] && [[userInfo valueForKey:@"aps"] valueForKey:@"alert"] && [[userInfo valueForKey:@"ab_uri"] isKindOfClass:[NSString class]]&& [[userInfo valueForKey:@"ab_uri"] length] > 0){
        self.didRecivePushMessagewithMessage([[userInfo valueForKey:@"aps"] valueForKey:@"alert"], [NSURL URLWithString:[userInfo valueForKey:@"ab_uri"]]);
        //[self.delegate didRecivePushMessagewithMessage:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] link:[NSURL URLWithString:[userInfo valueForKey:@"ab_uri"]]];
    }
}

-(void)handelPushNotificationWithMessage:(NSString*)message link:(NSString*)urlString{
    if(urlString && [urlString isKindOfClass:[NSString class]]&& [urlString length] > 0){
        //        [self.delegate didRecivePushMessagewithMessage:message link:[NSURL URLWithString:urlString]];
        self.didRecivePushMessagewithMessage(message, [NSURL URLWithString:urlString]);
    }
}

@end
