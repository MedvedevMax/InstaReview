//
//  IRBookReview.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IRBookReview : NSObject

@property (nonatomic, strong) NSString *reviewer;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *rate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
