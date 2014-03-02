//
//  IRHTTPClient.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRHTTPClient.h"
#import "MLIMGURUploader.h"

@implementation IRHTTPClient

#define IMGUR_CLIENT_ID @"abefe443c6d1bee"

- (NSString*)uploadImage:(UIImage *)image
{
    __block NSString *resultUrl = nil;
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    [MLIMGURUploader uploadPhoto:imgData title:@"Book cover" description:@"cover of some book" imgurClientID:IMGUR_CLIENT_ID completionBlock:^(NSString *result) {
        resultUrl = result;
    } failureBlock:nil];
    
    return resultUrl;
}

- (UIImage*)downloadImage:(NSString *)url
{
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    if (!imageData) {
        return nil;
    }
    
    return [UIImage imageWithData:imageData];
}

@end
