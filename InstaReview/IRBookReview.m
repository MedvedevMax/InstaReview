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
        self.reviewer = [self emptyStringOrValue:dic[@"reviewer"]];

        self.date = [NSDate dateWithTimeIntervalSince1970:[[self zeroStringOrValue:dic[@"date"]] intValue]];
        self.title = [self emptyStringOrValue:dic[@"title"]];
        self.text = [self emptyStringOrValue:dic[@"text"]];
        
        self.rate = @([[self zeroStringOrValue:dic[@"rate"]] intValue]);
    }
    
    return self;
}

- (NSString *)emptyStringOrValue:(id)dictionaryObject
{
    return [dictionaryObject isKindOfClass:[NSNull class]] ? @"" : dictionaryObject;
}

- (NSString *)zeroStringOrValue:(id)dictionaryObject
{
    return [dictionaryObject isKindOfClass:[NSNull class]] ? @"0" : dictionaryObject;
}

@end
