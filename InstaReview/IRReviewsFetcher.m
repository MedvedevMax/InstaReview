//
//  IRReviewsFetcher.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsFetcher.h"
#import "IRBookDetails.h"

#define IR_API_URL @"http://instareview-medvedev.rhcloud.com/1.1/"
//#define IR_API_URL @"http://localhost:8888/1.0/"

@implementation IRReviewsFetcher

- (IRRecognitionResponse *)getResponseForCoverUrl:(NSString *)imageUrl
{
    NSURL *queryUrl = [NSURL URLWithString:
                       [NSString stringWithFormat:@"%@?imgurl=%@",
                        IR_API_URL, [self encodeURL:imageUrl]]];
    
    NSLog(@"Querying API at %@", queryUrl);
    NSData *apiResponse = [NSData dataWithContentsOfURL:queryUrl];
    if (!apiResponse) {
        NSLog(@"Can't get the response");
        return nil;
    }
    
    return [IRRecognitionResponse responseWithJSON:apiResponse];
}

- (NSString*)encodeURL:(NSString *)unescaped
{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
