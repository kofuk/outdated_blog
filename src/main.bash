#!/usr/bin/env bash
set -eu
set -o pipefail
shopt -s extglob

function serve_file() {
    if [ -z "${1:-}" ]; then
        error_msg 'Internal server error'
    fi

    local file_path="$(realpath "$src_dir/$1")"
    if ! echo "$file_path" | grep "^$(realpath "$src_dir/../assets")" &>/dev/null && \
            ! echo "$file_path" | grep "^$(realpath "$src_dir/../static_pages")" &>/dev/null || \
            [ ! -e "$file_path" ]; then
        error_not_found
    fi

    echo 'Status: 200 OK'

    echo -n 'Content-Type: '
    local ext="$(echo "$file_path" | sed -E 's/^.+\.([^./ ]+)$/\1/')"
    cat "$src_dir/../third_party/mime.types" | grep -v '#' | \
        awk '{for(i=2;i<=NF;++i)print $i,$1}' | \
        awk '$1=="'$ext'"{print $2}'

    echo

    cat "$file_path"
}

function redirect() {
    echo 'Status: 301 Moved permanently'
    echo "Location: ${1:-}"
    echo 'Content-Type: text/plain'
    echo
    echo "The document has been moved."
}

readonly src_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"

source "$src_dir/error.bash"

if echo "${SERVER_SOFTWARE:-}" | grep -F 'Python' &>/dev/null; then
    _base_path='/cgi-bin/main.bash'
else
    _base_path=''
fi

if [ "${REQUEST_METHOD:-}" != 'GET' ]; then
    error_method_not_allowed
fi

if [ -z "${PATH_INFO:-}" ]; then
    PATH_INFO="$(echo "$REQUEST_URI" | sed -E 's@^(.*)\?.*$@\1@')"
fi

case "$PATH_INFO" in
    '/' | '')
        serve_file '../static_pages/index.html'
        ;;
    '/entry')
        redirect "$_base_path/entry/"
        ;;
    '/entry/')
        serve_file '../static_pages/entry_list.html'
        ;;
    /entry/+([a-zA-Z0-9-]))
        redirect "$PATH_INFO/"
        ;;
    /entry/+([a-zA-Z0-9-])/)
        source "$src_dir/entry.bash"
        ;;
    /entry/*)
        error_not_found
        ;;
    /api/entry/list/lifo/+([0-9]))
        source "$src_dir/entry_list_lifo.bash"
        ;;
    /api/*)
        error_not_found
        ;;
    /assets/*)
        serve_file "../$PATH_INFO"
        ;;
    /favicon.ico)
        serve_file '../assets/favicon.ico'
        ;;
    *)
        serve_file "misc/$PATH_INFO"
        ;;
esac
