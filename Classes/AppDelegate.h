//
//  AppDelegate.h
//  Sudoku
//
//  Created by gracegyu on 10. 3. 15..
//  Copyright Raymond 2010. All rights reserved.
//

@class MainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
#ifdef ADMOB_FREEVERSION
    BOOL        bNoAd;              // 광고 제거 아이템 구매
    BOOL        bNoAdRestarted;     // 광고 제거된 xib으로 load됨
#endif
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;
#ifdef ADMOB_FREEVERSION
@property BOOL        bNoAd;              // 광고 제거 아이템 구매
@property BOOL        bNoAdRestarted;     // 광고 제거된 xib으로 load됨
#endif

- (BOOL) supportRotate;
+ (AppDelegate *)sharedAppDelegate;
#ifdef ADMOB_FREEVERSION
- (void) loadSetting;
- (void) saveSetting;
- (void) saveNoAdSetting;
- (BOOL) getNoAdSetting;
#endif
@end

