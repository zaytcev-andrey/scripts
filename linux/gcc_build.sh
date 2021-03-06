#!/bin/bash

#script for building gcc any version (tested with 4.9.3 and over)

GCC_VER=$1
GMP_VER=$2
MPFR_VER=$3
MPC_VER=$4

GMP=gmp-$GMP_VER
MPFR=mpfr-$MPFR_VER
MPC=mpc-$MPC_VER
GCC_SRC=gcc-$GCC_VER
GCC_BUILD_DIR=/usr/local/bin/$GCC_SRC
RES_LIB_DIR=/usr/lib
HARDWARE_PLATFORM=`uname -i`

BUILD_OPT=''
OS_NAME=''

echo "test ubuntu!"

if [ "$(uname -a | grep Ubuntu)" != "" ]
then 
	echo "yo! man! its ubuntu!"
	BUILD_OPT=--build=x86_64-linux-gnu
	echo "build options is: $BUILD_OPT"
	OS_NAME="Ubuntu"
fi

#recreate temp directory
TMPDIR=~/tmp
if [ -d $TMPDIR ] 
then 
	echo 'yo! man! '$TMPDIR' is exists! recreate it'
	rm -rf $TMPDIR
fi
mkdir $TMPDIR

#cleanup all files
cleanup() 
{
	echo 'claening up...'
	echo "claenup `$TMPDIR`"
	rm -rf $TMPDIR
	echo 'claenup successfully'
}

#downloadin prerequisites

echo "downloading $GMP..."
wget -O $TMPDIR/$GMP.tar.bz2 ftp://mirrors.kernel.org/gnu/gmp/$GMP.tar.bz2
echo "downloading $MPFR..."
wget -O $TMPDIR/$MPFR.tar.bz2 ftp://mirrors.kernel.org/gnu/mpfr/$MPFR.tar.bz2
echo "downloading $MPC..."
wget -O $TMPDIR/$MPC.tar.gz ftp://mirrors.kernel.org/gnu/mpc/$MPC.tar.gz
echo "downloading $GCC_SRC..."
wget -O $TMPDIR/$GCC_SRC.tar.gz http://gcc.parentingamerica.com/releases/$GCC_SRC/$GCC_SRC.tar.gz

# create $GCC_BUILD_DIR directory
if [ -d $GCC_BUILD_DIR ] 
then 
	echo 'yo! man! '$GCC_BUILD_DIR' is exists! lets recreate it'
	rm -rf $GCC_BUILD_DIR
fi
mkdir $GCC_BUILD_DIR

pushd $TMPDIR

# build $GMP
# unpack
tar -jxvf $GMP.tar.bz2
pushd $GMP

mkdir build && pushd build
../configure --prefix=$GCC_BUILD_DIR $BUILD_OPT
make
sudo make install
	
popd #pop build $GMP
popd #pop $GMP

# build $MPFR
# unpack
tar -jxvf $MPFR.tar.bz2
pushd $MPFR

mkdir build && pushd build
../configure --prefix=$GCC_BUILD_DIR --with-gmp=$GCC_BUILD_DIR $BUILD_OPT
make
sudo make install
	
popd #pop build $MPFR
popd #pop $MPFR

#build $MPC
#unpack
tar -zxvf $MPC.tar.gz
pushd $MPC

mkdir build && pushd build
../configure --prefix=$GCC_BUILD_DIR $BUILD_OPT --with-gmp=$GCC_BUILD_DIR --with-mpfr=$GCC_BUILD_DIR
make
sudo make install
	
popd #pop build $MPC
popd #pop $MPC


#build $GCC_SRC
#unpack
tar -zxvf $GCC_SRC.tar.gz
pushd $GCC_SRC

mkdir build && pushd build
#../configure --prefix=$GCC_BUILD_DIR $BUILD_OPT --with-gmp=$GCC_BUILD_DIR --with-mpfr=$GCC_BUILD_DIR

# exporting path
export LD_LIBRARY_PATH=$GCC_BUILD_DIR/lib:$LD_LIBRARY_PATH

if [ $OS_NAME = "Ubuntu" ]
then
	export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/
	export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
	export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu
fi

../configure \
$BUILD_OPT \
--prefix=$GCC_BUILD_DIR \
--with-gmp=$GCC_BUILD_DIR \
--with-mpfr=$GCC_BUILD_DIR \
--with-mpc=$GCC_BUILD_DIR \
--enable-checking=release \
--enable-languages=c,c++,fortran,go \
--disable-multilib \
--program-suffix=-$GCC_VER
make
sudo make install
	
popd #pop build $MPC
popd #pop $MPC

# add gcc-$GCC_VER into PATH and create links for lib
#export LD_LIBRARY_PATH=$GCC_BUILD_DIR/lib:$GCC_BUILD_DIR/lib64:$LD_LIBRARY_PATH
echo export PATH=$GCC_BUILD_DIR/bin:$PATH >> ~/.bashrc
for file in $(ls $GCC_BUILD_DIR/lib/*); do	
	if [ -f $file ] 
	then 
		ln -sfv $file $RES_LIB_DIR/"$(basename $file)"
	fi
done


popd #pop $TMPDIR

cleanup
