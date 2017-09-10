#!/bin/bash
#set -eux
#==================================================================================================
# loggingユーティリティ
#
# 概要
#   ${LOGLEVEL} に応じて stderr, ${PATH_LOG} にログメッセージを出力します。
#
#
# 前提
#   ・システム設定を事前に読み込んでいること
#       ・${LOGLEVEL}が事前に設定されていること
#       ・${PATH_LOG}が事前に設定されていること ※ファイル出力系を利用する場合のみ必須。
#   ・パイプモードで利用する場合、必ず 標準入力に何らかの文字列が渡されること
#       ※cat - で受けるため、cdなど、出力のないコマンドからパイプでつなぐと予期せぬ動作が起こります。
#
# 定義リスト
#   ・log.add_indent
#   ・log.remove_indent
#   ・log.clear_indent
#   ・log.save_indent
#   ・log.restore_indent
#   ・log.get_indent
#   ・log.set_indent
#
#   ・log.trace_log
#   ・log.debug_log
#   ・log.info_log
#   ・log.warn_log
#   ・log.error_log
#
#   ・log.trace_teelog
#   ・log.debug_teelog
#   ・log.info_teelog
#   ・log.warn_teelog
#   ・log.error_teelog
#
#   ・log.trace_console
#   ・log.debug_console
#   ・log.info_console
#   ・log.warn_console
#   ・log.error_console
#
#   ・log.startlog
#   ・log.endlog
#
#   ・log.rotatelog_by_day
#   ・log.rotatelog_by_day_first
#
#==================================================================================================
#--------------------------------------------------------------------------------------------------
#  プロセス単位の環境変数 ※定数ですが、複数回sourceされることを考慮して変数として定義しています。
#--------------------------------------------------------------------------------------------------
LOG__FORMAT_DATE="+%Y-%m-%d"
LOG__FORMAT_TIMESTAMP="${LOG__FORMAT_DATE} %T"
LOG__INDENT_STR="--"

#--------------------------------------------------------------------------------------------------
# 起動元スクリプト単位の環境変数
#--------------------------------------------------------------------------------------------------
# 現在インデント深度
export LOG__INDENT_COUNT
# 一時保存インデント深度ファイル数
#   ※実ファイルは、スクリプト名 + PID毎に別管理しておき、各プロセス毎の restoreするインデント震度を保持しています。
export LOG__SAVED_INDENT_FILE_COUNT




#--------------------------------------------------------------------------------------------------
# private.マスキング
#
# 概要
#    パイプで渡された文言をマスキングします。
#    マスキングの内容は、固定のロジックなので、プロジェクトに応じて書き換えが必要です。
#
# 前提
#   ・出力内容がパイプで渡されること
#     some_command 2>&1 | mask > /path/to/log
#
# 引数
#   なし
#
# 出力
#   標準出力
#
#--------------------------------------------------------------------------------------------------
function log.local.mask() {
    cat -                                                                                          |
#    sed -e "s|${PASSWORD}|PASSWORD|g"     | # パスワード
    tee
}



#--------------------------------------------------------------------------------------------------
# インデント追加
#
# 引数
#   ・1: インデント追加数 ※デフォルト:1
#
#--------------------------------------------------------------------------------------------------
function log.add_indent() {
  local _count=$1
  if [ "${_count}" = "" ]; then
    _count=1
  fi
  LOG__INDENT_COUNT=$(( LOG__INDENT_COUNT + ${_count} ))
}
#--------------------------------------------------------------------------------------------------
# インデント削除
#
# 引数
#   ・1: インデント削除数 ※デフォルト:1
#
#--------------------------------------------------------------------------------------------------
function log.remove_indent() {
  local _count=$1
  if [ "${_count}" = "" ]; then
    _count=1
  fi
  LOG__INDENT_COUNT=$(( LOG__INDENT_COUNT - ${_count} ))
}
#--------------------------------------------------------------------------------------------------
# インデントクリア
#--------------------------------------------------------------------------------------------------
function log.clear_indent() {
  LOG__INDENT_COUNT=0
}
#--------------------------------------------------------------------------------------------------
# インデント一時保存ディレクトリ ※PID毎に一意
#--------------------------------------------------------------------------------------------------
function log.local.get_stack_dir() {
  echo "/tmp/`basename $0 .sh`_$$"
}
#--------------------------------------------------------------------------------------------------
# インデント一時保存
#--------------------------------------------------------------------------------------------------
function log.save_indent() {
  # 保存数のインクリメント
  LOG__SAVED_INDENT_FILE_COUNT=$(( LOG__SAVED_INDENT_FILE_COUNT + 1 ))

  # 保存ディレクトリの存在チェック
  if [ ! -d $(log.local.get_stack_dir) ]; then
    mkdir -p $(log.local.get_stack_dir)
  fi

  # 現在インデント深度をファイル保存
  echo ${LOG__INDENT_COUNT} > $(log.local.get_stack_dir)/${LOG__SAVED_INDENT_FILE_COUNT}

  # TRACE出力
  log.local.trace.echo_saved_indent_info
}
#--------------------------------------------------------------------------------------------------
# インデントリストア
#--------------------------------------------------------------------------------------------------
function log.restore_indent() {
  # インデント深度のリストア
  LOG__INDENT_COUNT=$(cat $(log.local.get_stack_dir)/${LOG__SAVED_INDENT_FILE_COUNT})

  # 保存ファイルの削除
  rm -f $(log.local.get_stack_dir)/${LOG__SAVED_INDENT_FILE_COUNT}

  # 保存ファイル数のデクリメント
  LOG__SAVED_INDENT_FILE_COUNT=$(( LOG__SAVED_INDENT_FILE_COUNT - 1 ))

  # ディレクトリ毎のファイル数確認
  local _file_count="$(ls $(log.local.get_stack_dir) | wc -l)"
  if [ ${_file_count} -le 0 ]; then
    # 0以下の場合、保存ディレクトリ削除
    rm -fr $(log.local.get_stack_dir)
  fi

  # TRACE出力
  log.local.trace.echo_saved_indent_info
}
function log.local.trace.echo_saved_indent_info() {
  if [ "${LOGLEVEL}" != "${LOGLEVEL_TRACE}" ]; then
    return ${EXITCODE_SUCCESS}
  fi

#  local _stack_dir=$(log.local.get_stack_dir)
#  log.trace_console "-------------------------------------------------- TRACE-START --------------------------------------------------"
#  log.trace_console "- INVOKER                       : ${FUNCNAME[1]}"
#  log.trace_console "  - STACK_DIR                   : ${_stack_dir}"
#  log.trace_console "  - ls                          : $(test -d ${_stack_dir} && ls -l ${_stack_dir})"
#  log.trace_console "  - LOG__SAVED_INDENT_FILE_COUNT: ${LOG__SAVED_INDENT_FILE_COUNT}"
#  log.trace_console "  - LOG__INDENT_COUNT           : ${LOG__INDENT_COUNT}"
#  log.trace_console "-------------------------------------------------- TRACE-END   --------------------------------------------------"
}

#--------------------------------------------------------------------------------------------------
# インデント取得
#--------------------------------------------------------------------------------------------------
function log.get_indent() {
  echo "${LOG__INDENT_COUNT}"
}
#--------------------------------------------------------------------------------------------------
# インデント設定
#
# 引数
#   ・1: インデント数
#
#--------------------------------------------------------------------------------------------------
function log.set_indent() {
  local _count=$1
  if [ "${_count}" = "" ]; then
    log.clear_indent
    log.error_teelog "${FUNCNAME[0]}: インデント数が指定されていません。処理を見なおして下さい。呼び出し元:${FUNCNAME[1]}"
    exit ${EXITCODE_ERROR}
  fi
  LOG__INDENT_COUNT=${_count}
}



#--------------------------------------------------------------------------------------------------
# private.ログ標準出力
#
# 概要
#   ログフォーマットに従って、引数の文言を標準出力します。
#   標準出力されるのはマスキングされた結果です。
#
# 前提
#   ・なし
#
# 引数
#   ・1  : ログレベル
#   ・2〜: ログ出力文言
#
# 出力
#   標準出力
#
#--------------------------------------------------------------------------------------------------
function log.local.format() {
    local _log_level="$1"
    local _timestamp=$(date "${LOG__FORMAT_TIMESTAMP}")
    shift
    local _msg="$@"

    echo "${_msg}"                                                                                  |
    #-----------------------------------------------------------------------------------------------
    # レイアウト
    # TIMESTAMP LOG_LEVEL INDENT MESSAGE
    #-----------------------------------------------------------------------------------------------
    awk                                                                                             \
        -v _timestamp="${_timestamp}"                                                               \
        -v _log_level="${_log_level}"                                                               \
        -v LOG__INDENT_STR="${LOG__INDENT_STR}"                                                     \
        -v LOG__INDENT_COUNT=${LOG__INDENT_COUNT}                                                   \
        '
      {
        # 「TIMESTAMP LOG_LEVEL」の出力
        printf _timestamp" "_log_level

        # 「 INDENT」の出力
        for (i = 0; i < LOG__INDENT_COUNT; i++) {
          if ( i == 0) {
            printf " "
          }
          printf LOG__INDENT_STR
        }

        # 「MESSAGE + 改行」の出力
        print " "$0
      }
    '                                                                                               |
    log.local.mask
}



#--------------------------------------------------------------------------------------------------
# private.ログファイルチェック
#
# 概要
#   出力するログファイルの存在チェック、初期化処理です。
#
# 前提
#   ・PATH_LOG が定義されていること
#
# 引数
#   ・なし
#
# 出力
#   PATH_LOG ※空ファイル
#
#--------------------------------------------------------------------------------------------------
function log.local.check_file() {
    # 環境変数チェック
    if [ "${PATH_LOG}" = "" ]; then
        log.local.format "${LOGLEVEL_ERROR}" "ログファイルパス：PATH_LOG が設定されていません。" 1>&2
        return ${EXITCODE_ERROR}
    fi

    # ファイル存在チェック
    if [ ! -f "${PATH_LOG}" ]; then
        local _dir_log=$(dirname "${PATH_LOG}")
        if [ ! -d "${_dir_log}" ]; then
            mkdir -p "${_dir_log}"
            local _ret_code=$?
            if [ ${_ret_code} -ne ${EXITCODE_SUCCESS} ]; then
                log.local.format "${LOGLEVEL_ERROR}" "ログ出力ディレクトリが作成できません。対象：${_dir_log}" 1>&2
                return ${EXITCODE_ERROR}
            fi
        fi
        touch "${PATH_LOG}"
    fi

    return ${EXITCODE_SUCCESS}
}



#--------------------------------------------------------------------------------------------------
# private.ログ出力要否チェック
#
# 概要
#   引数のログレベルが、出力が必要か否かを判定します。
#
# 前提
#   ・LOGLEVEL が定義されていること
#
# 引数
#   ・1: 判定対象のログレベル
#
# 出力
#   なし
#
# 戻り値
#   出力が必要な場合: 0
#   出力が不要な場合: 3
#   判定できない場合: 6
#
#--------------------------------------------------------------------------------------------------
function log.local.is_write() {
    local _trg_log_lebel="$1"

    #----------------------------------------------------------------------------------------------
    # 前提チェック
    #----------------------------------------------------------------------------------------------
    # ログレベル
    if [ "${LOGLEVEL}" = "" ]; then
        log.local.format "${LOGLEVEL_ERROR}" "出力ログレベル：LOGLEVEL が設定されていません。" 1>&2
        return ${EXITCODE_ERROR}
    fi

    #----------------------------------------------------------------------------------------------
    # 引数チェック
    #----------------------------------------------------------------------------------------------
    if [    "${_trg_log_lebel}" != "${LOGLEVEL_TRACE}" \
         -a "${_trg_log_lebel}" != "${LOGLEVEL_DEBUG}" \
         -a "${_trg_log_lebel}" != "${LOGLEVEL_INFO}"  \
         -a "${_trg_log_lebel}" != "${LOGLEVEL_WARN}"  \
         -a "${_trg_log_lebel}" != "${LOGLEVEL_ERROR}" \
       ]; then
        log.local.format "${LOGLEVEL_ERROR}" "ログレベル：「${_trg_log_lebel}」は想定外の値です。" 1>&2
        return ${EXITCODE_ERROR}
    fi

    if [ "${LOGLEVEL}" = "${LOGLEVEL_DEBUG}" ]; then
        # DEBUG以上のログレベルを出力
        if [ "${_trg_log_lebel}" = "${LOGLEVEL_TRACE}" ]; then
            return ${EXITCODE_WARN}
        fi

    elif [ "${LOGLEVEL}" = "${LOGLEVEL_INFO}" ]; then
        # INFO以上のログレベルを出力
        if [    "${_trg_log_lebel}" = "${LOGLEVEL_TRACE}" \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_DEBUG}" \
           ]; then
            return ${EXITCODE_WARN}
        fi

    elif [ "${LOGLEVEL}" = "${LOGLEVEL_WARN}" ]; then
        # WARN以上のログレベルを出力
        if [    "${_trg_log_lebel}" = "${LOGLEVEL_TRACE}" \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_DEBUG}" \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_INFO}"  \
           ]; then
            return ${EXITCODE_WARN}
        fi

    elif [ "${LOGLEVEL}" = "${LOGLEVEL_ERROR}" ]; then
        # ERROR以上のログレベルを出力
        if [    "${_trg_log_lebel}" = "${LOGLEVEL_TRACE}" \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_DEBUG}" \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_INFO}"  \
             -o "${_trg_log_lebel}" = "${LOGLEVEL_WARN}"  \
           ]; then
            return ${EXITCODE_WARN}
        fi
    fi

    return ${EXITCODE_SUCCESS}
}



#--------------------------------------------------------------------------------------------------
# private.ログファイル出力
#
# 概要
#   引数の文言 or パイプ経由の標準入力 を、ファイルにログフォーマットで出力します。
#
# 前提
#   ・LOGLEVEL が定義されていること
#   ・PATH_LOG が定義されていること
#
# 引数
#   ・1  : 出力ログレベル
#   ・2〜: 出力文言 ※パイプの場合は不要
#
# 出力
#   ${PATH_LOG}
#
# 戻り値
#   出力に成功した場合: 0
#   出力に失敗した場合: 6
#
#--------------------------------------------------------------------------------------------------
function log.local.log() {
    local _trg_log_level="$1"

    #----------------------------------------------------------------------------------------------
    # ファイルチェック
    #----------------------------------------------------------------------------------------------
    log.local.check_file
    local _ret_code=$?
    if [ ${_ret_code} -ne ${EXITCODE_SUCCESS} ]; then
        return ${EXITCODE_ERROR}
    fi

    #----------------------------------------------------------------------------------------------
    # 出力判定
    #----------------------------------------------------------------------------------------------
    log.local.is_write "${_trg_log_level}"
    _ret_code=$?
    if [ ${_ret_code} -eq ${EXITCODE_WARN} ]; then
        # 出力が不要な場合、ここで終了
        return ${EXITCODE_SUCCESS}
    elif [ ${_ret_code} -eq ${EXITCODE_ERROR} ]; then
        # 判定できない場合、エラー終了
        return ${EXITCODE_ERROR}
    fi

    #----------------------------------------------------------------------------------------------
    # パイプ判断
    #----------------------------------------------------------------------------------------------
    if [ -p /dev/stdin ]; then
        # パイプの場合
        local _before_IFS=$IFS
        IFS=$'\n'
        for _cur_row in $(cat -); do
            log.local.format "${_trg_log_level}" "${_cur_row}"                                       >> ${PATH_LOG}
        done
        IFS=${_before_IFS}

    else
        # 引数指定の場合
        shift
        log.local.format "${_trg_log_level}" "$@"                                                    >> ${PATH_LOG}
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# traceログ ファイル出力
#--------------------------------------------------------------------------------------------------
function log.trace_log() {
    local _trg_log_level="${LOGLEVEL_TRACE}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.log "${_trg_log_level}"
    else
        log.local.log "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# debugログ ファイル出力
#--------------------------------------------------------------------------------------------------
function log.debug_log() {
    local _trg_log_level="${LOGLEVEL_DEBUG}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.log "${_trg_log_level}"
    else
        log.local.log "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# infoログ ファイル出力
#--------------------------------------------------------------------------------------------------
function log.info_log() {
    local _trg_log_level="${LOGLEVEL_INFO}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.log "${_trg_log_level}"
    else
        log.local.log "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# warnログ ファイル出力
#--------------------------------------------------------------------------------------------------
function log.warn_log() {
    local _trg_log_level="${LOGLEVEL_WARN}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.log "${_trg_log_level}"
    else
        log.local.log "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# errorログ ファイル出力
#--------------------------------------------------------------------------------------------------
function log.error_log() {
    local _trg_log_level="${LOGLEVEL_ERROR}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.log "${_trg_log_level}"
    else
        log.local.log "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}



#--------------------------------------------------------------------------------------------------
# private.ログコンソール＆ファイル出力
#
# 概要
#   引数の文言 or パイプ経由の標準入力 を、コンソール＆ファイルにログフォーマットで出力します。
#
# 前提
#   ・LOGLEVEL が定義されていること
#   ・PATH_LOG が定義されていること
#
# 引数
#   ・1  : 出力ログレベル
#   ・2〜: 出力文言 ※パイプの場合は不要
#
# 出力
#   標準出力/標準エラー
#   ${PATH_LOG}
#
# 戻り値
#   出力に成功した場合: 0
#   出力に失敗した場合: 6
#
#--------------------------------------------------------------------------------------------------
function log.local.tee() {
    local _trg_log_level="$1"

    #----------------------------------------------------------------------------------------------
    # ファイルチェック
    #----------------------------------------------------------------------------------------------
    log.local.check_file
    local _ret_code=$?
    if [ ${_ret_code} -eq ${EXITCODE_WARN} ]; then
        # 出力が不要な場合、ここで終了
        return ${EXITCODE_SUCCESS}
    elif [ ${_ret_code} -eq ${EXITCODE_ERROR} ]; then
        # 判定できない場合、エラー終了
        return ${EXITCODE_ERROR}
    fi

    #----------------------------------------------------------------------------------------------
    # 出力判定
    #----------------------------------------------------------------------------------------------
    log.local.is_write "${_trg_log_level}"
    _ret_code=$?
    if [ ${_ret_code} -ne ${EXITCODE_SUCCESS} ]; then
        # 出力が不要な場合、ここで終了
        return ${EXITCODE_SUCCESS}
    fi

    #----------------------------------------------------------------------------------------------
    # パイプ判断
    #----------------------------------------------------------------------------------------------
    if [ -p /dev/stdin ]; then
        # パイプの場合
        local _before_IFS=$IFS
        IFS=$'\n'
        for _cur_row in $(cat -); do
            log.local.format "${_trg_log_level}" "${_cur_row}"                                     |
            tee -a ${PATH_LOG} 1>&2
        done
        IFS=${_before_IFS}

    else
        # 引数指定の場合
        shift
        log.local.format "${_trg_log_level}" "$@"                                                  |
        tee -a ${PATH_LOG} 1>&2
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# traceログ コンソール＆ファイル出力
#--------------------------------------------------------------------------------------------------
function log.trace_teelog() {
    local _trg_log_level="${LOGLEVEL_TRACE}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.tee "${_trg_log_level}"
    else
        log.local.tee "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# debugログ コンソール＆ファイル出力
#--------------------------------------------------------------------------------------------------
function log.debug_teelog() {
    local _trg_log_level="${LOGLEVEL_DEBUG}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.tee "${_trg_log_level}"
    else
        log.local.tee "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# infoログ コンソール＆ファイル出力
#--------------------------------------------------------------------------------------------------
function log.info_teelog() {
    local _trg_log_level="${LOGLEVEL_INFO}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.tee "${_trg_log_level}"
    else
        log.local.tee "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# warnログ コンソール＆ファイル出力
#--------------------------------------------------------------------------------------------------
function log.warn_teelog() {
    local _trg_log_level="${LOGLEVEL_WARN}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.tee "${_trg_log_level}"
    else
        log.local.tee "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# errorログ コンソール＆ファイル出力
#--------------------------------------------------------------------------------------------------
function log.error_teelog() {
    local _trg_log_level="${LOGLEVEL_ERROR}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.tee "${_trg_log_level}"
    else
        log.local.tee "${_trg_log_level}" "$@"
    fi

    return ${EXITCODE_SUCCESS}
}






#--------------------------------------------------------------------------------------------------
# private.ログコンソール出力
#
# 概要
#   引数の文言 or パイプ経由の標準入力 を、コンソールにログフォーマットで出力します。
#
# 前提
#   ・LOGLEVEL が定義されていること
#   ・PATH_LOG が定義されていること
#
# 引数
#   ・1  : 出力ログレベル
#   ・2〜: 出力文言 ※パイプの場合は不要
#
# 出力
#   標準出力/標準エラー
#
# 戻り値
#   出力に成功した場合: 0
#   出力に失敗した場合: 6
#
#--------------------------------------------------------------------------------------------------
function log.local.console() {
    local _trg_log_level="$1"

    #----------------------------------------------------------------------------------------------
    # 出力判定
    #----------------------------------------------------------------------------------------------
    log.local.is_write "${_trg_log_level}"
    local _ret_code=$?
    if [ ${_ret_code} -eq ${EXITCODE_WARN} ]; then
        # 出力が不要な場合、ここで終了
        return ${EXITCODE_SUCCESS}
    elif [ ${_ret_code} -eq ${EXITCODE_ERROR} ]; then
        # 判定できない場合、エラー終了
        return ${EXITCODE_ERROR}
    fi

    #----------------------------------------------------------------------------------------------
    # パイプ判断
    #----------------------------------------------------------------------------------------------
    if [ -p /dev/stdin ]; then
        # パイプの場合
        local _before_IFS=$IFS
        IFS=$'\n'
        for _cur_row in $(cat -); do
            log.local.format "${_trg_log_level}" "${_cur_row}" 1>&2
        done
        IFS=${_before_IFS}

    else
        # 引数指定の場合
        shift
        log.local.format "${_trg_log_level}" "$@" 1>&2
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# traceログ コンソール出力
#--------------------------------------------------------------------------------------------------
function log.trace_console() {
    local _trg_log_level="${LOGLEVEL_TRACE}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.console "${_trg_log_level}"
    else
        local _before_IFS=$IFS
        IFS=" $'\n'$'\t'"
        log.local.console "${_trg_log_level}" "$@"
        IFS=${_before_IFS}
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# debugログ コンソール出力
#--------------------------------------------------------------------------------------------------
function log.debug_console() {
    local _trg_log_level="${LOGLEVEL_DEBUG}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.console "${_trg_log_level}"
    else
        local _before_IFS=$IFS
        IFS=" $'\n'$'\t'"
        log.local.console "${_trg_log_level}" "$@"
        IFS=${_before_IFS}
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# infoログ コンソール出力
#--------------------------------------------------------------------------------------------------
function log.info_console() {
    local _trg_log_level="${LOGLEVEL_INFO}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.console "${_trg_log_level}"
    else
        local _before_IFS=$IFS
        IFS=" $'\n'$'\t'"
        log.local.console "${_trg_log_level}" "$@"
        IFS=${_before_IFS}
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# warnログ コンソール出力
#--------------------------------------------------------------------------------------------------
function log.warn_console() {
    local _trg_log_level="${LOGLEVEL_WARN}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.console "${_trg_log_level}"
    else
        local _before_IFS=$IFS
        IFS=" $'\n'$'\t'"
        log.local.console "${_trg_log_level}" "$@"
        IFS=${_before_IFS}
    fi

    return ${EXITCODE_SUCCESS}
}
#--------------------------------------------------------------------------------------------------
# errorログ コンソール出力
#--------------------------------------------------------------------------------------------------
function log.error_console() {
    local _trg_log_level="${LOGLEVEL_ERROR}"

    if [ -p /dev/stdin ]; then
        cat - | log.local.console "${_trg_log_level}"
    else
        local _before_IFS=$IFS
        IFS=" $'\n'$'\t'"
        log.local.console "${_trg_log_level}" "$@"
        IFS=${_before_IFS}
    fi

    return ${EXITCODE_SUCCESS}
}



#--------------------------------------------------------------------------------------------------
# 処理開始ログ出力
#
# 引数
#   ・1　: 実行スクリプトのパス ※$0を想定
#   ・2〜: 補足情報 ※引数リスト $@ などを想定
#
# 出力
#   ${PATH_LOG}
#--------------------------------------------------------------------------------------------------
function log.startlog() {
    log.log.info_teelog "START $@"
    return $?
}



#--------------------------------------------------------------------------------------------------
# 処理終了ログ出力
#
# 引数
#   ・1　: 実行スクリプトのパス ※$0を想定
#   ・2〜: 補足情報 ※引数リスト $@ などを想定
#
# 出力
#   ${PATH_LOG}
#--------------------------------------------------------------------------------------------------
function log.endlog() {
    log.log.info_teelog "END   $@"
    return $?
}



#--------------------------------------------------------------------------------------------------
# 概要
#   ログローテーション（日次）
#
# 引数
#   なし
#
# 出力
#   ${PATH_LOG}.${日付}
#
#--------------------------------------------------------------------------------------------------
function log.rotatelog_by_day() {
    #----------------------------------------------------------------------------------------------
    # 事前処理
    #----------------------------------------------------------------------------------------------
    # ログファイルチェック
    log.local.check_file
    local _ret_code=$?
    if [ ${_ret_code} -ne ${EXITCODE_SUCCESS} ]; then
        return ${_ret_code}
    fi

    #----------------------------------------------------------------------------------------------
    # 本処理
    #----------------------------------------------------------------------------------------------
    # 当日
    local _cur_date=`date ${LOG__FORMAT_DATE}`

    # 最終行の日付
    local _last_date=`cat ${PATH_LOG} | grep "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} " | tail -n 1 | cut -d " " -f 1`

    # 最終行の日付が当日と一致するか確認
    if [ "${_last_date}" != "${_cur_date}" ]; then

        # 一致しない場合、ローテーション
        local _path_output=${PATH_LOG}.`echo ${_last_date} | sed -e 's|/||g'`

        # ローテーション先ファイルが存在する場合、現在時刻でリネーム
        if [ -f ${_path_output} ]; then
            mv ${_path_output} ${_path_output}.`date '+%Y%m%d%H%M%S'`
        fi

        # コピー
        cp -p ${PATH_LOG} ${_path_output}
        if [ $? -ne 0 ]; then
            log.local.format "${LOGLEVEL_ERROR}" "ログローテーション（日次）に失敗しました。${PATH_LOG} を "`basename ${_path_output}`" にコピーできません。" 1>&2
            return ${EXITCODE_ERROR}
        fi

        # 本体を空に置き換え
        cp /dev/null ${PATH_LOG}
        if [ $? -ne 0 ]; then
            log.local.format "${LOGLEVEL_ERROR}" "ログローテーション（日次）に失敗しました。${PATH_LOG} を 空ファイル に置き換えできません。" 1>&2
            return ${EXITCODE_ERROR}
        fi
    fi

    #----------------------------------------------------------------------------------------------
    # 事後処理
    #----------------------------------------------------------------------------------------------
    return ${EXITCODE_SUCCESS}
}



#--------------------------------------------------------------------------------------------------
# 概要
#   ログローテーション（日次） ※先頭行で判断
#
# 引数
#   なし
#
# 出力
#   ${PATH_LOG}.${日付}
#
#--------------------------------------------------------------------------------------------------
function log.rotatelog_by_day_first() {
    #----------------------------------------------------------------------------------------------
    # 事前処理
    #----------------------------------------------------------------------------------------------
    # ログファイルチェック
    log.local.check_file
    local _ret_code=$?
    if [ ${_ret_code} -ne ${EXITCODE_SUCCESS} ]; then
        return ${_ret_code}
    fi

    #----------------------------------------------------------------------------------------------
    # 本処理
    #----------------------------------------------------------------------------------------------
    # 当日
    local _cur_date=`date ${LOG__FORMAT_DATE}`

    # 先頭行の日付
    local _first_date=`cat ${PATH_LOG} | grep "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} " | head -n 1 | cut -d " " -f 1`

    # 先頭行の日付が当日と一致するか確認
    if [ "${_first_date}" != "${_cur_date}" ]; then

        # 一致しない場合、ローテーション
        local _path_output=${PATH_LOG}.`echo ${_first_date} | sed -e 's|/||g'`

        # ローテーション先ファイルが存在する場合、現在時刻でリネーム
        if [ -f ${_path_output} ]; then
            mv ${_path_output} ${_path_output}.`date '+%Y%m%d%H%M%S'`
        fi

        # コピー
        cp -p ${PATH_LOG} ${_path_output}
        if [ $? -ne 0 ]; then
            log.local.format "${LOGLEVEL_ERROR}" "ログローテーション（日次）に失敗しました。${PATH_LOG} を "`basename ${_path_output}`" にコピーできません。" 1>&2
            return ${EXITCODE_ERROR}
        fi

        # 本体を空に置き換え
        cp /dev/null ${PATH_LOG}
        if [ $? -ne 0 ]; then
            log.local.format "${LOGLEVEL_ERROR}" "ログローテーション（日次）に失敗しました。${PATH_LOG} を 空ファイル に置き換えできません。" 1>&2
            return ${EXITCODE_ERROR}
        fi
    fi

    #----------------------------------------------------------------------------------------------
    # 事後処理
    #----------------------------------------------------------------------------------------------
    return ${EXITCODE_SUCCESS}
}
