echo 'Status: 200 OK'
echo 'Content-Type: application/json'
echo

page="$(echo "$PATH_INFO" | sed -E 's@^/api/entry/list/lifo/([0-9]+)$@\1@')"

(
    cd "$src_dir/.."
    find ./contents -mindepth 1 -maxdepth 1 -exec git log --format='%h'$'\t''{}'$'\t''{}'$'\t''%ad' \
         --date='format:%Y%m%d%H%M'$'\t''%Y/%m/%d' \{\} \; | sort -rk2 | \
        tail -n +$((page*10+1)) | head -n 10 | \
        sed -E 's@([0-9a-f]+)\t([^\t]+)\t./contents/([^\t]+)\t([0-9]+)\t([0-9/]+)@echo "$(bash '"$src_dir"'/entry_title.bash "\2")\t/entry/\3/\t\5"@e' | \
        column --separator=$'\t' --json --table-name=entry --table-columns=name,url,date
)
