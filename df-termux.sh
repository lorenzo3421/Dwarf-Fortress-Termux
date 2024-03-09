#!/bin/bash

# Download and install Ubuntu64
wget https://raw.githubusercontent.com/AllPlatform/Termux-UbuntuX86_64/master/Ubuntu-AMD64.sh
chmod +x Ubuntu-AMD64.sh
./Ubuntu-AMD64.sh

# Download Dwarf Fortress 64 bit in the Ubuntu64 filesystem
cd ubuntu-fs64/root # initial-folder/ubuntu-fs64/root
wget http://www.bay12games.com/dwarves/df_44_12_linux.tar.bz2
tar -xvf df_44_12_linux.tar.bz2
rm df_44_12_linux.tar.bz2

# Fix some files and configs to make the game run on Termux
cd df_linux # initial-folder/ubuntu-fs64/root/df_linux
rm libs/libstdc++.so.6
sed -i 's/\[PRINT_MODE:2D\]/\[PRINT_MODE:TEXT\]/' data/init/init.txt

# Create a file to install the dependencies on the first start of Ubuntu64
cd .. # initial-folder/ubuntu-fs64/root
echo "#!/bin/bash" > df-deps.sh
echo "apt update -y" >> df-deps.sh
echo "rm /var/lib/dpkg/info/\$nomdupaquet* -f" >> df-deps.sh
echo "apt install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libgtk2.0-0 libopenal1 libsndfile1 libncursesw5 libglu1-mesa" >> df-deps.sh
echo "chmod +x /root/df_linux/df" >> df-deps.sh
echo "chmod +x /root/df_linux/libs/Dwarf_Fortress" >> df-deps.sh
echo "clear" >> df-deps.sh
echo "echo \"Dwarf Fortress has been installed. To run it, use the command \"./df\".\"" >> df-deps.sh
echo "rm /root/df-deps.sh" >> df-deps.sh
chmod +x df-deps.sh

# Create a script to run Dwarf Fortress directly from the Termux shell
cd ../.. # initial-folder
echo "#!/bin/bash" > df
echo "cd \"\$(dirname \"\$0\")\"" >> df
echo "unset LD_PRELOAD" >> df
echo "command=\"proot\"" >> df
echo "command+=\" --link2symlink\"" >> df
echo "command+=\" -0\"" >> df
echo "command+=\" -r ubuntu-fs64 -q qemu-x86_64-static\"" >> df
echo "command+=\" -b /dev\"" >> df
echo "command+=\" -b /proc\"" >> df
echo "command+=\" -b ubuntu-fs64/root:/dev/shm\"" >> df
echo "command+=\" -w /root\"" >> df
echo "command+=\" /usr/bin/env -i\"" >> df
echo "command+=\" HOME=/root\"" >> df
echo "command+=\" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin\"" >> df
echo "command+=\" TERM=\$TERM\"" >> df
echo "command+=\" LANG=C.UTF-8\"" >> df
echo "command+=\" /bin/bash -c /root/df_linux/df\"" >> df
echo "\$command" >> df
chmod +x df

# Run the df-deps.sh script to install the dependencies
cd "$(dirname "$0")"
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r ubuntu-fs64 -q qemu-x86_64-static"
command+=" -b /dev"
command+=" -b /proc"
command+=" -b ubuntu-fs64/root:/dev/shm"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin"
command+=" TERM=$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash -c /root/df-deps.sh"

$command