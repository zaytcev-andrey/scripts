#!/bin/bash

#script for building gcc 5.2.0

GCC_VER=5.2.0
GMP_VER=4.3.2
MPFR_VER=2.4.2
MPC_VER=1.0.1

./gcc_build.sh $GCC_VER $GMP_VER $MPFR_VER $MPC_VER
