time1="$( date +"%r" )"

install1 () {
directory=ubuntu-fs
UBUNTU_VERSION=21.04
if [ -d "$directory" ];then
first=1
printf "\x1b[38;5;227m[WARNING]:\e[0m \x1b[38;5;87m Skipping the download and the extraction\n"
elif [ -z "$(command -v proot)" ];then
printf "\x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install proot.\n pkg install proot \n"
printf "\e[0m"
exit 1
elif [ -z "$(command -v wget)" ];then
printf "\x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Please install wget.\n pkg install wget \n"
printf "\e[0m"
exit 1
fi
if [ "$first" != 1 ];then
if [ -f "ubuntu.tar.gz" ];then
rm -rf ubuntu.tar.gz
fi
if [ ! -f "ubuntu.tar.gz" ];then
printf "\x1b[38;5;83m[Download ubuntu]:\e[0m \x1b[38;5;87m Downloading ubuntu rootfs \n please wait 2min... \n"
ARCHITECTURE=$(dpkg --print-architecture)
case "$ARCHITECTURE" in
aarch64) ARCHITECTURE=arm64;;
arm) ARCHITECTURE=armhf;;
amd64|x86_64) ARCHITECTURE=amd64;;
*)
printf "\x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Unknown architecture :- $ARCHITECTURE"
exit 1
;;

esac

wget http://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_VERSION}/release/ubuntu-base-${UBUNTU_VERSION}-base-${ARCHITECTURE}.tar.gz -q -O ubuntu.tar.gz 
printf "\x1b[38;5;83m[Download Ubuntu]:\e[0m \x1b[38;5;87m Download complete!\n"

fi

cur=`pwd`
mkdir -p $directory
cd $directory
printf "\x1b[38;5;83m[unzip]:\e[0m \x1b[38;5;87m Decompressing the ubuntu rootfs, please wait...\n"
tar -zxf $cur/ubuntu.tar.gz --exclude='dev'||:
printf "\x1b[38;5;83m[unzip]:\e[0m \x1b[38;5;87m The ubuntu rootfs have been successfully decompressed!\n"
printf "\x1b[38;5;83m[Fix Resolv]:\e[0m \x1b[38;5;87m Fixing the resolv.conf, so that you have access to the internet\n"
printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > etc/resolv.conf
stubs=()
stubs+=('usr/bin/groups')
for f in ${stubs[@]};do
printf "\x1b[38;5;87m Writing stubs, please wait...\n"
echo -e "#!/bin/sh\nexit" > "$f"
done
printf "\x1b[38;5;83m[Installer wrote]:\e[0m \x1b[38;5;87m Successfully wrote stubs!\n"
cd $cur

fi

mkdir -p ubuntu-binds
bin=start.sh
printf "\x1b[38;5;83m[created script]:\e[0m \x1b[38;5;87m Creating start script, please wait...\n"
cat > $bin <<- EOM


cd \$(dirname \$0)


unset LD_PRELOAD
command="proot"


command+=" --link2symlink"
command+=" -0"
command+=" -r $directory"
if [ -n "\$(ls -A ubuntu-binds)" ]; then
    for f in ubuntu-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b /sys"
command+=" -b ubuntu-fs/tmp:/dev/shm"
command+=" -b /data/data/com.termux"
command+=" -b /:/host-rootfs"
command+=" -b /sdcard"
command+=" -b /storage"
command+=" -b /mnt"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
printf "\x1b[38;5;83m[script created]:\e[0m \x1b[38;5;87m The start script has been successfully created!\n"
printf "\x1b[38;5;83m[fixed Start]:\e[0m \x1b[38;5;87m Fixing start.sh, please wait...\n"
termux-fix-shebang $bin
printf "\x1b[38;5;83m[fixed Start]:\e[0m \x1b[38;5;87m Successfully fixed start.sh! \n"
printf "\x1b[38;5;83m[Make Start.sh]:\e[0m \x1b[38;5;87m Making start.sh executable please wait...\n"
chmod +x $bin
printf "\x1b[38;5;83m[Making=> start.sh]:\e[0m \x1b[38;5;87m maked start.sh\n"
printf "\x1b[38;5;83m[up cleaned]:\e[0m \x1b[38;5;87m Cleaning up please wait...\n"
rm ubuntu.tar.gz -rf
printf "\x1b[38;5;83m[Install cleaned]:\e[0m \x1b[38;5;87m Successfully cleaned up!\n"
printf "\x1b[38;5;83m Channel Telegram:\e[0m \x1b[38;5;87m T.me/HACKGM \n \n \n Run Root in the Termux: bash start.sh \n"
printf "\e[0m"

}
if [ "$1" = "-y" ];then
install1
elif [ "$1" = "" ];then
printf "\x1b[38;5;87m install Root in the Termux?  [Y/n] "

read cmd1
if [ "$cmd1" = "y" ];then
install1
elif [ "$cmd1" = "Y" ];then
install1
else
printf "\x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
exit
fi
else
printf "\x1b[38;5;203m[ERROR]:\e[0m \x1b[38;5;87m Installation aborted.\n"
printf "\e[0m"
fi
#Telegram: T.me/Hackgm