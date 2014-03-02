//
//  IRHTTPClient.h
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRHTTPClient : NSObject

- (NSString*)uploadImage:(UIImage *)image;
- (UIImage*)downloadImage:(NSString *)url;

@end
