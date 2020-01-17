cache_dir="/tmp/blogcache-$(whoami)"
if [ ! -d "$cache_dir" ]; then
    mkdir -p "$cache_dir" || error_msg 'Internal server error'
fi

entry_name="$(echo "$REQUEST_URI" | sed -E 's@^/entry/([a-zA-Z0-9-]+)/$@\1@')"

src_file="$src_dir/../contents/$entry_name"

if [ "$entry_name" = 'template' ] || \
       [ "$entry_name" = 'misc' ] || \
       [ ! -d "$src_file" ]; then
    error_not_found
fi

echo 'Status: 200 OK'
echo 'Content-Type: text/html'
echo

# if post.org exist, use the org as input (for compatibility.)
if [ -e "$src_file/post.org" ]; then
    use_org_doc=yes
    files=( "$src_file/post.org" )
else
    use_org_doc=
    files=( $(find "$src_file" -name '*.md' | sort -V) )
fi

rev="$(git log -n 1 --pretty=format:%h -- "${files[@]}")"
if [ -z "$rev" ]; then
    rev="T$(echo "${files[@]}" | tr ' ' \\n | xargs -n 1 date +%s -r | sort -nr | head -n 1)"
fi
cache_name="$cache_dir/$entry_name@$rev"

if [ ! -e "$cache_name#source" ]; then
    if [ "$use_org_doc" = 'yes' ]; then
        cat -- "${files[@]}" | grep -v '^#+TITLE:' | grep -v '^#+DATE:' > "$cache_name#source"
    else
        cat -- "${files[@]}" > "$cache_name#source"
    fi
fi

if [ ! -e "$cache_name#metadata" ]; then
    (
        # Use sponge(1) to avoid to die from grep(1)'s broken pipe.
        if [ "$use_org_doc" = 'yes' ]; then
            cat "${files[@]}" | grep -F '#+TITLE:' | sponge | head -n 1 | sed -E 's@^#\+TITLE:(.+)$@\1@' | awk 1
        else
            cat "$cache_name#source" | head -n 1 | tr -d '#' | awk 1
        fi

        cat "$cache_name#source" | grep -vF '#' | grep -vF '`' | grep -o . | sponge | head -n 100 | \
            tr -d \\n | sed 's/"/\&quot/g' | awk 1
    )> "$cache_name#metadata"
fi

if [ ! -e "$cache_name#content" ]; then
    if [ "$use_org_doc" = 'yes' ]; then
        pandoc --data-dir="$src_dir/.." --template="post.html" \
               -f org -t html5 \
               -M title:"$(cat "$cache_name#metadata" | head -n 1)" \
               "$cache_name#source" > "$cache_name#content"
    else
        pandoc --data-dir="$src_dir/.." --template="post.html" \
               -f markdown -t html5 \
               -M title:"$(cat "$cache_name#metadata" | head -n 1)" \
               "$cache_name#source" > "$cache_name#content"
    fi
fi

cat "$cache_name#content"
