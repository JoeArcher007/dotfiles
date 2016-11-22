# Joe's rc files
I used a script from another persons github that I can't recall that basically allows for making a backup of older bashrc (or defaults) and then symbolically links the rc files inside this github.

## To use
Clone the repository to your home directory by doing the following:

`git clone https://github.com/JoeArcher007/dotfiles.git`

Once done, then go into the directory

`cd dotfiles`

Then run the script

`./make.sh`

This will move all existing rc files (vimrc, inputrc, and bashrc) into a new directory old_dotfiles and then links the new files inside dotfiles directory into the home folder.

You can then logout and log back in and have the new rc files in use.
