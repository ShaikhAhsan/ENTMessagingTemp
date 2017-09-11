//
//  ENTInAppMessage.h
//  TheEntertainer
//
//  Created by The Entertainer on 9/30/14.
//  Copyright (c) 2014 Future Workshops. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENTInAppMessage : NSObject

@property (nonatomic, assign) int32_t trg_pnt;
@property (nonatomic, assign) int32_t msg_id;
@property (nonatomic, strong) NSDate  *e_date;
@property (nonatomic, strong) NSDate  *s_date;

@end
