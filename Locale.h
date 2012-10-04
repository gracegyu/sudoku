//
//  Locale.h
//  sudokuiphonefree
//
//  Created by Raymond on 10/4/12.
//
//

#import <Foundation/Foundation.h>

#define gettext(msgid, cmt) [Locale getText_:msgid comment:cmt]

@interface Locale : NSObject

+ (void) setLocale:(NSString *)strLocale;
+ (NSString*) getText_:(NSString*)msgid comment:(NSString*)comment;

@end
