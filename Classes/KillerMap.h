//
//  KillerMap.h
//  sudokuall
//
//  Created by Raymond on 10/23/12.
//
//

#import <Foundation/Foundation.h>
#import "SudokuMap.h"


typedef struct KillerCage
{
	NSInteger x0;	// 합계를 표시할 위치
	NSInteger y0;
	NSInteger sum;
} KillerCage;


@interface KillerMap : NSObject

{
    NSInteger   size;							// 6,9
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
    NSInteger	color[MAXMAPSIZE][MAXMAPSIZE];	// 0~6
	KillerCage	cage[MAXMAPSIZE*MAXMAPSIZE/2];
	
	BOOL		tempColor[7];
}

@property NSInteger     size;

- (id) initWithMap:(KillerMap*)source;
- (id) initWithSize:(NSInteger)sizeMap;
- (NSInteger) getCageNumber:(NSInteger)x yPos:(NSInteger)y;	// from map
- (NSInteger) getColor:(NSInteger)x yPos:(NSInteger)y;		// from color
- (NSInteger) getCageCount;
- (NSInteger*) getMapArray;
- (NSInteger*) getColorArray;
- (KillerCage*) getCageArray;				
- (KillerCage*) getCageData:(NSInteger)num;				// from cell
- (void) saveData;
- (id) initWithSaveData;

@end
