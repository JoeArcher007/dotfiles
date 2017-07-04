#!/bin/bash
##########################################
# .make.sh
# This script creates symlinks from the home 
# directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
files="bashrc vimrc inputrc bash_aliases"    # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir || exit
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
        echo "Moving any existing dotfiles from ~ to $olddir"
            mv ~/."$file" "$olddir/"
                echo "Creating symlink to $file in home directory."
                    ln -s $dir/"$file" ~/."$file"
                done

echo "Would you like to link to roots rc files?"
read -p "[Y]es or [N]o: " yno

user_name=$USER

case "$yno" in 
         [yY] | [yY][Ee][sS] )
             for file in $files; do
                 echo "renaming old file $file"
                 sudo -i mv /root/."$file" /root/."$file".bak
                 echo "Creating the symlinks"
                 sudo -i ln -s "$HOME"/dotfiles/"$file" /root/."$file"
             done
        #sudo -i mv /root/.bashrc /root/.bashrc.bak ; mv /root/.vimrc /root/.vimrc.bak ; mv /root/.inputrc /root/.inputrc.bak ; ln -s $HOME/dotfiles/bashrc /root/.bashrc && ln -s $HOME/dotfiles/vimrc /root/.vimrc && ln -s $HOME/dotfiles/inputrc /root/.inputrc
        echo "All files have been renamed to .bak, and files have been linked to $home/dotfiles/*.rc"
        ;;
        [Nn] | [Nn][Oo] )
            echo "NOPE"
        ;;
esac
