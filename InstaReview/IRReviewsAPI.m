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
#import "UIImage+Resize.h"

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

- (NSString*)getBookNameForCover:(UIImage *)coverImage
{
    // Posting to imgur
    NSString *coverImageUrl = [self.httpClient uploadImage:[self prepareImageForRecognition:coverImage]];
    
    if (!coverImageUrl) {
        return nil;
    }

    NSString *bookName = [self.bookRecognizer getBookNameForUploadedImage:coverImageUrl];
    return bookName;
}

- (UIImage*)prepareImageForRecognition:(UIImage *)sourceImage
{
    #define IMG_WIDTH   480
    #define IMG_HEIGHT  640
    #define REMOVE_BORDER_PERCENTAGE    5
    
    UIImage *newImage = [sourceImage resizedImage:CGSizeMake(IMG_WIDTH, IMG_HEIGHT)
                             interpolationQuality:kCGInterpolationMedium];
    
    int borderWidth = IMG_WIDTH * REMOVE_BORDER_PERCENTAGE / 100.0;
    int borderHeight = IMG_HEIGHT * REMOVE_BORDER_PERCENTAGE / 100.0;
    newImage = [newImage croppedImage:CGRectMake(borderWidth, borderHeight,
                                                 IMG_WIDTH - borderWidth, IMG_HEIGHT - borderHeight)];
    
    return newImage;
}

#pragma mark - Properties lazy instantiation

- (IRBookRecognizer*)bookRecognizer
{
    if (!_bookRecognizer)
        _bookRecognizer = [[IRBookRecognizer alloc] init];
    
    return _bookRecognizer;
}

- (IRHTTPClient*)httpClient
{
    if (!_httpClient) {
        _httpClient = [[IRHTTPClient alloc] init];
    }
    
    return _httpClient;
}

@end
