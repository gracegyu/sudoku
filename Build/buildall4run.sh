#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -target "sudoku6free"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "sudoku6paid"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "sudoku7free"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "sudoku9free"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "sudoku9paid"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "gtsudoku6free"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "gtsudoku6paid"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "gtsudoku9free"  -configuration Run
xcodebuild  -project ../sudokuall.xcodeproj  -target "gtsudoku9paid"  -configuration Run
