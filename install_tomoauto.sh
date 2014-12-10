#!/bin/sh 
#------------------------------------------------------------------------------#
#                             install_tomoauto.sh                              #
#------------------------------------------------------------------------------#
# This shell script handles the installation of tomoauto.                      #
#------------------------------------------------------------------------------#
# Author: Dustin Morado                                                        #
# Written: December 2nd 2014                                                   #
# Contact: Dustin dot Morado at gmail                                          #
#------------------------------------------------------------------------------#
printf "Hello \"$USER\"!\n"
printf "This shell script handles the installation of tomoauto\n"
printf "======================================================\n\n"
printf "Where is tomoauto currently located?\n" 
printf "\t(Default: \"$PWD\"): "
read tomoauto_answer

if [ "$tomoauto_answer" ]; then
    tomoauto_dir="$tomoauto_answer"
else
    tomoauto_dir="$PWD"
fi

printf "\nInstalling tomoauto to: \"$tomoauto_dir\"\n\n"

printf "Do you want to proceed with the installation? [Y/N]: "
read user_approval

case "$user_approval" in
    Y|y)
        printf "Proceeding...\n\n"
        ;;
    N|n)
        printf "Aborting installation... Goodbye!\n\n"
        exit 0
        ;;
    *)
        printf "Error: Invalid user input.\n"
        printf "Aborting installation... Goodbye!\n\n"
        exit 1
        ;;
esac

user_shell=$(basename "$SHELL")
tomoauto_init_file="$tomoauto_dir"/tomoauto_init."$user_shell"
export TOMOAUTOROOT="$(echo "$tomoauto_dir" | sed 's/ /\\ /g')"
lua_dir="$tomoauto_dir"/lua
lua_install="lua-5.2.3"
lfs_install="luafilesystem-1.6.2"
struct_install="struct-0.2"

case $(uname) in
    Darwin)
        platform=macosx
        ;;
    Linux)
        platform=linux
        ;;
    *)
        printf "Error: Could not configure tomoauto for $(uname)\n"
        printf "Aborting installation... Goodbye!\n\n"
        exit 1
        ;;
esac

if [ ! -w "$tomoauto_dir" ]; then
    printf "Error: You don't have write permissions for \"$tomoauto_dir\"\n"
    printf "Aborting installation... Goodbye!\n\n"
fi

set -e

tar xvJf "$lua_dir"/"$lua_install".tar.xz --directory "$lua_dir" &> /dev/null
cd "$lua_dir"/"$lua_install"
make "$platform" 2>&1 > "$lua_dir"/lua_install.log 
make install "$platform" 2>&1 >> "$lua_dir"/lua_install.log
cd -
ln -s "$tomoauto_dir"/lua/bin/lua "$tomoauto_dir"/bin/talua

tar xvJf "$lua_dir"/"$lfs_install".tar.xz --directory "$lua_dir"
cd "$lua_dir"/"$lfs_install"
awk -v platform=${platform} \
    '$0 ~ platform { sub(/#/, ""); print } \
    $0 !~ platform { print }' config > config.new
mv config config.bak && mv config.new config
make 2>&1 > "$lua_dir"/lfs_install.log
make install 2>&1 >> "$lua_dir"/lfs_install.log
cd -

tar xvJf "$lua_dir"/"$struct_install".tar.xz --directory "$lua_dir"
cd "$lua_dir"/"$struct_install"
awk -v platform=${platform} \
    '$0 ~ platform { sub(/#/, ""); print } \
    $0 !~ platform { print }' makefile > makefile.new
mv makefile makefile.bak && mv makefile.new makefile
make 2>&1 > "$lua_dir"/struct_install.log
make install 2>&1 >> "$lua_dir"/struct_install.log
cd -

if [ -f "$tomoauto_init_file" ]; then
    mv "$tomoauto_init_file" "$tomoauto_init_file".bak
fi

touch "$tomoauto_init_file"
case "$user_shell" in
    sh|bash|zsh|ksh)
        printf "export TOMOAUTOROOT=\"$tomoauto_dir\"\n" >> \
            "$tomoauto_init_file"
        printf "export PATH=\"$tomoauto_dir/bin:$PATH\"\n" >> \
            "$tomoauto_init_file"
        printf "export LUA_PATH=\"$tomoauto_dir/lib/?.lua;;\"\n" >> \
            "$tomoauto_init_file"
        printf "export LUA_CPATH=\"$tomoauto_dir/lua/lib/lua/5.2/?.so;;\"\n">> \
            "$tomoauto_init_file"
        ;;
    csh|tcsh)
        printf "setenv TOMOAUTOROOT \"$tomoauto_dir\"\n" >> \
            "$tomoauto_init_file"
        printf "setenv PATH \"$tomoauto_dir/bin:$PATH\"\n" >> \
            "$tomoauto_init_file"
        printf "setenv LUA_PATH=\"$tomoauto_dir/lib/?.lua;;\"\n" >> \
            "$tomoauto_init_file"
        printf "setenv LUA_CPATH=\"$tomoauto_dir/lua/lib/lua/5.2/?.so;;\"\n">> \
            "$tomoauto_init_file"
        ;;
esac

printf "Installation complete! "
printf "Source \"$tomoauto_init_file\" in your shell rc file if you'd like\n"
