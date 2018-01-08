#!/bin/bash
#set -eux
#===================================================================================================
#
# CI Event - PullRequest Created
#
#===================================================================================================
#---------------------------------------------------------------------------------------------------
# env
#---------------------------------------------------------------------------------------------------
dir_script="$(dirname $0)"
cd "$(cd ${dir_script}; cd ../..; pwd)" || exit 1

readonly DIR_BASE="$(pwd)"
. "${DIR_BASE}/build/env.properties"
. "${DIR_BUILD_LIB}/common.sh"


#---------------------------------------------------------------------------------------------------
# main
#---------------------------------------------------------------------------------------------------
echo "$(basename $0)"

echo ""
${DIR_BUILD}/product/build.sh
exit_on_fail "product/build" $?


#---------------------------------------------------------------------------------------------------
# teardown
#---------------------------------------------------------------------------------------------------
echo ""
echo "$(basename $0) success."
exit 0
