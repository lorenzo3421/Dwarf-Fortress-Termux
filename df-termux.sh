#!/bin/bash

UBUNTU_SCRIPT_URL="https://raw.githubusercontent.com/AllPlatform/Termux-UbuntuX86_64/master/Ubuntu-AMD64.sh"
DWARF_FORTRESS_URL="http://www.bay12games.com/dwarves/df_44_12_linux.tar.bz2"
UBUNTU_ROOT="ubuntu-fs64/root"
DF_DIR="df_linux"

# Download and install Ubuntu64
echo "Downloading and setting up Ubuntu64..."
wget "$UBUNTU_SCRIPT_URL" -O Ubuntu-AMD64.sh
chmod +x Ubuntu-AMD64.sh
./Ubuntu-AMD64.sh

# Download and extract Dwarf Fortress in Ubuntu64 filesystem
echo "Downloading and extracting Dwarf Fortress..."
cd "$UBUNTU_ROOT"
wget "$DWARF_FORTRESS_URL" -O df.tar.bz2
tar -xvf df.tar.bz2
rm df.tar.bz2

# Configure Dwarf Fortress
echo "Configuring Dwarf Fortress..."
cd "$DF_DIR"
rm libs/libstdc++.so.6
sed -i 's/\[PRINT_MODE:2D\]/\[PRINT_MODE:TEXT\]/' data/init/init.txt

# Create a dependency installation script
echo "Creating dependency installation script..."
cat > ../df-deps.sh << 'EOF'
#!/bin/bash
apt update -y
rm /var/lib/dpkg/info/$nomdupaquet* -f
apt install -y libsdl1.2debian libsdl-image1.2 libsdl-ttf2.0-0 libgtk2.0-0 libopenal1 libsndfile1 libncursesw5 libglu1-mesa
chmod +x /root/df_linux/df
chmod +x /root/df_linux/libs/Dwarf_Fortress
clear
echo "Dwarf Fortress has been installed. To run it, use the command './df'."
rm /root/df-deps.sh
EOF
chmod +x ../df-deps.sh

# Create a script to run Dwarf Fortress from Termux
echo "Creating run script for Termux..."
cd ../..
cat > df << 'EOF'
#!/bin/bash
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
command+=" /bin/bash -c /root/df_linux/df"
$command
EOF
chmod +x df

# Run the dependency installation script
echo "Running dependency installation script..."
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

echo "Setup complete. You can now run Dwarf Fortress using './df'."
