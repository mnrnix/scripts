#part1
timedatectl set-timezone Europe/Bucharest
timedatectl set-ntp true
hwclock --systohc
pacman -Syyy python reflector
reflector --verbose --latest 5 --age 6 --protocol https --download-timeout 5 --sort rate --save /etc/pacman.d/mirrorlist
echo "Enter ROOT drive: "
read rootpart
mount $rootpart /mnt
mkdir -p /mnt/{boot,home,data}
echo "Enter BOOT drive: "
read bootpart
mount $bootpart /mnt/boot
echo "Enter HOME drive: "
read homepart
mount $homepart /mnt/home
echo "Enter DATA drive: "
read datapart
mount $datapart /mnt/data
pacstrap -i /mnt base base-devel linux linux-firmware linux-headers intel-ucode git curl wget rsync rclone python reflector vim neovim pacman-contrib terminus-font
genfstab -U -p /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' arch_install.sh >> /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

#part2
pacman -Syyy --noconfirm sed
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 5/" /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
echo "Europe/Bucharest" > /etc/timezone
hwclock --systohc
echo "en_US.UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "FONT=Lat2-Terminus16" >> /etc/vconsole.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1		localhost" > /etc/hosts
echo "::1		localhost" >> /etc/hosts
echo "127.0.1.1		$hostname.localdomain $hostname" >> /etc/hosts
mkinitcpio -P
passwd
pacman -Syyy --noconfirm grub sudo dialog yad dosfstools mtools ntfs-3g os-prober networkmanager network-manager-applet
echo "Enter Grub Install Disk: "
read diskgrub
grub-install --target=i386-pc $diskgrub
grub-mkconfig -o /boot/grub/grub.cfg

pacman -Syyy --noconfirm pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol \
	xf86-video-intel xorg xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xprop \
	sxiv mpv ffmpeg imagemagick ueberzug fzf man-db xclip xsel maim scrot zip unzip unrar p7zip \
	xdotool firefox lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings grub-customizer

systemctl enable NetworkManager lightdm
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "Enter Regular Username: "
read username
useradd -mG wheel -s /bin/bash $username
passwd $username
echo "Pre-Installation Finish Reboot Now"
ai3_path=/home/$username/arch_install3.sh
sed '1,/^#part3$/d' arch_install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/bash $username
exit

#part3
pacman -Syyy --noconfirm bspwm sxhkd dmenu dunst libnotify jq net-tools bind inetutils htop screen tmux neofetch screenfetch \
	usbutils android-tools gvfs gvfs-nfs gvfs-mtp udiskie udisks2 gparted devtools lsd exa bat ripgrep procs xdg-user-dirs xdg-user-dirs-gtk \
	pass pass-otp gopass qt5ct keepassxc tree meld gnome-disk-utility lshw make stow asciinema bashtop cmake fuse-overlayfs \
	python-pip dmidecode mlocate
exit
