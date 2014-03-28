//
//  IRHTTPClient.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRHTTPClient.h"

@implementation IRHTTPClient

- (UIImage*)downloadImage:(NSString *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    if (!imageData) {
        return nil;
    }
    
    return [UIImage imageWithData:imageData];
}

@end
