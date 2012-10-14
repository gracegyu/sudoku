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

static int setMap6[][16*16] = {
    {   1,1,1,2,2,2,1,1,1,2,2,2,3,3,3,4,4,4,3,3,3,4,4,4,5,5,5,6,6,6,5,5,5,6,6,6 },
    {   1,1,1,2,2,2,1,1,2,2,2,4,3,1,3,4,4,4,3,3,3,4,6,4,3,5,5,5,6,6,5,5,5,6,6,6 },
    {   1,1,1,2,2,2,1,1,3,3,2,2,1,3,3,3,3,2,5,4,4,4,4,6,5,5,4,4,6,6,5,5,5,6,6,6 },
    {   1,1,1,1,1,2,4,5,5,1,5,2,4,4,5,5,5,2,4,6,6,6,2,2,4,6,3,6,6,2,4,3,3,3,3,3 },
    {   1,2,2,2,2,3,1,1,1,2,3,3,5,6,1,2,4,3,5,6,1,6,4,3,5,6,6,6,4,3,5,5,5,4,4,4 },
    {   0   }
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
    {  1,2,2,2,2,3	,
        1,1,1,2,3,3	,
        5,6,1,2,4,3	,
        5,6,1,6,4,3	,
        5,6,6,6,4,3	,
        5,5,5,4,4,4	
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



- (SudokuMap*) initWithSize:(NSInteger)sizeMap defmap:(BOOL)defmap
{
    NSAssert(sizeMap <= SIZE_9 && sizeMap >= SIZE_4, @"sizeMap=%d", sizeMap);
    NSInteger countMap[MAXMAPSIZE+10] = {0};
    
    if (sizeMap > MAXMAPSIZE)
        return nil;

    memset(&countMap, 0, sizeof(countMap));
    
    int x, y, i=0;
    int *Map = nil;
    
    switch (sizeMap) {
        case SIZE_6 :
            if (defmap == YES)
            {
                Map = setMap6[0];
            } else {
                NSInteger countDefMap = 0;
                for (int i=0; setMap6[i][0]>0; i++)
                    countDefMap++;               
                
                
                unsigned int valRand = arc4random();
                NSInteger numRandom = valRand % (countDefMap-1);
                NSLog(@"numRandom = %d", numRandom);
                
                Map = setMap6[numRandom+1];
            }
            break;

        default :
            Map = defaultMap[sizeMap];
            break;
    }
    
    
    
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
    NSAssert3(x < MAXMAPSIZE && y < MAXMAPSIZE, @"getMapNum(%d,%d/Max = %d)", x, y, MAXMAPSIZE);

    return map[x][y];
}

- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
    return map[x][y] == map[x2][y2];
}

@end
