//
//  SudokuUndo.h
//  sudokuall
//
//  Created by Raymond on 10/9/12.
//
//

#import <Foundation/Foundation.h>

enum UNDOMODE {
    UNDOMODE_NUM_ADD = 0,   // 숫자 입력
    UNDOMODE_NUM_DEL,       // 숫자 삭제
    UNDOMODE_MEMO_ADD,      // 메모 입력
    UNDOMODE_MEMO_DEL,      // 메모 삭제
    UNDOMODE_AUTOMEMO_ADD,  // Auto메모 입력	(복구시만 사용)
    UNDOMODE_AUTOMEMO_DEL   // Auto메모 삭제
};

@interface UndoData : NSObject <NSCoding>
{
    enum UNDOMODE mode;
    NSInteger x;
    NSInteger y;
    NSInteger oldnum;       // 숫자 입력에만 쓰임
    NSInteger num;          // 4가지 모드에서 모두 쓰임
}

@property enum UNDOMODE mode;
@property NSInteger x;
@property NSInteger y;
@property NSInteger oldnum;
@property NSInteger num;

@end


typedef struct Bookmark
{
	NSInteger pos;	// undo array 상의 북마크 위치
	NSInteger x;	// 북마크 지정 셀의 X
	NSInteger y;	// 북마크 지정 셀의 Y
} Bookmark;

#define MAXBOOKMARK	5

@interface SudokuUndo : NSObject
{

    NSInteger       indexUndo;
    NSInteger       count;
	NSMutableArray	*arrayUndo;
	Bookmark		arrayBookmark[MAXBOOKMARK+1];	// +1은 삽입을 위해서 
}

@property NSInteger       count;

- (void) gotoFirst;
- (NSInteger) getIndex;
- (NSInteger) countUndo;    // undo 가능 수
- (NSInteger) countRedo;    // redo 가능 수
- (void) addNum:(NSInteger)num oldnum:(NSInteger)oldnum x:(NSInteger)x y:(NSInteger)y;
- (void) delNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) addMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) delMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) addAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) delAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (BOOL) getUndo:(UndoData*)undo;
- (BOOL) getRedo:(UndoData*)undo;
- (void) clear;

- (BOOL) addBookmark;   // include modify
- (void) delAllBookmarks;
- (void) delLastBookmark;
- (NSInteger) countBookmarked;
- (Bookmark*) getBookmark:(NSInteger)num;
- (Bookmark*) getLastBookmark;
//- (NSInteger) canGoBookmark;    // -1:undo, 0:can't +1:redo
- (NSInteger) countGoBookmark;  // 몇번 undo, redo를 해야 하나?
- (void) validateBookmark;

- (NSMutableArray*) getAutoUndo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) saveData;
- (id) initWithSaveData;
- (void) printData;

@end
