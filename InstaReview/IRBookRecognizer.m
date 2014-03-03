//
//  IRBookRecognizer.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRBookRecognizer.h"

@implementation IRBookRecognizer

#define GOOGLE_IMAGE_RECOGNITION_API_URL @"http://images.google.com/searchbyimage?image_url=%@"

- (NSString*)getBookNameForUploadedImage:(NSString *)url
{
    NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:GOOGLE_IMAGE_RECOGNITION_API_URL, [self encodeURL:url]]];
    NSLog(@"Accessing image recognition at: %@", apiUrl);
   
    [[UIApplication sharedApplication] openURL:apiUrl];
    return nil;
    
    NSError *error;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:apiUrl]
                                                                  delegate:self
                                                          startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
    
    NSString *resultPageContent = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    if (error) {
        NSLog(@"Error getting API-page content");
        return nil;
    }
    
    return [self fetchRecognitionStringFromPageContent:resultPageContent];
}

- (NSString*)fetchRecognitionStringFromPageContent:(NSString *)content
{
    NSString *fetchedResult = nil;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\style=\"font-style:italic\">[^<]*<\\/a>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSLog(@"Parsing page content...");
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:content
                                                         options:0
                                                           range:NSMakeRange(0, [content length])];
    
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        fetchedResult = [content substringWithRange:rangeOfFirstMatch];
    }
    NSLog(@"Fetched string: %@", fetchedResult);
    
    return fetchedResult;
}

- (NSString*)encodeURL:(NSString *)unescaped
{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSLog(@"Redirection catched: %@", request.URL);
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"received data: %@", string);
}

@end