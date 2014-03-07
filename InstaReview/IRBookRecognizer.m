//
//  IRBookRecognizer.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookRecognizer.h"

@implementation IRBookRecognizer

#define IR_API_URL @"http://instareview-medvedev.rhcloud.com/mock"

- (NSString*)getBookNameForUploadedImage:(NSString *)url
{
    NSURL *apiUrl = [NSURL URLWithString:
                     [IR_API_URL stringByAppendingString:[@"/recognize/?imgurl="
                                                          stringByAppendingString:[self encodeURL:url]]]];
    NSLog(@"Accessing image recognition at: %@", apiUrl);
    
    NSData *queryResult = [NSData dataWithContentsOfURL:apiUrl];
    if (!queryResult) {
        NSLog(@"Error getting API-page content");
        return nil;
    }
    
    NSError *error = NULL;
    NSDictionary *parsedResult = [NSJSONSerialization JSONObjectWithData:queryResult options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error);
    }
    
    if ([parsedResult isKindOfClass:[NSDictionary class]]) {
        NSString *response = [parsedResult valueForKey:@"response"];
        NSString *value = [parsedResult valueForKey:@"value"];
        
        if ([response isEqualToString:@"success"]) {
            return value;
        }
    }
    
    return nil;
}

- (NSString*)encodeURL:(NSString *)unescaped
{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end