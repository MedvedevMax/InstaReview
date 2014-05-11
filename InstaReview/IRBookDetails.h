//
//  IRBookDetails.h
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRBookDetails : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *alternativeName;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *description;

@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *ratingCount;
@property (nonatomic, strong) NSNumber *year;

@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, strong) NSArray *reviews;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
