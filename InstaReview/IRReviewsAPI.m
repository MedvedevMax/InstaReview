//
//  IRReviewsAPI.m
//  InstaReview
//
//  Created by Max Medvedev on 3/3/14.
//  Copyright (c) 2014 Max Medvedev. All rights reserved.
//

#import "IRReviewsAPI.h"

#import "IRReviewsFetcher.h"
#import "IRHTTPClient.h"
#import "UIImage+Resize.h"

@interface IRReviewsAPI ()

@property (nonatomic, strong) IRReviewsFetcher *reviewsFetcher;
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

- (NSArray*)getBooksForCover:(UIImage *)coverImage
{
    // Posting to imgur
    NSString *coverImageUrl = [self.httpClient uploadImage:[self prepareImageForRecognition:coverImage]];
    
    if (!coverImageUrl) {
        return nil;
    }

    NSArray *books = [self.reviewsFetcher getBooksForCoverPhotoUrl:coverImageUrl];
    return books;
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

- (void)downloadCoverForBook:(IRBookDetails *)book
{
    @synchronized(book.coverImage)
    {
        if (!book.coverImage && book.coverUrl.length > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self.httpClient downloadImage:book.coverUrl];

                dispatch_sync(dispatch_get_main_queue(), ^{
                    book.coverImage = image;
                });
            });
        }
    }
}

#pragma mark - Properties lazy instantiation

- (IRReviewsFetcher*)reviewsFetcher
{
    if (!_reviewsFetcher)
        _reviewsFetcher = [[IRReviewsFetcher alloc] init];
    
    return _reviewsFetcher;
}

- (IRHTTPClient*)httpClient
{
    if (!_httpClient) {
        _httpClient = [[IRHTTPClient alloc] init];
    }
    
    return _httpClient;
}

@end
