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
lua_dir="${tomoauto_dir}/${lua_version}"
lua_archive="${lua_dir}.tar.bz2"

# LFS variables
lfs_version="luafilesystem-1.6.3"
lfs_dir="${tomoauto_dir}/${lfs_version}"
lfs_archive="${lfs_dir}.tar.bz2"

set -e

# Lua configuration and install
if [[ -d "${lua_dir}" ]]
then
    rm -rf "${lua_dir}"
fi
tar -xjf "${lua_archive}" --directory "${tomoauto_dir}"
cd "${lua_dir}"
awk -v tomoautoroot="${TOMOAUTOROOT}" \
    '$0 ~ "#define LUA_ROOT" { sub(/TOMOAUTOROOT/, tomoautoroot); print } \
    $0 !~ "#define LUA_ROOT" { print }' src/luaconf.h > src/luaconf.h.new
mv src/luaconf.h src/luaconf.h.bak && mv src/luaconf.h.new src/luaconf.h
make "${platform}" 2>&1 | tee "${tomoauto_dir}/lua_install.log"
make "${platform}" install 2>&1 | tee -a "${tomoauto_dir}/lua_install.log"
mv "${tomoauto_dir}/bin/lua" "${tomoauto_dir}/bin/talua"
mv "${tomoauto_dir}/bin/luac" "${tomoauto_dir}/bin/taluac"
cd - > /dev/null 2>&1
rm -rf "${lua_dir}"

# LFS configuration and install
if [ -d "${lfs_dir}" ]
then
    rm -rf "${lfs_dir}"
fi
tar -xjf "${lfs_archive}" --directory "${tomoauto_dir}"
cd "${lfs_dir}"
awk -v platform="${platform}" \
    '$0 ~ platform { sub(/^#/, ""); print } \
    $0 !~ platform { print }' config > config.new
mv config config.bak && mv config.new config
make 2>&1 | tee "${tomoauto_dir}/lfs_install.log"
make install 2>&1 | tee -a "${tomoauto_dir}/lfs_install.log"
cd - > /dev/null 2>&1
rm -rf "${lfs_dir}"

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
