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
        self.url = dic[@"url"];
        self.date = dic[@"data"];
        self.shortText = dic[@"short"];
        self.reviewer = dic[@"reviewer"];
        self.reviewerUrl = dic[@"reviewerUrl"];
        self.likes = dic[@"likes"];
    }
    
    return self;
}

@end
