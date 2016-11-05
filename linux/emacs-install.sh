#!/bin/bash

INSTALL=0
REMOVE=0
FULL=0

function show_help()
{
	echo "usage: emacs-install.sh [install|reinstall|remove][full]"
	echo " install - install emacs without components"
	echo " remove - remove emacs without components"
	echo " reinstall - reinstall emacs without components"
	echo " full - make any operation with components"
	echo " example: emacs-install.sh install full"
}

function parse_first_param()
{
	case "$1" in
	"install")
		INSTALL=1
		;;
	"reinstall")
		INSTALL=1
		REMOVE=1
		;;
	"remove")
		REMOVE=1
		;;
	"--help")
		show_help
		exit 0
		;;
	*)
		show_help
		exit 1
		;;
	esac
}

function parse_second_param()
{
	if [ "$1" = "full" ]
	then
		FULL=1
	else
		show_help
		exit 1
	fi
}

function remove_by_path()
{
	sudo rm -rf $1
	echo "removed $1"
}

# parse command line
case $# in
1)
	parse_first_param $1
	;;
2)
	parse_first_param $1
	parse_second_param $2
	;;
*)
	show_help
	exit 1
	;;
esac

CURRENT_DIR=$(pwd)
TMP_DIR=$CURRENT_DIR/emacs-installing-tmp
EMACS_ARCH_NAME=emacs-25.1.tar.gz
EMACS_SRC_DIR=`echo "$EMACS_ARCH_NAME" | cut -d '.' -f1-2`
EMACS_BIN=/usr/local/bin/emacs
EMACS_SHARE_DIR=/usr/local/share/emacs
EMACS_LIBEXEC_DIR=/usr/local/libexec/emacs
EMACS_INFO_MASK=/usr/local/share/info/emacs*
EMACS_MAN_MASK=/usr/local/share/man/man1/emacs*

# removing
if [ $REMOVE = 1 ]
then
	echo "remove emacs by apt-get"
	sudo apt-get remove -y emacs24-nox emacs24-el emacs24-common-non-dfsg

	echo "removing emacs files by path $EMACS_BIN"
	remove_by_path $EMACS_BIN
	
	echo "removing emacs files by path $EMACS_BIN"
	remove_by_path $EMACS_SHARE_DIR

	echo "removing emacs files by path $EMACS_LIBEXEC_DIR"
	remove_by_path $EMACS_LIBEXEC_DIR
	
	echo "removing emacs files by path $EMACS_INFO_MASK"
	remove_by_path $EMACS_INFO_MASK

	echo "removing emacs files by path $EMACS_MAN_MASK"
	remove_by_path $EMACS_MAN_MASK
fi

# installing
if [ $INSTALL = 1 ]
then

	echo "creating temp dir $TMP_DIR"

	if [ -d "$TMP_DIR" ]
	then
		echo "temp dir $TMP_DIR exists" 
		echo "remove them and create again"
		rm -rf $TMP_DIR
	fi

	mkdir $TMP_DIR

	if [ ! -d "$TMP_DIR" ]
	then
		echo "error: can not create temp dir $TMP_DIR"
		exit 1
	fi

	pushd $TMP_DIR
	
		echo "run in $TMP_DIR"
		echo "download emacs source distributive $EMACS_ARCH_NAME"
		wget http://mirror.tochlab.net/pub/gnu/emacs/$EMACS_ARCH_NAME

		if [ $? -ne 0 ]
		then
			echo "error: can not download $EMACS_ARCH_NAME"
			exit 1
		fi

		echo "extract emacs source distributive $EMACS_ARCH_NAME"
		tar -zxvf $EMACS_ARCH_NAME

		if [ $? -ne 0 ]
		then
			echo "error: can not extract from $EMACS_ARCH_NAME"
			exit 1
		fi

		if [ ! -d "$EMACS_SRC_DIR" ]
		then
			echo "error: can not find extracted dir $EMACS_SRC_DIR"
			exit 1
		fi

		# installing
		pushd $EMACS_SRC_DIR

			echo "configuring emacs sources ..."

			bash ./autogen.sh
			./configure --without-x

			echo "building ..."
			make

			echo "installing ..."
			sudo make install

		popd

	popd

	if [ -d $TMP_DIR ]
	then
		echo "emacs installed successfully"

		echo "remove tem dir $TMP_DIR"
		sudo rm -rf $TMP_DIR
	fi
fi
