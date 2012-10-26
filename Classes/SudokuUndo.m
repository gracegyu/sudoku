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

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
	{
        self.mode = [decoder decodeIntegerForKey:@"mode"];
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
@synthesize  bookmarkX;
@synthesize  bookmarkY;

#define DEFMAXUNDO 300

- (id) init {
    
	if((self = [super init])) {
		DLog(@"init");
        
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
	DLog(@"getIndex(count:%d, indexUndo:%d)", count, indexUndo);
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
        for (int i = count-1; i >=indexUndo; i--)
        {
            [arrayUndo removeObjectAtIndex:i];
        }
        count = [arrayUndo count];
        DAssert(indexUndo == count, @"indexUndo(%d) != count(%d)", indexUndo, count);
    }
    if (bookmark > 0 && bookmark > count)
    {
        bookmark = -1;
        DLog(@"delete bookmark");
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
	
	DLog(@"getUndo(count:%d, indexUndo:%d)", count, indexUndo);

    
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
    
	DLog(@"getRedo(count:%d, indexUndo:%d)", count, indexUndo);
	
    UndoData* undoPop = [arrayUndo objectAtIndex:indexUndo];
    
    if (undoPop)
    {
        undo.mode = undoPop.mode;
        undo.x = undoPop.x;
        undo.y = undoPop.y;
        undo.oldnum = undoPop.oldnum;
        undo.num = undoPop.num;
		DLog(@"Undo:getRedo(%d,%d)%d,%d,%d", undo.x, undo.x, undo.mode, undo.oldnum, undo.num);
    }
    indexUndo++;
    
    return YES;
}

- (BOOL) addBookmark
{
    bookmark = indexUndo;
    //DLog(@"bookmark = %d", bookmark);
    
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
    //DLog(@"bookmark = %d", bookmark);
}

- (BOOL) isBookmarked
{
    //DLog(@"bookmark = %d", bookmark);
    return bookmark >= 0;
}

- (NSInteger) getBookmark
{
	return bookmark;
}


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

- (NSInteger) countGoBookmark  // 몇번 undo, redo를 해야 하나?
{
    //DLog(@"bookmark = %d", bookmark);

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

#define kundosaved		@"kundosaved"
#define kbookmark		@"kbookmark"
#define kbookmarkX		@"kbookmarkX"
#define kbookmarkY		@"kbookmarkY"
#define kindexUndo		@"kindexUndo"
#define kcount			@"kcount"
#define karrayUndo		@"karrayUndo"

- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setInteger:1 forKey:kundosaved];
	[defaults setInteger:bookmark forKey:kbookmark];
	[defaults setInteger:bookmarkX forKey:kbookmarkX];
	[defaults setInteger:bookmarkY forKey:kbookmarkY];
	[defaults setInteger:indexUndo forKey:kindexUndo];
	[defaults setInteger:count forKey:kcount];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayUndo];
	[defaults setObject:data forKey:karrayUndo];
}

- (id) initWithSaveData
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults integerForKey:kundosaved] == 1)
	{
		bookmark = [defaults integerForKey:kbookmark];
		bookmarkX = [defaults integerForKey:kbookmarkX];
		bookmarkY = [defaults integerForKey:kbookmarkY];
		indexUndo = [defaults integerForKey:kindexUndo];
		count = [defaults integerForKey:kcount];
		NSData *data = [defaults objectForKey:karrayUndo];
		if (data)
		{
			NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			if (array)
			{
				arrayUndo = [[NSMutableArray alloc] initWithArray:array];
				
				return self;
			}
		}
		arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
	} else {
		DLog(@"Never saved Undo data");
		bookmark = -1;  // no bookmark
        bookmarkX = -1;
        bookmarkY = -1;
	}
	
	return self;
}


@end
