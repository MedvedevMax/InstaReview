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

- (NSString*)getBookNameForCover:(UIImage *)coverImage
{
    // Resizing cover image to a smaller size
    CGSize size = CGSizeMake(240, 320);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [coverImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *smallerCover = [self cropImage:UIGraphicsGetImageFromCurrentImageContext() toRect:CGRectMake(24, 32, 408, 544)];
    UIGraphicsEndImageContext();
    
    // Posting to imgur
    NSString *coverImageUrl = [self.httpClient uploadImage:smallerCover];
    
    if (!coverImageUrl) {
        return nil;
    }

    NSString *bookName = [self.bookRecognizer getBookNameForUploadedImage:coverImageUrl];
    return bookName;
}

- (UIImage *)cropImage:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
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
