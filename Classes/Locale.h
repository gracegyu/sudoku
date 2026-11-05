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

/// More Games 가 여는 곳. 지금은 개발자 페이지 링크이고, A469 에서 공용 카탈로그로 바꾼다.
/// 설정의 goNewApps · 메뉴 · 완료 창이 모두 이 한 곳을 부른다.
+ (void) openMoreGames;

@end

