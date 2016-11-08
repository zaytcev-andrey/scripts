#!/bin/bash

INSTALL=0
REMOVE=0
FULL=0

CURRENT_DIR=$(pwd)
TMP_DIR=$CURRENT_DIR/emacs-installing-tmp
# emacs variables
EMACS_ARCH_NAME=emacs-25.1.tar.gz
EMACS_SRC_DIR=$(basename "$EMACS_ARCH_NAME" .tar.gz)
EMACS_BIN=/usr/local/bin/emacs
EMACS_SHARE_DIR=/usr/local/share/emacs
EMACS_LIBEXEC_DIR=/usr/local/libexec/emacs
EMACS_INFO_MASK=/usr/local/share/info/emacs*
EMACS_MAN_MASK=/usr/local/share/man/man1/emacs*
#gnu global variables
GNUGLOBAL=global-6.5.5.tar.gz
GNUGLOBAL_SRC_DIR=$(basename "$GNUGLOBAL" .tar.gz)
GNUGLOBAL_BIN_GTAGS_MASK=/usr/local/bin/gtags*
GNUGLOBAL_BIN_GLOBAL=/usr/local/bin/global
GNUGLOBAL_LIB_DIR=/usr/local/lib/gtags
GNUGLOBAL_SHARE_DIR=/usr/local/share/gtags
GNUGLOBAL_MAN1_MASK=/usr/local/share/man/man1/gtags*
GNUGLOBAL_MAN5_MASK=/usr/local/share/man/man5/gtags*
GNUGLOBAL_VAR_DIR=/usr/local/var/gtags

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

function install_emacs_only()
{
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
}

function remove_emacs_only()
{
	echo "remove emacs by apt-get"
	sudo apt-get remove -y emacs24-nox emacs24-el emacs24-common-non-dfsg

	echo "removing emacs files by path $EMACS_BIN"
	remove_by_path $EMACS_BIN
	
	echo "removing emacs files by path $EMACS_SHARE_DIR"
	remove_by_path $EMACS_SHARE_DIR

	echo "removing emacs files by path $EMACS_LIBEXEC_DIR"
	remove_by_path $EMACS_LIBEXEC_DIR
	
	echo "removing emacs files by path $EMACS_INFO_MASK"
	remove_by_path $EMACS_INFO_MASK

	echo "removing emacs files by path $EMACS_MAN_MASK"
	remove_by_path $EMACS_MAN_MASK	
}

function install_gnu_global()
{
	echo "installing gnu global ..."
	pushd $TMP_DIR

	    echo "downloding global-6.4.tar.gz"
	    wget ftp://ftp.gnu.org/pub/gnu/global/$GNUGLOBAL

	    if [ $? -ne 0 ]
	    then
			echo "error: can not download $GNUGLOBAL"
			exit 1
		fi

		echo "extract gnu global source distributive $GNUGLOBAL"
		tar -zxvf $GNUGLOBAL

		if [ $? -ne 0 ]
		then
   			echo "error: can not extract from $GNUGLOBAL"
			exit 1
		fi

		if [ ! -d "$GNUGLOBAL_SRC_DIR" ]
		then
			echo "error: can not find extracted dir $GNUGLOBAL_SRC_DIR"
			exit 1
		fi

		# installing
		pushd $GNUGLOBAL_SRC_DIR

			echo "configuring ..."
			./configure
		
			echo "building ..."
			make
			
			echo "installing ..."
			sudo make install

		popd
    popd
}

function remove_gnu_global()
{
	echo "removing gnu global files by path $GNUGLOBAL_BIN_GLOBAL"
	remove_by_path $GNUGLOBAL_BIN_GLOBAL

	echo "removing gnu global files by path $GNUGLOBAL_BIN_GTAGS_MASK"
	remove_by_path $GNUGLOBAL_BIN_GTAGS_MASK
	
	echo "removing gnu global files by path $GNUGLOBAL_LIB_DIR"
	remove_by_path $GNUGLOBAL_LIB_DIR
	
	echo "removing gnu global files by path $GNUGLOBAL_SHARE_DIR"
	remove_by_path $GNUGLOBAL_SHARE_DIR

	echo "removing gnu global files by path $GNUGLOBAL_MAN1_MASK"
	remove_by_path $GNUGLOBAL_MAN1_MASK

	echo "removing gnu global files by path $GNUGLOBAL_MAN5_MASK"
	remove_by_path $GNUGLOBAL_MAN5_MASK

	echo "removing gnu global files by path $GNUGLOBAL_VAR_DIR"
	remove_by_path $GNUGLOBAL_VAR_DIR
}

function install_components()
{
	install_gnu_global
}

function remove_components()
{
	remove_gnu_global
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

# removing
if [ $REMOVE = 1 ]
then
	remove_emacs_only

	if [ $FULL = 1 ]
	then
		echo "removing components ..."
		remove_components
	fi
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

	install_emacs_only

	if [ $FULL = 1 ]
	then
		echo "installing components ..."
		install_components
	fi	

	if [ -d $TMP_DIR ]
	then
		echo "emacs installed successfully"

		echo "remove tem dir $TMP_DIR"
		sudo rm -rf $TMP_DIR
	fi
fi
