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
SYSTEM_TYPE=$(uname)
case ${SYSTEM_TYPE} in
  Darwin)
    PLATFORM=macosx
    ;;
  Linux)
    PLATFORM=linux
    ;;
  *)
    printf "Error: tomoauto is not designed for system type: ${SYSTEM_TYPE}"
    printf "\nAborting installation... Goodbye!\n\n"
    exit 1
    ;;
esac

printf "Hello ${USER}\n"
printf "This shell script handles the installation of tomoauto\n"
printf "======================================================\n\n"

printf "Where is tomoauto currently located?\n"
printf "\t(Default: ${PWD}): "
read TOMOAUTO_DIR

if [[ -z "${TOMOAUTO_DIR}" ]]
then
  TOMOAUTO_DIR="${PWD}"
fi

if [[ ! -d "${TOMOAUTO_DIR}" || ! -w "${TOMOAUTO_DIR}" ]]
  then
    printf "ERROR: ${TOMOAUTO_DIR} is not a writeable-directory!\n"
    printf "Aborting the installation... Goodbye!\n\n"
    exit 1
fi

while true
do
  printf "\nInstalling tomoauto to: ${TOMOAUTO_DIR}\n\n"
  printf "\tDo you want to proceed with the installation? [Y/N]: "
  read DO_INSTALL

  case "$DO_INSTALL" in
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
export TOMOAUTOROOT="${TOMOAUTO_DIR}"
SHELL_TYPE=$(basename ${SHELL})
TOMOAUTOINIT="${TOMOAUTOROOT}/tomoauto_init.${SHELL_TYPE}"

# Lua variables
LUA_VERSION="5.3.1"
LUA_DIR="${TOMOAUTOROOT}/external/lua-${LUA_VERSION}"

# LFS variables
LFS_VERSION="1.6.3"
LFS_DIR="${TOMOAUTOROOT}/external/luafilesystem-${LFS_VERSION}"

set -e
START_DIR="${PWD}"
# Lua configuration and install
printf "Configuring and installing Lua: Log at $TOMAUTOROOT/lua_install.log\n"
printf "======================================================\n\n"
cd "${LUA_DIR}"
awk -v tomoautoroot="${TOMOAUTOROOT}" \
  '$0 ~ "#define LUA_ROOT" \
    { sub(/TOMOAUTOROOT/, tomoautoroot); print } \
   $0 !~ "#define LUA_ROOT" \
    { print }' src/luaconf.h > src/luaconf.h.new

mv src/luaconf.h src/luaconf.h.bak && mv src/luaconf.h.new src/luaconf.h
make ${PLATFORM} 2>&1 | tee "${TOMOAUTOROOT}/lua_install.log"

if [[ ! -x src/talua || ! -x src/taluac ]]
then
  make clean &> /dev/null
  mv src/luaconf.h.bak src/luaconf.h
  cd "${START_DIR}"
  printf "ERROR: Compilation of Lua failed please see log file.\n"
  printf "Aborting installation... Goodbye!\n\n"
  exit 1
fi

make "${PLATFORM}" install 2>&1 | tee -a "${TOMOAUTOROOT}/lua_install.log"

if [[ ! -x "${TOMOAUTOROOT}/bin/talua" || ! -x "${TOMOAUTOROOT}/bin/taluac" ]]
then
  make clean &> /dev/null
  mv src/luaconf.h.bak src/luaconf.h
  cd "${START_DIR}"
  printf "ERROR: Installation of Lua failed please see log file.\n"
  printf "Aborting installation... Goodbye!\n\n"
  exit 1
fi

make clean &> /dev/null
mv src/luaconf.h.bak src/luaconf.h
cd "${START_DIR}"

# LFS configuration and install
printf "\n\n"
printf "Configuring and installing LFS: Log at $TOMAUTOROOT/lfs_install.log\n"
printf "======================================================\n\n"
cd "${LFS_DIR}"
awk -v platform="${PLATFORM}" \
  '$0 ~ platform { sub(/^#/, ""); print } \
  $0 !~ platform { print }' config > config.new

mv config config.bak && mv config.new config
make 2>&1 | tee "${TOMOAUTOROOT}/lfs_install.log"

if [[ ! -r src/lfs.so ]]
then
  make clean &> /dev/null
  mv config.bak config
  cd "${START_DIR}"
  printf "ERROR: Compilation of Luafilesystem failed please see log file.\n"
  printf "Aborting installation... Goodbye!\n\n"
  exit 1
fi

make install 2>&1 | tee -a "${TOMOAUTOROOT}/lfs_install.log"

if [[ ! -r "${TOMOAUTOROOT}/lib/lua/5.3/lfs.so" ]]
then
  make clean &> /dev/null
  mv config.bak config
  cd "${START_DIR}"
  printf "ERROR: Installation of Luafilesystem failed please see log file.\n"
  printf "Aborting installation... Goodbye!\n\n"
  exit 1
fi

make clean &> /dev/null
mv config.bak config
cd "${START_DIR}"

# tomoauto configuration and install
printf "\n\n"
printf "Configuring and installing tomoauto\n"
printf "======================================================\n\n"
install -m 0644 "${TOMOAUTOROOT}"/external/yalgo.lua \
  "${TOMOAUTOROOT}"/lib/lua/5.3/
install -m 0755 "${TOMOAUTOROOT}"/src/bin/* "${TOMOAUTOROOT}"/bin
mkdir -p "${TOMOAUTOROOT}"/lib/lua/5.3/tomoauto/settings
install -m 0644 "${TOMOAUTOROOT}"/src/lib/tomoauto/*.lua \
  "${TOMOAUTOROOT}"/lib/lua/5.3/tomoauto
install -m 0644 "${TOMOAUTOROOT}"/src/lib/tomoauto/settings/*.lua \
  "${TOMOAUTOROOT}"/lib/lua/5.3/tomoauto/settings

if [[ -a "${TOMOAUTOINIT}" ]]
then
  mv "${TOMOAUTOINIT}" "${TOMOAUTOINIT}.bak"
fi

case "${SHELL_TYPE}" in
  sh|bash|zsh|ksh)
    printf "export TOMOAUTOROOT=\"${TOMOAUTOROOT}\"\n" > "${TOMOAUTOINIT}"
    printf "export PATH=\"${TOMOAUTOROOT}/bin:\${PATH}\"\n" >> "${TOMOAUTOINIT}"
    ;;
  csh|tcsh)
    printf "setenv TOMOAUTOROOT \"$TOMOAUTOROOT\"\n" >> "$TOMOAUTOINIT"
    printf "setenv PATH \"$TOMOAUTOROOT/bin:$PATH\"\n" >> "$TOMOAUTOINIT"
    ;;
esac

printf "Installation complete\n\n"
