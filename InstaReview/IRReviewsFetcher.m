//
//  IRReviewsFetcher.m
//  InstaReview
//
//  Created by Max Medvedev on 3/8/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsFetcher.h"
#import "IRBookDetails.h"

#define IR_API_URL @"http://api.getinstareview.com/"

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

- (IRRecognitionResponse *)getResponseForJPEGRepresentation:(NSData *)jpegRepresentation
{
    #define URL_REQUEST_TRY_COUNT 4
    #define URL_REQUEST_TIMEOUT 20
    
    NSURL *queryUrl = [NSURL URLWithString:IR_API_URL];
    NSLog(@"Querying API using POST request at %@", queryUrl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:queryUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jpegRepresentation];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    request.timeoutInterval = URL_REQUEST_TIMEOUT;
    
    NSData *apiResponse = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    for (int tryNumber = 0; tryNumber < URL_REQUEST_TRY_COUNT; tryNumber++) {
        NSError *error;
        NSLog(@"Sending url request, try #%d", tryNumber);
        apiResponse = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:nil
                                                        error:&error];
        if (!error) {
            break;
        }
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
