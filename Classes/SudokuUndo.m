//
//  SudokuUndo.m
//  sudokuall
//
//  Created by Raymond on 10/9/12.
//
//

#import "SudokuUndo.h"
#import "Constants.h"

@implementation UndoData

@synthesize mode;
@synthesize x;
@synthesize y;
@synthesize oldnum;
@synthesize num;

@end

@implementation SudokuUndo

@synthesize  count;
@synthesize  bookmarkX;
@synthesize  bookmarkY;

#define DEFMAXUNDO 300

- (id) init {
    
	if((self = [super init])) {
		NSLog(@"init");
        
        arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
        bookmark = -1;  // no bookmark
        bookmarkX = -1;
        bookmarkY = -1;
        
	}
	return self;
}

- (void)dealloc
{
    [arrayUndo removeAllObjects];
    [arrayUndo release];
	[super dealloc];
}

- (NSInteger) getIndex
{
    return indexUndo;
}


- (NSInteger) countUndo
{
    return indexUndo;
}

- (NSInteger) countRedo
{
    count = [arrayUndo count];
    return count - indexUndo;
}

- (void) flushUndo
{
    if (indexUndo < count)
    {
        for (int i = count-1; i >=indexUndo; i--)
        {
            [arrayUndo removeObjectAtIndex:i];
        }
        count = [arrayUndo count];
        NSAssert(indexUndo == count, @"indexUndo(%d) != count(%d)", indexUndo, count);
    }
    if (bookmark > 0 && bookmark > count)
    {
        bookmark = -1;
        NSLog(@"delete bookmark");
    }
}

- (void) addNum:(NSInteger)num oldnum:(NSInteger)oldnum x:(NSInteger)x y:(NSInteger)y
{
	NSLog(@"Undo:addNum(%d,%d)%d,%d", x, y, num, oldnum);
    [self flushUndo];
    
    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_NUM_ADD;
    undo.x = x;
    undo.y = y;
    undo.oldnum = oldnum;
    undo.num = num;
    
    [arrayUndo addObject:undo];

    [undo release];
    indexUndo = count = [arrayUndo count];
    
}

- (void) delNum:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	NSLog(@"Undo:delNum(%d,%d)%d", x, y, num);
    [self flushUndo];

    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_NUM_DEL;
    undo.x = x;
    undo.y = y;
    undo.oldnum = num;
    undo.num = num;
    
    [arrayUndo addObject:undo];
    
    [undo release];
    indexUndo = count = [arrayUndo count];
}

- (void) addMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	NSLog(@"Undo:addMemo(%d,%d)%d", x, y, num);
    [self flushUndo];

    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_MEMO_ADD;
    undo.x = x;
    undo.y = y;
    undo.num = num;
    
    [arrayUndo addObject:undo];
    
    [undo release];
    indexUndo = count = [arrayUndo count];
}

- (void) delMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	NSLog(@"Undo:delMemo(%d,%d)%d", x, y, num);
    [self flushUndo];

    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_MEMO_DEL;
    undo.x = x;
    undo.y = y;
    undo.num = num;
    
    [arrayUndo addObject:undo];
    
    [undo release];
    indexUndo = count = [arrayUndo count];

}
- (void) addAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
 	NSLog(@"Undo:addAutoMemo(%d,%d)%d", x, y, num);
   [self flushUndo];
	
    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_AUTOMEMO_ADD;
    undo.x = x;
    undo.y = y;
    undo.num = num;
    
    [arrayUndo addObject:undo];
    
    [undo release];
    indexUndo = count = [arrayUndo count];
}

- (void) delAutoMemo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
 	NSLog(@"Undo:delAutoMemo(%d,%d)%d", x, y, num);
    [self flushUndo];
	
    UndoData *undo = [[UndoData alloc] init];
    
    undo.mode = UNDOMODE_AUTOMEMO_DEL;
    undo.x = x;
    undo.y = y;
    undo.num = num;
    
    [arrayUndo addObject:undo];
    
    [undo release];
    indexUndo = count = [arrayUndo count];
	
}

- (BOOL) getUndo:(UndoData*)undo
{
    if (indexUndo < 1)
        return NO;
    
    UndoData* undoPop = [arrayUndo objectAtIndex:indexUndo-1];
    
    if (undoPop)
    {
        undo.mode = undoPop.mode;
        undo.x = undoPop.x;
        undo.y = undoPop.y;
        undo.oldnum = undoPop.oldnum;
        undo.num = undoPop.num;
		NSLog(@"Undo:getUndo(%d,%d)%d<-%d,M:%d", undo.x, undo.y, undo.num, undo.oldnum, undo.mode);
    }
    indexUndo--;
    
   return YES;
}

- (BOOL) getRedo:(UndoData*)undo
{
    if (indexUndo >= count)
        return NO;
    
    UndoData* undoPop = [arrayUndo objectAtIndex:indexUndo];
    
    if (undoPop)
    {
        undo.mode = undoPop.mode;
        undo.x = undoPop.x;
        undo.y = undoPop.y;
        undo.oldnum = undoPop.oldnum;
        undo.num = undoPop.num;
		NSLog(@"Undo:getRedo(%d,%d)%d,%d,%d", undo.x, undo.x, undo.mode, undo.oldnum, undo.num);
    }
    indexUndo++;
    
    return YES;
}

- (BOOL) addBookmark
{
    bookmark = indexUndo;
    //NSLog(@"bookmark = %d", bookmark);
    
	// autoMemo skip
	UndoData* data;
	
	NSInteger i = indexUndo;
	while (i>0)
	{
		data = [arrayUndo objectAtIndex:i-1];
		if (data.mode == UNDOMODE_AUTOMEMO_ADD || data.mode == UNDOMODE_AUTOMEMO_DEL)
		{
			i--;
		} else {
			bookmark = i;
			break;
		}
	}
	bookmark = i;
	
	
    if (bookmark > 0)
    {
        UndoData* undoBookmark = [arrayUndo objectAtIndex:bookmark-1];
        if (undoBookmark)
        {
            bookmarkX = undoBookmark.x;
            bookmarkY = undoBookmark.y;

            return YES;
        }
    }
    bookmarkX = -1;
    bookmarkY = -1;
    return YES;
}

- (void) delBookmark
{
    bookmark = -1;
    bookmarkX = -1;
    bookmarkY = -1;
    //NSLog(@"bookmark = %d", bookmark);
}

- (BOOL) isBookmarked
{
    //NSLog(@"bookmark = %d", bookmark);
    return bookmark >= 0;
}

- (NSInteger) getBookmark
{
	return bookmark;
}


- (NSInteger) canGoBookmark    // -1:undo, 0:can't +1:redo
{
    //NSLog(@"bookmark = %d", bookmark);
    if (bookmark >= count)
        return 0;
    if (bookmark < indexUndo)
        return -1;
    if (bookmark > indexUndo)
        return +1;

    return 0;
}

- (NSInteger) countGoBookmark  // 몇번 undo, redo를 해야 하나?
{
    //NSLog(@"bookmark = %d", bookmark);

    if (bookmark < 0 || bookmark > count)
        return 0;
    
    return (bookmark - indexUndo);
}

- (void) clear
{
    [arrayUndo removeAllObjects];
    indexUndo = count = [arrayUndo count];
}

- (NSMutableArray*) getAutoUndo:(NSInteger)num x:(NSInteger)x y:(NSInteger)y
{
	NSInteger i;
	UndoData *data;
	
	i = indexUndo;
	
	while (i>0)
	{
		data = [arrayUndo objectAtIndex:i-1];
		if (data.mode == UNDOMODE_NUM_ADD &&
			data.num == num &&
			data.x == x &&
			data.y == y)
		{
			// found
			break;
		}
		i--;
	}
	
	if (i>0)
	{
		NSMutableArray* array = [[NSMutableArray alloc] init];
		while (i < indexUndo)
		{
			data = [arrayUndo objectAtIndex:i];	// 첫번째는 무시
			if (data.mode == UNDOMODE_AUTOMEMO_DEL)
			{
				[array addObject:data];
			} else {
				break;
			}
			i++;
		}
		return array;
		
	}

	return nil;
}


@end
