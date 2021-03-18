//
//  SudokuMap.h
//  sudoku
//
//  Created by Raymond on 9/24/12.
//
//

#import <Foundation/Foundation.h>

#ifdef SUDOKU16 
#define MAXMAPSIZE  16
#define GRIDX       4
#define GRIDY       4
#elif defined(SUDOKU12)
#define MAXMAPSIZE  12
#define GRIDX       4
#define GRIDY       3
#else
#define MAXMAPSIZE  9
#define GRIDX       3
#define GRIDY       3
#endif

#define SIZE_4      4
#define SIZE_5      5
#define SIZE_6      6
#define SIZE_7      7
#define SIZE_8      8
#define SIZE_9      9
#define SIZE_12     12
#define SIZE_16     16

typedef struct 
{
	NSInteger x;
	NSInteger y;
} sXY;

@interface SudokuMap : NSObject
{
    NSInteger   size;                   // 4,5,6,7,8,9,12,16
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
	sXY			sub[MAXMAPSIZE+1][MAXMAPSIZE];	// 1~9/12,16, 0~8, x,y
}

@property NSInteger     size;

- (id) initWithMap:(SudokuMap*)source;
- (id) initWithMapArray:(NSInteger*)arrayMap size:(NSInteger)sizeMap;
- (id) initWithSize:(NSInteger)size defmap:(BOOL)defmap;
- (void) initSXY;
- (NSInteger*) getMap;
- (sXY*) getSub;
- (sXY*) getSubNum:(NSInteger)num;
- (NSInteger) getMapNum:(NSInteger)x y:(NSInteger)y;
- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2;


@end
