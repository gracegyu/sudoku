//
//  SudokuUndo.m
//  sudokuall
//
//  Created by Raymond on 10/9/12.
//
//

#import "SudokuUndo.h"

@implementation UndoData

@synthesize mode;
@synthesize x;
@synthesize y;
@synthesize oldnum;
@synthesize num;

@end

@implementation SudokuUndo

@synthesize  count;

#define DEFMAXUNDO 300

- (id) init {
    
	if((self = [super init])) {
		NSLog(@"init");
        
        arrayUndo = [[NSMutableArray alloc] initWithCapacity:DEFMAXUNDO];
        
	}
	return self;
}

- (void)dealloc
{
    [arrayUndo removeAllObjects];
    [arrayUndo release];
	[super dealloc];
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
}

- (void) addNum:(NSInteger)num oldnum:(NSInteger)oldnum x:(NSInteger)x y:(NSInteger)y
{
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
    }
    indexUndo++;
    
    return YES;
}


- (void) clear
{
    [arrayUndo removeAllObjects];
    indexUndo = count = [arrayUndo count];
}

@end
