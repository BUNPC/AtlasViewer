@echo off

mkdir bin
mkdir bin\Win
mkdir obj
mkdir obj\Win

copy /Y makefile.win makefile
copy /Y src\makefile.win src\makefile


set CC=bcc32
REM set CFLAGS_DEBUG=-v -c -DDEBUG -DSINGLE_PREC
set CFLAGS_DEBUG=-v -c -DDEBUG 
set LFLAGS_DEBUG=-v
REM set CFLAGS_OPT=-c -DSINGLE_PREC
set CFLAGS_OPT=-c
set LFLAGS_OPT=
set MOVE=move
set RM=del /Q /S
set OS=Win
set OBJ=obj
set TARGET_EXE_DEBUG=tMCimg.exe
set TARGET_OBJ_DEBUG=tMCimg.obj
set TARGET_EXE_OPT=tMCimg.exe
set TARGET_OBJ_OPT=tMCimg.obj


REM ###################################################
REM # The following three variables are meant to be configured 
REM # to point to the actual paths of your Borland compiler
REM ###################################################
echo ************************************************
echo NOTE: Make sure the following variables are correctly
echo       pointing to your compiler paths. If not, open
echo       install_win.bat in a text editor and set them
echo       correctly.
echo ************************************************

set CC_ROOT_PATH=D:\Borland\Bcc55
set CC_INCLUDE_PATH=-I%CC_ROOT_PATH%\Include
set CC_LIB_PATH=-L%CC_ROOT_PATH%\lib

echo CC_ROOT_PATH    = %CC_ROOT_PATH%
echo CC_INCLUDE_PATH = %CC_INCLUDE_PATH%
echo CC_LIB_PATH     = %CC_LIB_PATH%
