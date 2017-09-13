#!/bin/bash
#==================================================================================================
#
# git操作バウンダリ共通処理
#
#==================================================================================================
#--------------------------------------------------------------------------------------------------
# 関数定義
#--------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# 終了処理
#
# 引数
#   1: EXIT CODE
#   2: メッセージ
#------------------------------------------------------------------------------
function git.common.exit_script() {
  local _exit_code=$1
  local _exit_msg=$2

  # 終了ログ
  log.end_script "$0" "${_exit_code}" "${_exit_msg}"

  # ログローテーション（日次） ※先頭行判断
  log.rotatelog_by_day_first

  # 終了
  exit ${_exit_code}
}



#--------------------------------------------------------------------------------
# リポジトリディレクトリ取得
#
# 引数
#   1: コミットユーザ
#--------------------------------------------------------------------------------
function git.common.get_repo_dir() {
  local _user="$1"
  if [ "${_user}x" = "x" ]; then
    _user="${SCM_DEFAULT_USER}"
  fi

  local _repo_dir="${DIR_DATA}/${_user}/repo"
  echo "${_repo_dir}"
  return ${EXITCODE_SUCCESS}
}
