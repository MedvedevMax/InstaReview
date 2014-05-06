
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

        double dateInterval = [[self zeroStringOrValue:dic[@"date"]] doubleValue];
        if (dateInterval > 0) {
            self.date = [NSDate dateWithTimeIntervalSince1970:dateInterval];
        }
        else {
            self.date = nil;
        }
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.reviewer = [aDecoder decodeObjectForKey:@"reviewer"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.rate = [aDecoder decodeObjectForKey:@"rate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.reviewer forKey:@"reviewer"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.rate forKey:@"rate"];
}

@end
