#!/usr/bin/sh
timedatectl set-ntp true
wipefs -a /dev/sda
parted -a optimal --script /dev/sda unit mib mklabel gpt mkpart '"EFI system partition"' fat32 1 513 set 1 esp on mkpart '"root partition"' ext4 513 100%
mkfs.fat -F32 /dev/sda1
mkfs.ext4 -F /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base base-devel linux linux-firmware git grub efibootmgr fish
genfstab -U /mnt >> /mnt/etc/fstab
echo "#!/usr/bin/bash
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
sed -ie 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
hwclock --systohc
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'arch-dell' > /etc/hostname
echo '127.0.0.1	localhost
::1		localhost
127.0.1.1	arch-dell.localdomain	arch-dell' >> /etc/hosts
echo 'blacklist pcspkr' > /etc/modprobe.d/nobeep.conf
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
sed -ie 's/#%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
useradd -mG wheel -s /bin/fish wera
echo 'root:141453' | chpasswd
echo 'wera:141453' | chpasswd
sed -ie 's/#Color/Color/' /etc/pacman.conf
pacman -Syu --noconfirm

sudo -i -u wera bash << EOF
echo '[user]
	email = sokneip@tuta.io
	name = WeraPea' >> ~/.gitconfig
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
rm -rf ~/yay
yay --save --answerclean N --answerdiff N 
yay --noconfirm --cleanafter -S noto-fonts xorg-mkfontscale xorg-server xorg-xinit xorg-xinput xorg-xsetroot xcape mpv rxvt-unicode urxvt-perls urxvt-resize-font-git unclutter sxiv zaread-git scrot rofi rofi-greenclip rofi-bluetooth-git rofi-calc pulseaudio pulseaudio-bluetooth pulseaudio-control progress polybar playerctl pidswallow pavucontrol pamixer pa_volume-git neovim man-db kdeconnect jq inotify-tools htop firefox exa dunst btops-git bspwm networkmanager sxhkd python-pip nerd-fonts-jetbrains-mono ttf-jetbrains-mono dash ntfs-3g brightnessctl mesa xf86-video-intel
pip install pynvim
git clone https://www.github.com/WeraPea/.dotfiles
git clone https://www.github.com/WeraPea/.scripts
rm ~/.bashrc ~/.config/fish/ -rf 
.dotfiles/linkall
.scripts/linkall
mkdir .dotfiles/nvim/bundle
cd ~/.dotfiles/nvim/bundle/
git clone https://github.com/VundleVim/Vundle.vim
echo '/usr/bin/bspwm' >> ~/.xinitrc
systemctl --user enable ssh-agent
EOF

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sshd
rm /bin/sh
ln -s dash /bin/sh
rm /arch-install-part2.sh
su - wera" >> /mnt/arch-install-part2.sh
chmod +x /mnt/arch-install-part2.sh
arch-chroot /mnt /arch-install-part2.sh
