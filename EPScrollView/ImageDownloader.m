//
//  ImageDownloader.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 23.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "ImageDownloader.h"
#import "Global.h"

static ImageDownloader *_sharedImageDownloader;

@interface ImageDownloader ()

- (id)init;

@end

@implementation ImageDownloader

#pragma mark - Singleton and lifetime methods

+ (ImageDownloader *)sharedInstance
{
    @synchronized(self)
    {
        if (_sharedImageDownloader == nil) {
            _sharedImageDownloader = [[ImageDownloader alloc] init];
        }
    }
    return _sharedImageDownloader;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (NSData *)downloadPictureDataWithURL:(NSString *)urlString
{
    // Send synchronous GET query with given URL
    NSError *err = nil;
    NSURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kNetworkTimeout];
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] != 200) {
        // Catch an error
        if ([err localizedDescription])
            VLog(@"DEBUG: URL %@ ; HTTP error: %@", url, [err localizedDescription]);
        else {
            VLog(@"DEBUG: URL %@ ; HTTP status code: %ld", url, (long)[httpResponse statusCode]);
        }
        receivedData = nil;
    }
    
    return receivedData;
}

- (NSData *)downloadPictureDataByUrlFormat:(NSString *)urlFormat andWidth:(NSInteger)width andHeight:(NSInteger)height
{
    return [self downloadPictureDataWithURL:[NSString stringWithFormat:urlFormat, width, height]];
}

@end
