#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku7free" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6free" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6paid" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9free" clean build
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9paid" clean build

