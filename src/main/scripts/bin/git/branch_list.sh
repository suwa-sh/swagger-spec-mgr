#!/bin/bash
#set -eux
#==================================================================================================
#
# ブランチ一覧取得処理
#
# 引数
#   1: コミットユーザ ※任意
#
#==================================================================================================
#--------------------------------------------------------------------------------------------------
# 環境設定
#--------------------------------------------------------------------------------------------------
# カレントディレクトリの移動
dir_script="$(dirname $0)"
cd "$(cd ${dir_script}; pwd)" || exit 1

# 共通設定
readonly DIR_BASE=$(cd ../..; pwd)
. ../setenv


#--------------------------------------------------------------------------------
# ユーティリティ読み込み
#--------------------------------------------------------------------------------
# ログ出力ユーティリティ
. "${DIR_BIN_LIB}/logging_utils.sh"
# gitユーティリティ
. "${DIR_BIN_LIB}/git_utils.sh"
# git操作バウンダリ共通処理
. "${DIR_BIN}/git/_common.sh"



#--------------------------------------------------------------------------------------------------
# 関数定義
#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# Usage
#--------------------------------------------------------------------------------
function usage() {
  echo "Usage: $(basename $0) [USER]" >&2
  exit ${EXITCODE_ERROR}
}



#--------------------------------------------------------------------------------------------------
# 事前処理
#--------------------------------------------------------------------------------------------------
raw_args="$*"
#ret_code=${EXITCODE_SUCCESS}


#--------------------------------------------------------------------------------
# オプション解析
#--------------------------------------------------------------------------------
while :; do
  case $1 in
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      usage
      ;;
    *)
      break
      ;;
  esac
done


#--------------------------------------------------------------------------------
# 引数取得
#--------------------------------------------------------------------------------
# 引数チェック
if [ $# -gt 1 ]; then
  usage
fi

# 開始ログ
log.start_script "$0" "${raw_args}"

# コミットユーザ
user="$1"



#--------------------------------------------------------------------------------------------------
# 本処理
#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# Git作業ディレクトリ取得
#--------------------------------------------------------------------------------
dir_repo="$(git.common.get_repo_dir ${user})"
if [ $? -ne ${EXITCODE_SUCCESS} ]; then
  exit ${EXITCODE_ERROR}
fi


#--------------------------------------------------------------------------------
# ブランチ一覧
#--------------------------------------------------------------------------------
git.branch_list "${dir_repo}"
ret_code=$?

if [ ${ret_code} -ne ${EXITCODE_SUCCESS} ]; then
  git.common.exit_script ${EXITCODE_ERROR} "ブランチの一覧取得 でエラーが発生しました。"
fi



#--------------------------------------------------------------------------------------------------
# 事後処理
#--------------------------------------------------------------------------------------------------
git.common.exit_script ${EXITCODE_SUCCESS} "${EXITMSG_SUCCESS}"
