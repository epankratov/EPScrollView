//
//  ItemView.m
//  EPScrollView
//
//  Created by Eugene Pankratov on 03.04.15.
//  Copyright (c) 2015 ua.net.pankratov. All rights reserved.
//

#import "ItemView.h"
#import "Global.h"
#import "ImageDownloader.h"

NSString *const kDefaultFontName       = @"OpenSans";
NSString *const kStringEmptyThumbnail  = @"bg";

const CGFloat kPlayerWideProportion    = 0.5625; // The wide screen 9:16
const CGFloat kInsetHorizontal         = 8.0;
const CGFloat kInsetVertical           = 12.0;
const CGFloat kFontSizeMainLabel       = 20.0;
const CGFloat kFontSizeDescription     = 15.0;
const CGFloat kFontSizeSynopsis        = 13.5;
const CGFloat kFontSizeMainLabel_Pad   = 24.0;
const CGFloat kFontSizeDescription_Pad = 18.0;
const CGFloat kFontSizeSynopsis_Pad    = 15.0;
const CGFloat kHeightMainLabel         = 28.0;
const CGFloat kHeightDescriptionLabel  = 20.0;

@interface ItemView () {
    UIView *_container;
    UILabel *_labelMain;
    UILabel *_labelAdditionalInfo;
    UIImageView *_image;
    UIImageView *_imageSmall;
    UIScrollView *_scrollViewSynopsis;
    UILabel *_labelSynopsis;
}

- (void)downloadImageForView:(UIImageView *)imageView withTempImageName:(NSString *)tempImageName;
+ (UIImage *)defaultImage;
- (CGRect)mainLabelRect;
- (CGRect)descriptionLabelRect;

@end

@implementation ItemView

- (instancetype)initWithDataItem:(DataItem *)item
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.dataItem = item;
        // Create and add container
        _container = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, kInsetHorizontal, kInsetVertical)];
        [_container setClipsToBounds:isPad()];
        [self addSubview:_container];
        // Other view properties
        [_container setBackgroundColor:[UIColor whiteColor]];
        _container.layer.cornerRadius  = 4.0;
        _container.layer.shadowColor   = RGBA_COLOR(202.0, 206.0, 209.0, 1).CGColor;
        _container.layer.shadowOffset  = CGSizeMake(0, 3);
        _container.layer.shadowRadius  = 6.0;
        _container.layer.shadowOpacity = 1.0;

        // Add images
        // Big image is the artwork made from random scene
        _image = [[UIImageView alloc] initWithImage:[ItemView defaultImage]];
        [_image setClipsToBounds:NO];
        [_container addSubview:_image];
        // Small image is a poster thumbnail
        _imageSmall = [[UIImageView alloc] initWithImage:[ItemView defaultImage]];
        _imageSmall.layer.cornerRadius = 3.0;
        _imageSmall.layer.borderWidth = 1.0;
        _imageSmall.layer.borderColor = [UIColor commonGrayColor].CGColor;
        [_imageSmall setClipsToBounds:YES];
        [_container addSubview:_imageSmall];
        
        // And labels
        _labelMain = [[UILabel alloc] initWithFrame:[self mainLabelRect]];
        [_labelMain setAdjustsFontSizeToFitWidth:YES];
        [_labelMain setBackgroundColor:[UIColor clearColor]];
        [_labelMain setFont:[UIFont fontWithName:kDefaultFontName size:isPad() ? kFontSizeMainLabel_Pad : kFontSizeMainLabel]];
        [_labelMain setText:self.dataItem.title];
        [_labelMain setTextColor:[UIColor mainLabelColor]];
        [_labelMain adjustFontSizeToFit];
        [_container addSubview:_labelMain];
    
        _labelAdditionalInfo = [[UILabel alloc] initWithFrame:[self descriptionLabelRect]];
        [_labelAdditionalInfo setAdjustsFontSizeToFitWidth:YES];
        [_labelAdditionalInfo setBackgroundColor:[UIColor clearColor]];
        [_labelAdditionalInfo setFont:[UIFont fontWithName:kDefaultFontName size:isPad() ? kFontSizeDescription_Pad : kFontSizeDescription]];
        [_labelAdditionalInfo setText:self.dataItem.additionalTitle];
        [_labelAdditionalInfo setTextColor:[UIColor descriptionLabelColor]];
        [_labelAdditionalInfo adjustFontSizeToFit];
        [_container addSubview:_labelAdditionalInfo];

        // Add scroll view for synopsis
        _scrollViewSynopsis = [[UIScrollView alloc] initWithFrame:[self scrollViewRect]];
        [_scrollViewSynopsis setUserInteractionEnabled:NO];
        [_container addSubview:_scrollViewSynopsis];
        
        _labelSynopsis = [[UILabel alloc] initWithFrame:_scrollViewSynopsis.bounds];
        [_labelSynopsis setNumberOfLines:0];
        [_labelSynopsis setAdjustsFontSizeToFitWidth:NO];
        [_labelSynopsis setBackgroundColor:[UIColor clearColor]];
        [_labelSynopsis setFont:[UIFont fontWithName:kDefaultFontName size:isPad() ? kFontSizeSynopsis_Pad : kFontSizeSynopsis]];
        [_labelSynopsis setText:self.dataItem.synopsis];
        [_labelSynopsis setTextColor:[UIColor descriptionLabelColor]];
        [_scrollViewSynopsis addSubview:_labelSynopsis];
        // Clip to parent bounds
        [self setClipsToBounds:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    [_container setFrame:CGRectInset(self.bounds, kInsetHorizontal, kInsetVertical)];
    CGFloat width  = _container.bounds.size.width + 2 * kInsetHorizontal;
    CGFloat height = width * kPlayerWideProportion;
    [_image setFrame:CGRectMake(0 - kInsetHorizontal, kInsetHorizontal + kHeightMainLabel + kHeightDescriptionLabel, width, height)];
    // Get the third part of the big image
    width  = (_container.bounds.size.width - kInsetVertical * 2) / 3;
    height = width * 4/3;
    [_imageSmall setFrame:CGRectMake(kInsetVertical, _container.bounds.size.height - kInsetVertical - height, width, height)];
    // Labels
    [_labelMain setFrame:[self mainLabelRect]];
    [_labelMain setFont:[UIFont fontWithName:kDefaultFontName size:isPad() ? kFontSizeMainLabel_Pad : kFontSizeMainLabel]];
    [_labelAdditionalInfo setFrame:[self descriptionLabelRect]];
    [_labelAdditionalInfo setFont:[UIFont fontWithName:kDefaultFontName size:isPad() ? kFontSizeDescription_Pad : kFontSizeDescription]];
    // Synopsis
    [_scrollViewSynopsis setFrame:[self scrollViewRect]];
    [_labelSynopsis setFrame:_scrollViewSynopsis.bounds];

    // Picture
    [self downloadImageForView:_image withTempImageName:@"image01.jpg"];
    // Thumbnail
    [self downloadImageForView:_imageSmall withTempImageName:@"thumb01.jpg"];
}

#pragma mark - Private methods

- (void)downloadImageForView:(UIImageView *)imageView withTempImageName:(NSString *)tempImageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger status = 0;
        NSData *pictureData = [[ImageDownloader sharedInstance] downloadPictureDataByImageOrigin:self.dataItem.imageOrigin andWidth:imageView.frame.size.width andHeight:imageView.frame.size.height status:&status];
        UIImage *tempImage = nil;
        // Verify data
        if (pictureData != nil) {
            tempImage = [UIImage imageWithData:pictureData];
        } else if (status) {
            tempImage = [UIImage imageNamed:tempImageName];
        }
        // Verify picture
        if (tempImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [tempImage crossFadeToImageView:imageView];
            });
        }
    });
}

+ (UIImage *)defaultImage
{
    static UIImage *_emptyImage;
    @synchronized(self)
    {
        if (_emptyImage == nil) {
            _emptyImage = [UIImage imageNamed:kStringEmptyThumbnail];
        }
    }
    return _emptyImage;
}

- (CGRect)mainLabelRect
{
    CGFloat x = kInsetVertical;
    CGFloat y = x - 4;
    CGFloat width = _container.bounds.size.width - kInsetVertical * 2;
    CGFloat height = kHeightMainLabel;
    return CGRectMake(x, y, width, height);
}

- (CGRect)descriptionLabelRect
{
    CGRect rect = [self mainLabelRect];
    CGFloat height = kHeightDescriptionLabel;
    return CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - kInsetHorizontal/2, rect.size.width, height);
}

- (CGRect)scrollViewRect
{
    CGFloat x = _imageSmall.frame.origin.x + _imageSmall.frame.size.width + kInsetVertical;
    CGFloat y = _image.frame.origin.y + _image.frame.size.height + kInsetVertical/2;
    CGFloat width = _container.bounds.size.width - x - kInsetVertical/2;
    CGFloat height = _container.bounds.size.height - y - kInsetVertical;
    return CGRectMake(x, y, width, height);
}

@end
