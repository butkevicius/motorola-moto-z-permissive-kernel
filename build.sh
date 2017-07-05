#!/bin/bash

ROOT=`pwd`
OUT_DIR=$ROOT/out/target/product/generic/obj/kernel
CPU_COUNT=`cat /proc/cpuinfo | grep processor | wc -l`
JOBS=$[CPU_COUNT + 1]
"${CROSS_COMPILE?Need to set CROSS_COMPILE}"


mkdir -p $OUT_DIR

function build {
	(perl -le 'print "# This file was automatically generated from:\n#\t" . join("\n#\t", @ARGV) . "\n"' \
	kernel/arch/arm/configs/msmcortex-perf_defconfig \
	kernel/arch/arm/configs/ext_config/moto-msmcortex.config \
	kernel/arch/arm/configs/ext_config/debug-msmcortex.config \
	kernel/arch/arm/configs/ext_config/moto-camera-addison.config \
	kernel/arch/arm/configs/ext_config/moto-addison.config && \
	cat kernel/arch/arm/configs/msmcortex-perf_defconfig \
	kernel/arch/arm/configs/ext_config/moto-msmcortex.config \
	kernel/arch/arm/configs/ext_config/debug-msmcortex.config) > $OUT_DIR/mapphone_defconfig || ( rm -f $kernel_out_dir/mapphone_defconfig && false )

	cp $OUT_DIR/mapphone_defconfig $OUT_DIR/.config

	make -C kernel O=$OUT_DIR ARCH=arm CROSS_COMPILE=$CROSS_COMPILE KBUILD_BUILD_USER= KBUILD_BUILD_HOST= defoldconfig
	make -j${JOBS} -C kernel KBUILD_RELSRC=$ROOT/kernel O=$OUT_DIR ARCH=arm CROSS_COMPILE=$CROSS_COMPILE KBUILD_BUILD_USER= KBUILD_BUILD_HOST= KCFLAGS=-mno-android
}

function clean {
	make -C kernel O=$OUT_DIR ARCH=arm CROSS_COMPILE=$CROSS_COMPILE KBUILD_BUILD_USER= KBUILD_BUILD_HOST= clean
}

case "$1" in
        clean)
            clean
            ;;
         
        *)
            build

esac
