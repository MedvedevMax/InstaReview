//
//  IRRecognitionResponse.m
//  InstaReview
//
//  Created by Max Medvedev on 3/29/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRRecognitionResponse.h"
#import "IRBookDetails.h"

@implementation IRRecognitionResponse

+ (IRRecognitionResponse *)responseWithJSON:(NSData *)jsonData
{
    IRRecognitionResponse *response = [[IRRecognitionResponse alloc] init];
    response.success = NO;
    response.confidence = 0.0f;
    response.books = nil;
    
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error parsing jQuery: %@", error);
        return response;
    }
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Response is not dictionary");
        return response;
    }
    
    NSString *responseValue = [dictionary objectForKey:@"response"];
    id confidenceRef = [dictionary objectForKey:@"confidence"];
    NSArray *bookDics = [dictionary objectForKey:@"reviews"];
    
    if (![responseValue isEqualToString:@"success"]) {
        NSLog(@"Query failed (response = %@)", responseValue);
        return response;
    }
    
    if (![bookDics isKindOfClass:[NSArray class]]) {
        NSLog(@"[Reviews] content is not an array");
        return response;
    }
    
    if (![confidenceRef isKindOfClass:[NSNull class]]) {
        response.confidence = [confidenceRef floatValue];
    }
    
    NSMutableArray *books = [[NSMutableArray alloc] init];
    
    for (NSDictionary *bookDic in bookDics) {
        [books addObject:[[IRBookDetails alloc] initWithDictionary:bookDic]];
    }
    
    response.success = YES;
    response.books = [books copy];
    return response;
}

@end
