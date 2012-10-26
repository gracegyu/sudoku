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


@interface SudokuUndo : NSObject
{
    NSInteger       bookmark;
    NSInteger       bookmarkX;
    NSInteger       bookmarkY;
    NSInteger       indexUndo;
    NSInteger       count;
	NSMutableArray	*arrayUndo;
}

@property NSInteger       count;
@property NSInteger       bookmarkX;
@property NSInteger       bookmarkY;


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
- (void) delBookmark;   
- (BOOL) isBookmarked;
- (NSInteger) getBookmark;
- (NSInteger) canGoBookmark;    // -1:undo, 0:can't +1:redo
- (NSInteger) countGoBookmark;  // 몇번 undo, redo를 해야 하나?

- (NSMutableArray*) getAutoUndo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y;
- (void) saveData;
- (id) initWithSaveData;
- (void) printData;

@end
