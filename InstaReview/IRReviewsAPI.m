//
//  IRReviewsAPI.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsAPI.h"
#import "IRBookRecognizer.h"
#import "IRHTTPClient.h"

@interface IRReviewsAPI ()

@property (nonatomic, strong) IRBookRecognizer *bookRecognizer;
@property (nonatomic, strong) IRHTTPClient *httpClient;

@end

@implementation IRReviewsAPI

+ (id)sharedInstance
{
    static IRReviewsAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[IRReviewsAPI alloc] init];
    });
    return _sharedInstance;
}

- (NSString*)getNameForCover:(UIImage *)coverImage
{
    NSString *coverImageUrl = [self.httpClient uploadImage:coverImage];
    
    if (!coverImageUrl) {
        return nil;
    }
    
    NSString *bookName = [self.bookRecognizer getBookNameForUploadedImage:coverImageUrl];
    return bookName;
}

#pragma mark - Properties lazy instantiation

- (IRBookRecognizer*)getBookRecognizer
{
    if (!_bookRecognizer)
        _bookRecognizer = [[IRBookRecognizer alloc] init];
    
    return _bookRecognizer;
}

- (IRHTTPClient*)getHttpClient
{
    if (!_httpClient) {
        _httpClient = [[IRHTTPClient alloc] init];
    }
    
    return _httpClient;
}

@end
