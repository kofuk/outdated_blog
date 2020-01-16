function diag() {
    echo "$@" >&2
}

function error_msg() {
    echo 'Status: 500 Internal server error'
    echo 'Content-Type: text/plain'
    echo
    echo "${1:-No message}"

    exit
}

function error_bad_request() {
    echo 'Status: 400 Bad request'
    echo 'Content-Type: text/html'
    echo
    cat "$src_dir/../error_pages/400.html"

    exit
}

function error_not_found() {
    echo 'Status: 404 Not found'
    echo 'Content-Type: text/html'
    echo
    cat "$src_dir/../error_pages/404.html"

    exit
}

function error_method_not_allowed() {
    echo 'Status: 405 Method not allowed'
    echo 'Content-Type: text/html'
    echo
    cat "$src_dir/../error_pages/405.html"

    exit
}
