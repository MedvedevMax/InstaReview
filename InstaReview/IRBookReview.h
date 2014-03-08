//
//  IRBookReview.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRBookReview : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *shortText;
@property (nonatomic, strong) NSString *reviewer;
@property (nonatomic, strong) NSString *reviewerUrl;
@property (nonatomic, strong) NSString *likes;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
