#!/bin/bash

sudo apt-get install p7zip-full dos2unix libhivex-bin 

export win7iso=~/Downloads/windows/7/enterprise_trial/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso

# http://www.ultimatedeployment.org/win7pxelinux1.html
# http://www.ultimatedeployment.org/win7pxelinux.tgz
# http://www.ultimatedeployment.org/wimlib.html

wget http://www.ultimatedeployment.org/wimlib-0.2.tgz
tar xvfz wimlib-0.2.tgz
cd wimlib-0.2/src
make
cd -

#7z x 7/enterprise_trial/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso -so sources/install.wim > tftp/AMD64/ISO/sources/7enterprise.wim

mkdir tftproot
7z x $win7iso -so sources/boot.wim > boot.wim
./wimlib-0.2/src/updatewim boot.wim tftproot/winpe.wim wim.action

cd tftproot
7z x $win7iso -so boot/boot.sdi > boot.sdi
7z x $win7iso -so boot/bcd > bcd
7z x ../boot.wim -so 1/Windows/Boot/PXE/pxeboot.n12 > pxeboot.com
7z x ../boot.wim -so 1/Windows/Boot/PXE/wdsnbp.com > wdsnbp.0
7z x ../boot.wim -so 1/Windows/Boot/PXE/bootmgr.exe > bootmgr.exe
7z x ../boot.wim -so 1/Windows/Boot/DVD/PCAT/BCD boot/boot.sdi > boot.sdi
cd -

mkdir system1
cp wdsnbp.0 bcd system1/
../bcdedit.pl system1/bcd /winpe.wim /boot.sdi INFO=10.0.0.1:system1

mkdir system2
cp wdsnbp.0 bcd system2/
../bcdedit.pl system2/bcd /winpe.wim /boot.sdi INFO=10.0.0.1:system2
