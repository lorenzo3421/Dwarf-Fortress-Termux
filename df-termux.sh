#!/bin/bash

BASE_DIR="$(pwd)"
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
sed -i 's/main/main restricted universe multiverse/' /etc/apt/sources.list 2>/dev/null || true
sed -i 's/Components: main/Components: main restricted universe multiverse/' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
apt update -y
apt install --no-install-recommends -y libsdl1.2-compat libsdl-image1.2 libsdl-ttf2.0-0 libgtk2.0-0 libopenal1 libsndfile1 libncursesw6 libncurses6 libtinfo6 libglu1-mesa
ln -s /usr/lib/x86_64-linux-gnu/libncursesw.so.6 /usr/lib/x86_64-linux-gnu/libncursesw.so.5 2>/dev/null || true
ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5 2>/dev/null || true
ln -s /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5 2>/dev/null || true
apt clean
rm -rf /var/lib/apt/lists/*
chmod +x /root/df_linux/df
chmod +x /root/df_linux/libs/Dwarf_Fortress
rm -f /root/df-deps.sh
EOF
chmod +x ../df-deps.sh

# Create a script to run Dwarf Fortress from Termux
echo "Creating run script for Termux..."
cd "$BASE_DIR"
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
cd "$BASE_DIR"
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

if $command; then
    printf "\n\033[1;32mSetup complete! You can now run Dwarf Fortress using './df'.\033[0m\n"
else
    printf "\n\033[1;31mSetup failed during dependency installation. Please check the logs above.\033[0m\n"
fi
