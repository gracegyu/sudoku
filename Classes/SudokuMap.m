//
//  SudokuMap.m
//  sudoku
//
//  Created by Raymond on 9/24/12.
//
//

#import "SudokuMap.h"
#import "Constants.h"

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
static int setMap7[][16*16] = {
	{   1,1,2,2,2,2,3,1,1,1,2,2,2,3,4,1,1,5,5,3,3,4,4,5,5,5,3,3,4,4,5,5,6,6,3,4,7,7,7,6,6,6,4,7,7,7,7,6,6 },
	{   1,1,1,3,3,3,3,1,1,5,6,3,3,3,1,1,5,6,6,6,6,5,5,5,7,7,6,6,5,5,7,7,7,2,2,4,4,4,7,7,2,2,4,4,4,4,2,2,2 },
	{   1,1,1,4,4,4,5,1,1,1,4,4,5,5,2,1,4,4,5,5,5,2,2,2,2,7,5,6,3,2,2,7,7,6,6,3,3,7,7,7,6,6,3,3,3,3,7,6,6 },
	{   1,1,2,2,2,2,3,1,1,1,2,2,3,3,4,1,5,2,5,3,3,4,1,5,5,5,5,3,4,4,4,5,7,7,3,4,4,6,6,7,7,7,6,6,6,6,6,7,7 },
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
    {10},
    {11},
    {   1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
        1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
        1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
        4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6,
        4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6,
        4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6,
        7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
        7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
        7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9,
        10,10,10,10,11,11,11,11,12,12,12,12,
        10,10,10,10,11,11,11,11,12,12,12,12,
        10,10,10,10,11,11,11,11,12,12,12,12
    },  // 12
    {13},
    {14},
    {15},
    {   1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
        1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
        1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
        1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,
        5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8,
        5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8,
        5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8,
        5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8,
        9, 9, 9, 9, 10,10,10,10,11,11,11,11,12,12,12,12,
        9, 9, 9, 9, 10,10,10,10,11,11,11,11,12,12,12,12,
        9, 9, 9, 9, 10,10,10,10,11,11,11,11,12,12,12,12,
        9, 9, 9, 9, 10,10,10,10,11,11,11,11,12,12,12,12,
        13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,
        13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,
        13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,
        13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,
    },  // 16
    {17}
};


- (id) initWithMap:(SudokuMap*)source
{
	if ((self = [super init]) == nil)
		return nil;
	
	size = source.size;
	memcpy(map, [source getMap], sizeof(map));
	memcpy(sub, [source getSub], sizeof(sub));

	return self;
}

- (id) initWithMapArray:(NSInteger*)arrayMap size:(NSInteger)sizeMap
{
	if ((self = [super init]) == nil)
		return nil;

	size = sizeMap;
	memcpy(map, arrayMap, sizeof(map));
	[self initSXY];
	
	return self;
}


- (id) initWithSize:(NSInteger)sizeMap defmap:(BOOL)defmap
{
	if ((self = [super init]) == nil)
		return nil;
	
    DAssert((sizeMap <= SIZE_9 && sizeMap >= SIZE_4) || (sizeMap == SIZE_12 || sizeMap == SIZE_16), @"sizeMap=%d", sizeMap);
    
    if (sizeMap > MAXMAPSIZE)
        return nil;

    size = sizeMap;
	
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
                NSInteger numRandom = countDefMap > 0 ? (valRand % (countDefMap)) : 0;
                DLog(@"numRandom = %ld", (long)numRandom);
                
                Map = setMap6[numRandom];
            }
            break;
        case SIZE_7 :
			{
				NSInteger countDefMap = 0;
				for (int i=0; setMap7[i][0]>0; i++)
					countDefMap++;
				
				unsigned int valRand = arc4random();
				NSInteger numRandom = countDefMap > 0 ? (valRand % (countDefMap)) : 0;
				DLog(@"numRandom = %ld", (long)numRandom);
				
				Map = setMap7[numRandom];
			}
            break;

        default :
            Map = defaultMap[sizeMap];
            break;
    }

	for (y = 0; y < size; y++) {
        for (x = 0; x < size; x++) {
			
            map[x][y] = Map[i];
			i++;
		}
	}
	
	[self initSXY];
	
    return self;
}

- (void) initSXY
{
	NSInteger countMap[MAXMAPSIZE+10] = {0};
    memset(&countMap, 0, sizeof(countMap));

	NSInteger countSub[MAXMAPSIZE+1];
	memset(countSub, 0, sizeof(countSub));
	
	for (int y = 0; y < size; y++) {
		for (int x = 0; x < size; x++) {
			
			DAssert(map[x][y] <= size, @"map[%d,%d](%d) > %d", x, y, map[x][y], size);
			DAssert(++countMap[map[x][y]] <= size, @"countMap[%d] > %d", map[x][y], size);
			//DLog(@"%d,%d - Map[%d]=%d", x, y, i, Map[i]);
			
			sub[map[x][y]][countSub[map[x][y]]].x = x;
			sub[map[x][y]][countSub[map[x][y]]].y = y;
			//DLog(@"sub[%d][%d](%d,%d)", map[x][y],countSub[map[x][y]], x, y);
			countSub[map[x][y]] += 1;
			

		}
	}
}

- (NSInteger*) getMap
{
    return (NSInteger*) map;
}
- (sXY*) getSub
{
	return (sXY*) sub;
}

- (sXY*) getSubNum:(NSInteger)num
{
	return (sXY*) (sub[num]);
}

- (NSInteger) getMapNum:(NSInteger)x y:(NSInteger)y
{
    DAssert(x < MAXMAPSIZE && y < MAXMAPSIZE, @"getMapNum(%d,%d/Max = %d)", x, y, MAXMAPSIZE);

    return map[x][y];
}

- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2
{
    return map[x][y] == map[x2][y2];
}

@end
