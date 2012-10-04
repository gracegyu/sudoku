//
//  Locale.m
//  sudokuiphonefree
//
//  Created by Raymond on 10/4/12.
//
//

#import "Locale.h"

@implementation Locale


#define kLocale     @"locale"

static NSBundle *bundle = nil;

+ (void) setLocale:(NSString *)strLocale
{
    NSLog(@"preferredLang: %@", strLocale);
    
    NSString* strResource;
    
    if ([strLocale compare:@"en"] == NSOrderedSame)
        strResource = @"English";
    else if ([strLocale compare:@"ko"] == NSOrderedSame)
        strResource = @"Korean";
    else if ([strLocale compare:@"ja"] == NSOrderedSame)
        strResource = @"Japanese";
    else if ([strLocale compare:@"zh_CN"] == NSOrderedSame)
        strResource = @"zh_CN";
    else if ([strLocale compare:@"zh_TW"] == NSOrderedSame)
        strResource = @"zh_TW";
    else
        return;

    
    NSString *path = [[ NSBundle mainBundle ] pathForResource:strResource ofType:@"lproj" ];
    if (path)
    {
        if (bundle)
            [bundle release];
    } else {
        return; // 번들 파일이 없음
    }
    bundle = [[NSBundle bundleWithPath:path] retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:strLocale forKey:kLocale];  // locale 저장하기

}

+ (NSString*) getText_:(NSString*)msgid comment:(NSString*)comment
{
    if (bundle)
        return [bundle localizedStringForKey:msgid value:msgid table:nil];
    else
        return NSLocalizedString(msgid, comment);
}











@end
