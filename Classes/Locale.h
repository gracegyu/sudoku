//
//  Locale.h
//  sudokuiphonefree
//
//  Created by Raymond on 10/4/12.
//
//

#import <Foundation/Foundation.h>

#define gettext(msgid, cmt)         [Locale getText_:msgid comment:cmt]
#define gettexttable(msgid, tbl)    [Locale getTextTable_:msgid table:tbl]


@interface Locale : NSObject

+ (void) setLocale:(NSString *)strLocale;
+ (NSString *) getFullLocale:(NSString *)strLocale;
+ (NSString*) getText_:(NSString*)msgid comment:(NSString*)comment;
+ (NSString*) getTextTable_:(NSString*)msgid table:(NSString*)table;

/// More Games 화면(MoreGamesViewController, 공장 More games 와 같은 꼴)을 띄운다.
/// 설정의 goNewApps · 메뉴 · 완료 창이 모두 이 한 곳을 부른다.
+ (void) openMoreGames;

@end

