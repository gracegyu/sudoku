//
//  KillerMap.h
//  sudokuall
//
//  Created by Raymond on 10/23/12.
//
//

#import <Foundation/Foundation.h>
#import "SudokuMap.h"


typedef struct KillerCell
{
	NSInteger x0;	// 합계를 표시할 위치
	NSInteger y0;
	NSInteger sum;
} KillerCell;


@interface KillerMap : NSObject

{
    NSInteger   size;							// 6,9
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
    NSInteger	color[MAXMAPSIZE][MAXMAPSIZE];	// 0~7
	KillerCell	cell[MAXMAPSIZE*MAXMAPSIZE/2];
	
	BOOL		tempColor[7];
}

@property NSInteger     size;

- (id) initWithSize:(NSInteger)sizeMap;
- (NSInteger) getCellNum:(NSInteger)x yPos:(NSInteger)y;	// from map
- (NSInteger) getColor:(NSInteger)x yPos:(NSInteger)y;		// from color
- (NSInteger) getCellCount;
- (KillerCell*) getCellData:(NSInteger)num;				// from cell
- (void) saveData;
- (id) initWithSaveData;

@end
