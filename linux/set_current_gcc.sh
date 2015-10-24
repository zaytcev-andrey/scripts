#!/bin/bash

# script for setting current specified version of gcc or restoring previous

NEW_GCC_VER=$1
GCC_PREV_VER_FILE=$HOME/.gcc_history
GCC_CUR_VER=`gcc --version | head -n 1 | cut -d ")" -f 2 -s | cut -b 2-6`

if [ -z "$(which gcc)" ]
then
	echo "gcc does not exist at all."
	exit 0
fi

if [ "$1" = "restore" ]
then

	if [ -f $GCC_PREV_VER_FILE ]
	then
		echo "file with previous version of gcc exists."
		
		GCC_PREV_PATH=$(cat $GCC_PREV_VER_FILE)

		if [ ! -f $GCC_PREV_PATH ]
		then
			echo "path $GCC_PREV_PATH of previous gcc version does not exist"		
			exit 1
		fi

		GCC_PREV_VER=`$GCC_PREV_PATH --version | head -n 1 | cut -d ")" -f 2 -s | cut -b 2-6`

		echo "restoring $GCC_PREV_VER version of gcc..."
		
		sudo ln -sf $GCC_PREV_PATH /usr/bin/gcc
		
		PREV_GCC_VER_ASSERT=`/usr/bin/gcc --version | head -n 1 | cut -d ")" -f 2 | cut -b 2-6`
		
		if [ "$PREV_GCC_VER_ASSERT" != "$GCC_PREV_VER" ]
		then
			echo "something wrong: can not resoring previous version $GCC_PREV_VER"
			echo "find only gcc-$PREV_GCC_VER_ASSERT. will exit"
			exit 1
		fi		

		rm -f $GCC_PREV_VER_FILE
		echo "previous version $GCC_PREV_VER of gcc successfully restored"
		exit 0
		
	else
		echo "file with previous version of gcc does not exist."		
		echo "current vertion of gcc is "$GCC_CUR_VER
	fi
else

	if [ "$GCC_CUR_VER" = "$NEW_GCC_VER" ]
	then
		echo "version $NEW_GCC_VER of gcc is already installed. exit"
		exit 0
	fi

	CUR_GCC_PATH=`readlink -f /usr/bin/gcc`	
	NEW_GCC_PATH=`whereis gcc-$NEW_GCC_VER | cut -d " " -f2 -s`

	if [ "$NEW_GCC_PATH" = "" ]
	then
		echo "there is no gcc version $NEW_GCC_VER"
		exit 0	
	fi

	# test is it file or directory, it maybe custom builded gcc and "whereis gcc-***"
	# return direcotry path rather than path to executable

	if [ -d "$NEW_GCC_PATH" ]
	then
		echo "whereis retrun directory. try to find gcc executable"
		
		if [ ! -f $NEW_GCC_PATH/bin/gcc-$NEW_GCC_VER ]
		then
			echo "can not find file $NEW_GCC_PATH/bin/gcc-$NEW_GCC_VER"
		
			exit 1
		fi	

		NEW_GCC_PATH=$NEW_GCC_PATH/bin/gcc-$NEW_GCC_VER
		echo "find file $NEW_GCC_PATH"

	fi

	echo "setting up $NEW_GCC_VER as current version gcc"	
	echo "current ver path = "$CUR_GCC_PATH " new ver path = "$NEW_GCC_PATH
	
	NEW_GCC_VER_ASSERT=`$NEW_GCC_PATH --version | head -n 1 | cut -d ")" -f 2 | cut -b 2-6`

	if [ "$NEW_GCC_VER_ASSERT" != "$NEW_GCC_VER" ]
	then
		echo "something wrong: can not find gcc with you version $NEW_GCC_VER"
		echo "find only gcc-$NEW_GCC_VER_ASSERT. will exit"
		exit 1
	fi
	
	echo $CUR_GCC_PATH > $GCC_PREV_VER_FILE
	
	sudo ln -sf $NEW_GCC_PATH /usr/bin/gcc
	
fi
