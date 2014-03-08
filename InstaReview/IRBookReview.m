//
//  IRBookReview.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookReview.h"

@implementation IRBookReview

- (id)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.url = [self emptyStringOrValue:dic[@"url"]];
        self.date = [self emptyStringOrValue:dic[@"data"]];
        self.shortText = [self emptyStringOrValue:dic[@"short"]];
        self.reviewer = [self emptyStringOrValue:dic[@"reviewer"]];
        self.reviewerUrl = [self emptyStringOrValue:dic[@"reviewerUrl"]];
        self.likes = [self emptyStringOrValue:dic[@"likes"]];
    }
    
    return self;
}

- (NSString *)emptyStringOrValue:(id)dictionaryObject
{
    return [dictionaryObject isKindOfClass:[NSNull class]] ? @"" : dictionaryObject;
}

@end
