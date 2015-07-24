#!/bin/bash
################################################################################
#                                                                              #
#                             install_tomoauto.sh                              #
#                                                                              #
#------------------------------------------------------------------------------#
# This shell script handles the installation of tomoauto.                      #
#------------------------------------------------------------------------------#
# AUTHOR: Dustin Morado                                                        #
# VERSION: 0.2.20                                                              #
# DATE: 12.02.2015                                                             #
################################################################################
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

printf "Hello ${USER}\n"
printf "This shell script handles the installation of tomoauto\n"
printf "======================================================\n\n"

while true
do
    printf "Where is tomoauto currently located?\n"
    printf "\t(Default: ${PWD}: "
    read tomoauto_dir_answer

    if [[ -n "${tomoauto_answer}" ]]
    then
        if [[ -d "${tomoauto_answer}" && -w "${tomoauto_answer}" ]]
        then
            tomoauto_dir="${tomoauto_answer}"
            break
        else
            printf "ERROR: ${tomoauto_answer} is not a writeable-directory!\n"
            printf "Try again or press Ctrl-C to abort the installation\n\n"
        fi
    else
        if [[ -d "${PWD}" && -w "${PWD}" ]]
        then
            tomoauto_dir="${PWD}"
            break
        else
            printf "ERROR: ${PWD} is not a writeable-directory!\n"
            printf "Try again or press Ctrl-C to abort the installation\n\n"
        fi
    fi
done

while true
do
    printf "\nInstalling tomoauto to: ${tomoauto_dir}\n\n"
    printf "Do you want to proceed with the installation? [Y/N]: "
    read user_answer

    case "$user_answer" in
        Y|y)
            printf "Proceeding...\n\n"
            break
            ;;
        N|n)
            printf "Aborting installation... Goodbye!\n\n"
            exit 0
            ;;
        *)
            printf "Error: Invalid user input.\n"
            printf "Try again or press Ctrl-C or N to abort installation\n\n"
            ;;
    esac
done

# tomoauto variables
export TOMOAUTOROOT="${tomoauto_dir}"
user_shell=$(basename ${SHELL})
tomoauto_init_file="${tomoauto_dir}/tomoauto_init.${user_shell}"

# Lua variables
lua_version="lua-5.3.0"
lua_dir="${tomoauto_dir}/external/${lua_version}"

# LFS variables
lfs_version="luafilesystem-1.6.3"
lfs_dir="${tomoauto_dir}/external/${lfs_version}"

set -e

# Lua configuration and install
cd "${lua_dir}"
awk -v tomoautoroot="${tomoauto_dir}" \
    '$0 ~ "#define LUA_ROOT" \
        { sub(/TOMOAUTOROOT/, tomoautoroot); print } \
     $0 !~ "#define LUA_ROOT" \
        { print }' \
    src/luaconf.h > src/luaconf.h.new

mv src/luaconf.h src/luaconf.h.bak && mv src/luaconf.h.new src/luaconf.h
TOMOAUTO=${tomoauto_dir} make "${platform}" 2>&1 | \
    tee "${tomoauto_dir}/lua_install.log"

TOMOAUTO=${tomoauto_dir} make "${platform}" install 2>&1 | \
    tee -a "${tomoauto_dir}/lua_install.log"

make clean
mv src/luaconf.h.bak src/luaconf.h
cd - > /dev/null 2>&1

# LFS configuration and install
cd "${lfs_dir}"
awk -v platform="${platform}" \
    '$0 ~ platform { sub(/^#/, ""); print } \
    $0 !~ platform { print }' config > config.new
mv config config.bak && mv config.new config
TOMOAUTO=${tomoauto_dir} make 2>&1 | \
    tee "${tomoauto_dir}/lfs_install.log"

TOMOAUTO=${tomoauto_dir} make install 2>&1 | \
    tee -a "${tomoauto_dir}/lfs_install.log"

make clean
mv config.bak config
cd - > /dev/null 2>&1

install -m 0755 ${tomoauto_dir}/src/bin/* ${tomoauto_dir}/bin
mkdir ${tomoauto_dir}/lib/lua/5.3/tomoauto
install -m 0644 ${tomoauto_dir}/src/lib/tomoauto/* \
  ${tomoauto_dir}/lib/lua/5.3/tomoauto

if [[ -a "${tomoauto_init_file}" ]]
then
    mv "${tomoauto_init_file}" "{$tomoauto_init_file}.bak"
fi

case "${user_shell}" in
    sh|bash|zsh|ksh)
        printf "export TOMOAUTOROOT=\"${tomoauto_dir}\"\n" > \
            "${tomoauto_init_file}"
        printf "export PATH=\"${tomoauto_dir}/bin:\${PATH}\"\n" >> \
            "${tomoauto_init_file}"
        ;;
    csh|tcsh)
        printf "setenv TOMOAUTOROOT \"$tomoauto_dir\"\n" >> \
            "$tomoauto_init_file"
        printf "setenv PATH \"$tomoauto_dir/bin:$PATH\"\n" >> \
            "$tomoauto_init_file"
        ;;
esac

printf "Installation complete\n\n"
