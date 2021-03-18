//
//  SudokuUndo.m
//  sudokuall
//
//  Created by Raymond on 10/9/12.
//
//

#import "SudokuUndo.h"
#import "Constants.h"
#import "KillerMap.h"

@implementation UndoData

@synthesize mode;
@synthesize x;
@synthesize y;
@synthesize oldnum;
@synthesize num;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
	{
        self.mode = (UNDOMODE)[decoder decodeIntegerForKey:@"mode"];
        self.x = [decoder decodeIntegerForKey:@"x"];
        self.y = [decoder decodeIntegerForKey:@"y"];
        self.oldnum = [decoder decodeIntegerForKey:@"oldnum"];
        self.num = [decoder decodeIntegerForKey:@"num"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:mode forKey:@"mode"];
    [encoder encodeInteger:x forKey:@"x"];
    [encoder encodeInteger:y forKey:@"y"];
    [encoder encodeInteger:oldnum forKey:@"oldnum"];
    [encoder encodeInteger:num forKey:@"num"];
}

@end

@implementation SudokuUndo

@synthesize  count;
//@synthesize  bookmarkX;
//@synthesize  bookmarkY;

#define DEFMAXUNDO 1000

- (id) init {
    
	if((self = [super init])) {
		DLog(@"init");
        
        arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
		memset(arrayBookmark, -1, sizeof(arrayBookmark));
//        bookmark = -1;  // no bookmark
//        bookmarkX = -1;
//        bookmarkY = -1;
        
	}
	return self;
}

- (void)dealloc
{
    [arrayUndo removeAllObjects];
    [arrayUndo release];
	[super dealloc];
}

- (void) gotoFirst
{
    indexUndo = 0;
}

- (NSInteger) getIndex
{
	DLog(@"getIndex(count:%ld, indexUndo:%ld)", (long)count, (long)indexUndo);
    return indexUndo;
}


- (NSInteger) countUndo
{
	//DLog(@"countUndo(count:%d, indexUndo:%d)", count, indexUndo);
    return indexUndo;
}

- (NSInteger) countRedo
{
	//DLog(@"countRedo(count:%d, indexUndo:%d)", count, indexUndo);
	
    count = [arrayUndo count];
    return count - indexUndo;
}

- (void) flushUndo
{
	//DLog(@"flushUndo(count:%d, indexUndo:%d)", count, indexUndo);

    if (indexUndo < count)
    {
        for (NSInteger i = count-1; i >=indexUndo; i--)
        {
            [arrayUndo removeObjectAtIndex:i];
        }
        count = [arrayUndo count];
        DAssert(indexUndo == count, @"indexUndo(%ld) != count(%ld)", (long)indexUndo, (long)count);
    }
	// count보다 큰 위치의 bookmark는 모두 삭제한다.
	
	[self delBookmarkBiggerThan:count];
}

// pos보다 큰 위치의 bookmark는 모두 삭제한다.
- (void) delBookmarkBiggerThan:(NSInteger)pos
{
	for (int i=0; i<MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos > pos)
		{
			arrayBookmark[i].pos = -1;
			arrayBookmark[i].x = -1;
			arrayBookmark[i].y = -1;
		}
		else if (arrayBookmark[i].pos < 0)
		{
			return;	
		}
	}
}


- (void) addNum:(NSInteger)num oldnum:(NSInteger)oldnum x:(NSInteger)x y:(NSInteger)y
{
	//DLog(@"Undo:addNum(%d,%d)%d,%d", x, y, num, oldnum);
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
	//DLog(@"Undo:delNum(%d,%d)%d", x, y, num);
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
	//DLog(@"Undo:addMemo(%d,%d)%d", x, y, num);
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
	//DLog(@"Undo:delMemo(%d,%d)%d", x, y, num);
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
 	//DLog(@"Undo:addAutoMemo(%d,%d)%d", x, y, num);
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
 	//DLog(@"Undo:delAutoMemo(%d,%d)%d", x, y, num);
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
	
	//DLog(@"getUndo(count:%d, indexUndo:%d)", count, indexUndo);

    
    UndoData* undoPop = [arrayUndo objectAtIndex:indexUndo-1];
    
    if (undoPop)
    {
        undo.mode = undoPop.mode;
        undo.x = undoPop.x;
        undo.y = undoPop.y;
        undo.oldnum = undoPop.oldnum;
        undo.num = undoPop.num;
		//DLog(@"Undo:getUndo(%d,%d)%d<-%d,M:%d", undo.x, undo.y, undo.num, undo.oldnum, undo.mode);
    }
    indexUndo--;
    
   return YES;
}

- (BOOL) getRedo:(UndoData*)undo
{
    if (indexUndo >= count)
        return NO;
    
	DLog(@"getRedo(count:%ld, indexUndo:%ld)", (long)count, (long)indexUndo);
	
    UndoData* undoPop = [arrayUndo objectAtIndex:indexUndo];
    
    if (undoPop)
    {
        undo.mode = undoPop.mode;
        undo.x = undoPop.x;
        undo.y = undoPop.y;
        undo.oldnum = undoPop.oldnum;
        undo.num = undoPop.num;
		DLog(@"Undo:getRedo(%ld,%ld)%d,%ld,%ld", (long)undo.x, (long)undo.y, undo.mode, (long)undo.oldnum, (long)undo.num);
    }
    indexUndo++;
    
    return YES;
}

- (BOOL) isBookmarkedPos:(NSInteger)pos
{
	for (int i=0; i<MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos == pos)
		{
			return YES;
		}
		else if (arrayBookmark[i].pos < 0)
		{
			return NO;
		}
	}
	return NO;
}

- (BOOL) addBookmark
{    
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
			break;
		}
	}
	
	// 중복된 bookmark는 추가 할 수 없음
	if ([self isBookmarkedPos:i] == YES)
	{
		return NO;	// 이미 추가된 북마크 위치
	}
	
	Bookmark bmTemp, bm;
	
	bm.pos = i;
	bm.x = -1;
	bm.y = -1;
    if (bm.pos > 0)
    {
        UndoData* undoBookmark = [arrayUndo objectAtIndex:bm.pos-1];
        if (undoBookmark)
        {
            bm.x = undoBookmark.x;
            bm.y = undoBookmark.y;
        }
    }

    // 북마크 삽입하기
	for (int i=0; i<=MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos == -1 || bm.pos < arrayBookmark[i].pos)
		{
			memcpy(&bmTemp, &arrayBookmark[i], sizeof(Bookmark));
			memcpy(&arrayBookmark[i], &bm, sizeof(Bookmark));
			memcpy(&bm, &bmTemp, sizeof(Bookmark));
		}
	}
	
	if (arrayBookmark[MAXBOOKMARK].pos != -1)	// bookmark가 넘쳤으므로 매 앞으로 북마크를 제거해야 한다.
	{
		for (int i=0; i<MAXBOOKMARK; i++)
		{
			memcpy(&arrayBookmark[i], &arrayBookmark[i+1], sizeof(Bookmark));
		}
		// 마지막은 -1로 채운다.
		arrayBookmark[MAXBOOKMARK].pos = -1;
		arrayBookmark[MAXBOOKMARK].x = -1;
		arrayBookmark[MAXBOOKMARK].y = -1;
	}
	//[self saveData];
	for (NSInteger i=0; i<=MAXBOOKMARK; i++)
	{
		DLog(@"bookmark(%ld)P:%ld XY:%ld,%ld", (long)i, (long)arrayBookmark[i].pos, (long)arrayBookmark[i].x, (long)arrayBookmark[i].y);
	}
	
	return YES;
}

- (void) delAllBookmarks
{
	memset(arrayBookmark, -1, sizeof(arrayBookmark));
//    bookmark = -1;
//    bookmarkX = -1;
//    bookmarkY = -1;
    //DLog(@"bookmark = %d", bookmark);
}

- (void) delLastBookmark
{
	for (int i=0; i<=MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos < 0)
		{
			if (i > 0)
			{
				arrayBookmark[i-1].pos = -1;
				arrayBookmark[i-1].x = -1;
				arrayBookmark[i-1].y = -1;
			} else {
				DLog(@"Can't delete bookmark, there is no bookmark");
			}
			return;
		}
	}
	for (NSInteger i=0; i<=MAXBOOKMARK; i++)
	{
		DLog(@"bookmark(%ld)P:%ld XY:%ld,%ld", (long)i, (long)arrayBookmark[i].pos, (long)arrayBookmark[i].x, (long)arrayBookmark[i].y);
	}
}


- (NSInteger) countBookmarked
{
	for (int i=0; i<MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos < 0)
			return i;
	}
	return MAXBOOKMARK;
}

- (void) validateBookmark
{
	for (int i=0; i<MAXBOOKMARK; i++)
	{
		if (arrayBookmark[i].pos == 0)	// pos 0은 북마크를 할 수 없다.
		{
			arrayBookmark[i].pos = -1;
			arrayBookmark[i].x = -1;
			arrayBookmark[i].y = -1;
			return;
		}
		// 순서가 뒤바뀐 북마크의 뒤는 지운다.
		if (i > 0 && arrayBookmark[i].pos > 0 && arrayBookmark[i].pos < arrayBookmark[i-1].pos)
		{
			arrayBookmark[i].pos = -1;
			arrayBookmark[i].x = -1;
			arrayBookmark[i].y = -1;
			return;
		}
	}
	arrayBookmark[MAXBOOKMARK].pos = -1;
	arrayBookmark[MAXBOOKMARK].x = -1;
	arrayBookmark[MAXBOOKMARK].y = -1;
}


- (Bookmark*) getBookmark:(NSInteger)num;
{
	DAssert(num>=0 && num<MAXBOOKMARK, @"getBookmark(%ld)", (long)num);
	
	return &arrayBookmark[num];
}

- (Bookmark*) getLastBookmark
{
	NSInteger countBM = [self countBookmarked];
	if (countBM == 0)
		return NULL;
	
	return [self getBookmark:countBM-1];	
}

/*
- (NSInteger) canGoBookmark    // -1:undo, 0:can't +1:redo
{
    //DLog(@"bookmark = %d", bookmark);
    if (bookmark >= count)
        return 0;
    if (bookmark < indexUndo)
        return -1;
    if (bookmark > indexUndo)
        return +1;

    return 0;
}
*/

// 마지막 북마크로 이동하기
- (NSInteger) countGoBookmark  // 몇번 undo, redo를 해야 하나?
{
    //DLog(@"bookmark = %d", bookmark);
	Bookmark* bm = [self getLastBookmark];
	if (!bm)
	{
		// no bookmark
		return 0;
	}
    if (bm->pos < 0 || bm->pos > count)
        return 0;
    
    return (bm->pos - indexUndo);
}

- (void) clear
{
    [arrayUndo removeAllObjects];
    indexUndo = count = [arrayUndo count];
    [self delAllBookmarks];
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
				//break;
			}
			i++;
		}
		return array;
		
	}

	return nil;
}

#define kundosaved		@"kundosaved"
#define kbookmark		@"kbookmark"
#define kbookmarkX		@"kbookmarkX"
#define kbookmarkY		@"kbookmarkY"
#define kindexUndo		@"kindexUndo"
#define kcount			@"kcount"
#define karrayUndo		@"karrayUndo"
#define karrayBookmark	@"karrayBookmark"


- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	char zStrBookmark[MAXBOOKMARK*30] = "";
	
	[defaults setInteger:1 forKey:kundosaved];
	[defaults setInteger:indexUndo forKey:kindexUndo];
	[defaults setInteger:count forKey:kcount];

	// bookmark array save
	if ([self countBookmarked] > 0)
		[KillerMap getNumsPipe:zStrBookmark	size:[self countBookmarked]*sizeof(Bookmark)/sizeof(NSInteger) nums:(NSInteger*)&arrayBookmark[0]];
	NSString *str = [[NSString alloc] initWithFormat:@"%s", zStrBookmark];
	//DLog(@"bookmark(%@)", str);
	[defaults setObject:str forKey:karrayBookmark];
	
	// undo array save
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayUndo];
    if (data)   // for safe
        [defaults setObject:data forKey:karrayUndo];    // Crash
    
    [defaults synchronize];

    [str release];

}

- (id) initWithSaveData
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	memset(arrayBookmark, -1, sizeof(arrayBookmark));
	
	if ([defaults integerForKey:kundosaved] == 1)
	{
		indexUndo = [defaults integerForKey:kindexUndo];
		count = [defaults integerForKey:kcount];
		
		NSString *str = (NSString*)[defaults stringForKey:karrayBookmark];
		if (str != nil)
		{
			//DLog(@"bookmark(%@)", str);
			[KillerMap setNumsPipe:str size:MAXBOOKMARK*sizeof(Bookmark)/sizeof(NSInteger)	nums:(NSInteger*)&arrayBookmark[0]];
			[self validateBookmark];
		} else {
			// Never been saved
		}

		
		NSData *data = [defaults objectForKey:karrayUndo];
		if (data)
		{
			NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			if (array)
			{
				arrayUndo = [[NSMutableArray alloc] initWithArray:array];
				DAssert(count == [arrayUndo count], @"Undo:initWithSaveData:count(%ld)!=ArrayUndoCount(%ld)",
						(long)count, (long)[arrayUndo count]);
				[self printData];

				return self;
			}
		}
		arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
	} else {
		DLog(@"Never saved Undo data");
		arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
	}
	
	[self printData];
	
	return self;
}

- (void) printData
{
	DLog(@"UndoLog: indexUndo(%ld) count(%ld)",
		 (long)indexUndo, (long)count);
	
	for (NSInteger i=0; i<count; i++)
	{
		UndoData* undoTemp = [arrayUndo objectAtIndex:i];
    
		if (undoTemp)
		{
			//DLog(@"  %d:M%d XY%d%d O%d N%d", i, undoTemp.mode, undoTemp.x, undoTemp.y, undoTemp.oldnum, undoTemp.num);
		} else {
			DAssert(undoTemp, @"[arrayUndo objectAtIndex:%ld]==NULL;count=%ld", (long)i, (long)count);
		}
	}
	
}

@end
