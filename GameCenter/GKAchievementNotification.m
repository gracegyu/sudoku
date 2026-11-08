//
//  GKAchievementNotification.m
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//  $Id$
//


#import <GameKit/GameKit.h>
#import "GKAchievementNotification.h"
#import "Locale.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "MainView.h"
#import <sys/utsname.h>



#pragma mark -

@interface GKAchievementNotification(private)

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)delegateCallback:(SEL)selector withObject:(id)object;

@end

#pragma mark -

@implementation GKAchievementNotification(private)

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didShowAchievementNotification:) withObject:self];
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:kGKAchievementDisplayTime];
}

- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didHideAchievementNotification:) withObject:self];
    [self removeFromSuperview];
}

- (void)delegateCallback:(SEL)selector withObject:(id)object
{
    if (self.handlerDelegate)
    {
        if ([self.handlerDelegate respondsToSelector:selector])
        {
            [self.handlerDelegate performSelector:selector withObject:object];
        }
    }
}

@end

#pragma mark -

@implementation GKAchievementNotification

@synthesize achievement=_achievement;
@synthesize background=_background;
@synthesize handlerDelegate=_handlerDelegate;
@synthesize detailLabel=_detailLabel;
@synthesize logo=_logo;
@synthesize message=_message;
@synthesize title=_title;
@synthesize textLabel=_textLabel;

#pragma mark -

- (id)initWithAchievementDescription:(GKAchievementDescription *)achievement
{
    CGRect frame = kGKAchievementDefaultSize;
    self.achievement = achievement;
    if (self = [self initWithFrame:frame])
    {
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message
{
    CGRect frame = kGKAchievementDefaultSize;
    self.title = title;
    self.message = message;
    if (self = [self initWithFrame:frame])
    {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // create the GK background
        UIImage *backgroundStretch = [[UIImage imageNamed:@"gk-notification.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
        UIImageView *tBackground = [[UIImageView alloc] initWithFrame:frame];
        tBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tBackground.image = backgroundStretch;
        self.background = tBackground;
        self.opaque = NO;
        [tBackground release];
        [self addSubview:self.background];
        self.userInteractionEnabled = NO;   // 띠가 떠 있는 동안에도 아래 판·버튼을 누를 수 있게

        CGRect r1 = kGKAchievementText1;
        CGRect r2 = kGKAchievementText2;

        // create the text label
        UILabel *tTextLabel = [[UILabel alloc] initWithFrame:r1];
        tTextLabel.textAlignment = NSTextAlignmentCenter;
        tTextLabel.backgroundColor = [UIColor clearColor];
        tTextLabel.textColor = [UIColor whiteColor];
        tTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        tTextLabel.text = gettext(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
        self.textLabel = tTextLabel;
        [tTextLabel release];

        // detail label
        UILabel *tDetailLabel = [[UILabel alloc] initWithFrame:r2];
        tDetailLabel.textAlignment = NSTextAlignmentCenter;
        tDetailLabel.adjustsFontSizeToFitWidth = YES;
        //tDetailLabel.minimumFontSize = 10.0f;
        [tDetailLabel setMinimumScaleFactor:10.0f];
        tDetailLabel.backgroundColor = [UIColor clearColor];
        tDetailLabel.textColor = [UIColor whiteColor];
        tDetailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        self.detailLabel = tDetailLabel;
        [tDetailLabel release];

        if (self.achievement)
        {
            self.textLabel.text = self.achievement.title;
            self.detailLabel.text = self.achievement.achievedDescription;
        }
        else
        {
            if (self.title)
            {
                self.textLabel.text = self.title;
            }
            if (self.message)
            {
                self.detailLabel.text = self.message;
            }
        }

        [self addSubview:self.textLabel];
        [self addSubview:self.detailLabel];
    }
    return self;
}

- (void)dealloc
{
   // NSLog(@"dealloc: GKAchievementNotification");
    
    self.handlerDelegate = nil;
    self.logo = nil;
    
    [_achievement release];
    [_background release];
    [_detailLabel release];
    [_logo release];
    [_message release];
    [_textLabel release];
    [_title release];
    
    [super dealloc];
}


#pragma mark -

/// 띠가 내려와 멈출 자리. 노치·Dynamic Island 기기는 안전 영역 top inset 바로 아래에 둔다
/// (전에는 45pt 고정이라 Dynamic Island 기기에서 위쪽이 가렸다). 노치 없는 기기와 가로 화면은
/// 예전과 같은 10pt 다(상태 막대 높이 20pt 는 노치로 치지 않는다).
/// safe top 은 창 좌표다. 띠를 얹는 mainView 가 창 위쪽에서 어긋나 있을 수 있으므로 부모 좌표로 바꾼다.
static CGRect GKAchievementFrameEndForScreen(UIView *host)
{
    CGRect frame = kGKAchievementFrameEnd;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        CGFloat top = mainWindow.safeAreaInsets.top;
        if (top > 24.0f) {
            CGFloat hostTop = host ? [host convertPoint:CGPointZero toView:nil].y : 0.0f;
            frame.origin.y = top - hostTop;
        }
    }
    return frame;
}

- (void)animateIn
{
    [self delegateCallback:@selector(willShowAchievementNotification:) withObject:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationInDidStop:finished:context:)];
 
    self.frame = GKAchievementFrameEndForScreen(self.superview);


    
    [UIView commitAnimations];
}

- (void)animateOut
{
    [self delegateCallback:@selector(willHideAchievementNotification:) withObject:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationOutDidStop:finished:context:)];
    self.frame = kGKAchievementFrameStart;

    [UIView commitAnimations];
}

- (void)setImage:(UIImage *)image
{
    if (image)
    {
        if (!self.logo)
        {
            UIImageView *tLogo = [[UIImageView alloc] initWithFrame:CGRectMake(7.0f, 6.0f, 34.0f, 34.0f)];
            tLogo.contentMode = UIViewContentModeCenter;
            self.logo = tLogo;
            [tLogo release];
            [self addSubview:self.logo];
        }
        self.logo.image = image;
        self.textLabel.frame = kGKAchievementText1WLogo;
        self.detailLabel.frame = kGKAchievementText2WLogo;
    }
    else
    {
        if (self.logo)
        {
            [self.logo removeFromSuperview];
        }
        self.textLabel.frame = kGKAchievementText1;
        self.detailLabel.frame = kGKAchievementText2;
    }
}



@end
