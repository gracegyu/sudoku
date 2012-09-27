//
//  SudokuMap.m
//  sudoku
//
//  Created by Raymond on 9/24/12.
//
//

#import "SudokuMap.h"

@implementation SudokuMap

@synthesize size;

- (void)dealloc {
	[super dealloc];
}

 static int Map9x9__[9*9] = {
    1, 1, 2, 2, 2, 3, 3, 3, 3,
    1, 1, 1, 1, 2, 2, 2, 3, 3,
    1, 4, 1, 2, 2, 2, 3, 3, 6,
    1, 4, 4, 5, 5, 5, 6, 3, 6,
    4, 4, 4, 5, 5, 5, 6, 6, 6,
    4, 7, 4, 5, 5, 5, 6, 6, 9,
    4, 7, 7, 8, 8, 8, 9, 6, 9,
    7, 7, 8, 8, 8, 9, 9, 9, 9,
    7, 7, 7, 7, 8, 8, 8, 9, 9
};

static int defaultMap[][16*16] = {
    {0},
    {1},
    {2},
    {3},
    {   1, 1, 2, 2,
        1, 1, 2, 2,
        3, 3, 4, 4,
        3, 3, 4, 4
    },  // 4
    {   1, 1, 1, 2, 2,
        1, 1, 3, 2, 2,
        4, 3, 3, 3, 2,
        4, 4, 3, 5, 5,
        4, 4, 5, 5, 5
    },  // 5
    {   1, 1, 1, 2, 2, 2,
        1, 1, 1, 2, 2, 2,
        3, 3, 3, 4, 4, 4,
        3, 3, 3, 4, 4, 4,
        5, 5, 5, 6, 6, 6,
        5, 5, 5, 6, 6, 6
    },  // 6
    {   1, 1, 2, 2, 2, 2, 3,
        1, 1, 1, 2, 2, 2, 3,
        4, 1, 1, 5, 5, 3, 3,
        4, 4, 5, 5, 5, 3, 3,
        4, 4, 5, 5, 6, 6, 3,
        4, 7, 7, 7, 6, 6, 6,
        4, 7, 7, 7, 7, 6, 6
    },  // 7
    {   1, 1, 1, 2, 2, 3, 3, 3,
        1, 1, 2, 2, 2, 2, 3, 3,
        1, 1, 1, 2, 2, 3, 3, 3,
        4, 4, 4, 4, 5, 5, 5, 5,
        4, 4, 4, 4, 5, 5, 5, 5,
        6, 6, 6, 7, 7, 8, 8, 8,
        6, 6, 7, 7, 7, 7, 8, 8,
        6, 6, 6, 7, 7, 8, 8, 8
    },  // 8
    {   1, 1, 1, 2, 2, 2, 3, 3, 3,
        1, 1, 1, 2, 2, 2, 3, 3, 3,
        1, 1, 1, 2, 2, 2, 3, 3, 3,
        4, 4, 4, 5, 5, 5, 6, 6, 6,
        4, 4, 4, 5, 5, 5, 6, 6, 6,
        4, 4, 4, 5, 5, 5, 6, 6, 6,
        7, 7, 7, 8, 8, 8, 9, 9, 9,
        7, 7, 7, 8, 8, 8, 9, 9, 9,
        7, 7, 7, 8, 8, 8, 9, 9, 9
    },  // 9
    {10}
};



- (SudokuMap*) initWithSize:(NSInteger)sizeMap
{
    NSAssert(sizeMap <= SIZE_9 && sizeMap >= SIZE_4, @"sizeMap=%d", sizeMap);
    NSInteger countMap[MAXMAPSIZE+10] = {0};
    
    if (sizeMap > MAXMAPSIZE)
        return nil;

    memset(&countMap, 0, sizeof(countMap));
    
    int x, y, i=0;
    int *Map =  defaultMap[sizeMap];
    
    for (y = 0; y < sizeMap; y++) {
        for (x = 0; x < sizeMap; x++) {

            map[x][y] = Map[i];
            NSAssert(Map[i] <= sizeMap, @"Map[%d](%d) > %d", i, Map[i], sizeMap);
            NSAssert(++countMap[Map[i]] <= sizeMap, @"countMap[%d] > %d", Map[i], sizeMap);
            NSLog(@"%d,%d - Map[%d]=%d", x, y, i, Map[i]);
            
            i++;
        }
    }
    return self;
}


- (NSInteger*) getMap
{
    return (NSInteger*) map;
}

- (NSInteger) getMapNum:(NSInteger)x y:(NSInteger)y
{
    NSAssert(x < MAXMAPSIZE && y < MAXMAPSIZE, @"getMapNum(%d,%d/Max = %d)", x, y, MAXMAPSIZE);

    return map[x][y];
}

- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
    return map[x][y] == map[x2][y2];
}

@end
