//
//  TeamMediaViewController.m
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 7/21/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import "TeamMediaViewController.h"
#import "Media.h"
#import <AsyncImageView/AsyncImageView.h>

@interface TeamMediaViewController ()

@end

@implementation TeamMediaViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSArray *typeOrder = @[@"cdphotothread", @"youtube"];
    NSArray *medias = [[self.team.media allObjects] sortedArrayUsingComparator:^NSComparisonResult(Media *obj1, Media *obj2) {
        NSInteger index1 = [typeOrder indexOfObject:obj1.type];
        NSInteger index2 = [typeOrder indexOfObject:obj2.type];
        if(index1 == index2) {
            return NSOrderedSame;
        } else if(index1 == NSNotFound) {
            return NSOrderedDescending;
        } else if(index2 == NSNotFound) {
            return NSOrderedAscending;
        } else if(index1 < index2) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
    
    UIScrollView *scroll = [[UIScrollView alloc] initForAutoLayout];
    [self.view addSubview:scroll];
    [scroll autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIView *previousMediaView = nil;
    for (Media *media in medias) {
        UILabel *titleLabel = [[UILabel alloc] initForAutoLayout];
        titleLabel.text = media.title;
        titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [scroll addSubview:titleLabel];
        [titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        if(previousMediaView) {
            [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousMediaView withOffset:40];
        } else {
            [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
        }
        
        if([media.type isEqualToString:@"cdphotothread"]) {
            previousMediaView = [[AsyncImageView alloc] initForAutoLayout];
            previousMediaView.contentMode = UIViewContentModeScaleAspectFit;
            
            AsyncImageView *imageView = (AsyncImageView *)previousMediaView;
            [imageView addObserver:self forKeyPath:@"image" options:0 context:NULL];
            imageView.imageURL = [NSURL URLWithString:media.url];

        } else {
            previousMediaView = [[UIWebView alloc] initForAutoLayout];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:media.url]];
            [(UIWebView *)previousMediaView loadRequest:request];
        }
        
        [scroll addSubview:previousMediaView];
        
        if([previousMediaView isKindOfClass:[UIWebView class]])
        {
            [previousMediaView autoConstrainAttribute:ALDimensionWidth
                                          toAttribute:ALDimensionHeight
                                               ofView:previousMediaView
                                       withMultiplier:(1280.0/720.0)]; // Just a ballbark figure
        }
        [previousMediaView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [previousMediaView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:8];
        [previousMediaView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:8];
    }
    
    [previousMediaView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([object isKindOfClass:[AsyncImageView class]] && [keyPath isEqualToString:@"image"]) {
        AsyncImageView *imageView = object;
        CGFloat aspectRatio = imageView.image.size.width / imageView.image.size.height;
        [imageView autoConstrainAttribute:ALDimensionWidth
                              toAttribute:ALDimensionHeight
                                   ofView:imageView
                           withMultiplier:aspectRatio];
        [imageView removeObserver:self forKeyPath:@"image" context:NULL];
    }
}



@end