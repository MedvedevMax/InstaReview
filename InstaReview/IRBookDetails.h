//
//  IRBookDetails.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRBookDetails : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *published;
@property (nonatomic, strong) NSString *description;

@property (nonatomic, strong) NSArray *reviews;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
