#!/bin/sh

xcodebuild -project ../sudokuall.xcodeproj  -target "sudoku6free"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "sudoku6paid"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "sudoku7free"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "sudoku9free"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "sudoku9paid"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "gtsudoku6free"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "gtsudoku6paid"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "gtsudoku9free"  -configuration Debug
xcodebuild -project ../sudokuall.xcodeproj  -target "gtsudoku9paid"  -configuration Debug


