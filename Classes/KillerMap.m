//
//  KillerMap.m
//  sudokuall
//
//  Created by Raymond on 10/23/12.
//
//

#import "KillerMap.h"
#import "LogItem.h"
#import "Constants.h"


@implementation KillerMap

@synthesize size;

- (void)dealloc {
	[super dealloc];
}



- (id) initWithSize:(NSInteger)sizeMap
{
	if ((super.init) == nil)
		return nil;
	
    NSAssert(sizeMap <= SIZE_9 && sizeMap >= SIZE_6, @"sizeMap=%d", sizeMap);
    
	size = sizeMap;
    if (size > MAXMAPSIZE)
        return nil;
	
	memset(map, -1, sizeof(map));
	memset(color, -1, sizeof(color));
	memset(cell, -1, sizeof(cell));
	NSInteger num=0;
	
	while ([self FillRandomMap:num] == YES)
	{
		num++;
	}
	cell[num].x0 = -1;
	cell[num].y0 = -1;
	[self printMap];
	
	return self;
}


- (void) printMap
{
	for (int y=0; y<size; y++)
	{
		if (y%3 == 0)
			LogIt(@"----------------------------  -------------------\n");
		for (int x=0; x<size; x++)
		{
			if (x%3==0)
				LogIt(@"|");
			else
				LogIt(@" ");

			if (map[x][y] < 0)
				LogIt(@" .");
			else
				LogIt(@"%.2d", map[x][y]);
		}
		LogIt(@"|  ");
		
		for (int x=0; x<size; x++)
		{
			if (x%3==0)
				LogIt(@"|");
			else
				LogIt(@" ");
			
			if (color[x][y] < 0)
				LogIt(@".");
			else
				LogIt(@"%d", color[x][y]);
		}
		LogIt(@"|");

		LogIt(@"\n");
	}
	LogIt(@"---------------------------  -------------------\n");
}

- (NSInteger) GetRandomBlockSize
{
	NSInteger Rand = ((unsigned int)arc4random()) % 100;
	
	if (Rand < 50)
		return 2;
	if (Rand < 80)
		return 3;
	return 4;
}

- (BOOL) FillRandomMap:(NSInteger) num
{
	NSInteger xPos = -1, yPos = -1;
	int i;
	
	for (i = 0; i < size*size; i++)
	{
		if (map[i%size][i/size] == -1)	// 첫번쨰 빈칸 발견
		{
			xPos = i%size;	
			yPos = i/size;
			break;
		}
	}
	if (i == size*size)
		return NO;	// finished
	
	
	NSInteger sizeBlock = [self GetRandomBlockSize];	// 2~4
	memset(tempColor, 0, sizeof(tempColor));
	
	cell[num].x0 = xPos;
	cell[num].y0 = yPos;
	
	//DLog(@"sizeBlock=%d", sizeBlock);
	
	for (i = 0; i<sizeBlock; i++)
	{
		map[xPos][yPos] = num;
		//DLog(@"Set(%d,%d)->%d", xPos, yPos, num);
		[self FindNeighborColor:xPos yPos:yPos];
		
		if (![self findNeighborPosition:&xPos pY:&yPos])
		{
			break; // 갖힌 셀
		}
	}
	
	[self SetCellColor:num];
	
	
	return YES;
}

- (void) FindNeighborColor:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if (xPos - 1 >= 0 && color[xPos-1][yPos] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos-1, yPos, color[xPos-1][yPos]);
		tempColor[color[xPos-1][yPos]] = YES;
	}
	if (xPos + 1 < size && color[xPos+1][yPos] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos+1, yPos, color[xPos+1][yPos]);
		tempColor[color[xPos+1][yPos]] = YES;
	}
	if (yPos - 1 >= 0 && color[xPos][yPos-1] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos, yPos-1, color[xPos][yPos-1]);
		tempColor[color[xPos][yPos-1]] = YES;
	}
	if (yPos + 1 < size && color[xPos][yPos+1] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos, yPos+1, color[xPos][yPos+1]);
		tempColor[color[xPos][yPos+1]] = YES;
	}	
}


- (BOOL) findNeighborPosition:(NSInteger*)pX pY:(NSInteger*)pY
{
	NSInteger countNum = 0;
	sXY	xy[4];
	
	if (*pX - 1 >= 0 && map[*pX-1][*pY] == -1)
	{
		xy[countNum].x = *pX-1;
		xy[countNum].y = *pY;
		countNum++;
	}
	if (*pX + 1 < size && map[*pX+1][*pY] == -1)
	{
		xy[countNum].x = *pX+1;
		xy[countNum].y = *pY;
		countNum++;
	}
	if (*pY - 1 >= 0 && map[*pX][*pY-1] == -1)
	{
		xy[countNum].x = *pX;
		xy[countNum].y = *pY-1;
		countNum++;
	}
	if (*pY + 1 < size && map[*pX][*pY+1] == -1)
	{
		xy[countNum].x = *pX;
		xy[countNum].y = *pY+1;
		countNum++;
	}
	
	if (countNum == 0)
	{
		//DLog(@"countNum == 0");
		return NO; // 막힌 셀
	}
	NSInteger numRand = (((unsigned int)arc4random()) % countNum);
	
	*pX = xy[numRand].x;
	*pY = xy[numRand].y;

	return YES;	
}

- (void) SetCellColor:(NSInteger)num
{
	NSInteger countNeighborColor=0;
	NSInteger countAvailColor=0;
	NSInteger nowColor=-1;
	
	for (int i=0; i<sizeof(tempColor); i++)
	{
		if (tempColor[i] == YES)
		{
			countNeighborColor++;
		}
	}
	
	countAvailColor = sizeof(tempColor)-1 - countNeighborColor;

	if (countAvailColor < 0)
	{
		//DLog(@"###########");
		//NSAssert(countAvailColor>0, @"##########");
		nowColor = 6;
	} else {
		
		NSInteger numRand = (((unsigned int)arc4random()) % countAvailColor);
		
		for (int i=0; i<sizeof(tempColor); i++)
		{
			if (tempColor[i] == NO)
			{
				if (numRand == 0)
				{
					nowColor = i;
					break;
				} else {
					numRand--;
				}
			}
		}
	}
	
	NSAssert(nowColor >= 0, @"##########");
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if (map[x][y] == num)
			{
				color[x][y] = nowColor;
			}
		}
	}
}

- (NSInteger) getCellNum:(NSInteger)x yPos:(NSInteger)y
{
	return map[x][y];
}	// from map

- (NSInteger) getColor:(NSInteger)x yPos:(NSInteger)y
{
	return color[x][y];
}	// from color
- (KillerCell*) getCellData:(NSInteger)num
{
	return cell[num].x0 >= 0 ? &(cell[num]) : NULL;
}	// from cell


- (NSInteger) getCellCount
{
	int num = 0;
	while (cell[num].x0 >= 0)
	{
		num++;
	}
	return num;
}

#define kKillerMap		@"killermap"

NSInteger   size;							// 6,9
NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
NSInteger	color[MAXMAPSIZE][MAXMAPSIZE];	// 0~7
KillerCell	cell[MAXMAPSIZE*MAXMAPSIZE/2];

- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	char zStrMap[MAXMAPSIZE*MAXMAPSIZE*3+1] = "";
	char zStrColor[MAXMAPSIZE*MAXMAPSIZE*3+1] = "";
	char zStrCell[MAXMAPSIZE*MAXMAPSIZE*3] = "";
	
	[KillerMap getNumsPipe:zStrMap		size:MAXMAPSIZE*MAXMAPSIZE	nums:&map[0][0]];
	[KillerMap getNumsPipe:zStrColor	size:MAXMAPSIZE*MAXMAPSIZE	nums:&color[0][0]];
	[KillerMap getNumsPipe:zStrCell		size:[self getCellCount]*sizeof(KillerCell)/sizeof(NSInteger)
										nums:(NSInteger*)&cell[0]];
	DLog(@"zStrCell(%s)", zStrCell);
	
	NSString *str = [NSString stringWithFormat:
					 @"%d,%s,%s,%s",
					 size,
					 zStrMap,
					 zStrColor,
					 zStrCell];
	
	DLog(@"saveData(%@)", str);
	
	[defaults setObject:str forKey:kKillerMap];
}

- (id) initWithSaveData
{
	if ((super.init) == nil)
		return nil;
	
	memset(map, -1, sizeof(map));
	memset(color, -1, sizeof(color));
	memset(cell, -1, sizeof(cell));
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kKillerMap];
	if (str == nil) {
		DLog(@"loadData Failed");
		return nil;
	}
	DLog(@"initWithSaveData(%@)", str);
	
	NSArray *listItems = [str componentsSeparatedByString:@","];

	size = [[listItems objectAtIndex:0] integerValue];
	[KillerMap setNumsPipe:[listItems objectAtIndex:1] size:MAXMAPSIZE*MAXMAPSIZE	nums:&map[0][0]];
	[KillerMap setNumsPipe:[listItems objectAtIndex:2] size:MAXMAPSIZE*MAXMAPSIZE	nums:&color[0][0]];
	[KillerMap setNumsPipe:[listItems objectAtIndex:3] size:MAXMAPSIZE*MAXMAPSIZE/2*sizeof(KillerCell)	nums:(NSInteger*)&cell[0]];
	
	return self;
}


+ (void) getNumsPipe:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums
{
    for (int i=0; i<size; i++)
    {
		if (nums[i] < 0)
			break;
		if (nums[i] >= 10)
			*str++ = ('0' + nums[i]/10);
		*str++ = ('0' + nums[i]%10);
		if (i+1 < size)
			*str++ = '|';
    }
    
    
	*str = '\0';
}

+ (void) setNumsPipe:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];
	
	for (int i=0; i<size && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		nums[i] = [[listItems objectAtIndex:i] integerValue];
	}
}


@end
