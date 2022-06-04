#!/bin/bash

rootdir=$(dirname $(realpath "$0"))
classdoc='class_doctool'

declare -A outsubdirs
outsubdirs['nodes']='nodes'
outsubdirs['nodes/commands']='nodes/commands'
outsubdirs['resources']='resources'
outsubdirs['singletons']='singletons'

convert() {
    for infile in *.gd; do
        outfile="$rootdir/docs/${outsubdirs[$subdir]}/${infile%.gd}.html"
        $classdoc "$infile" > "$outfile" || rm -f "$outfile" 2> /dev/null
    done
}

convertFile() {
    local infile="$1"
    local base=$(basename "$infile")
    local outfile="$rootdir/docs/${base%.gd}.html"
    $classdoc "$infile" > "$outfile" || rm -f "$outfile" 2> /dev/null
}

# Convert named files
x=0
for arg; do
    if [[ $arg =~ .+/.+ ]]; then
        echo "is a path"
    else
        temp=$(find "$rootdir" -name $arg)
        if [ -z "$temp" ]; then
            echo "Did not find file matching pattern '$arg'" >&2
            continue
        fi
        arg="$temp"
    fi

    convertFile "$arg"
    let x++
done
echo $x

if [ $x -gt 0 ]; then
    echo 'done'
    exit
fi

# Registered classes or singletons
for subdir in nodes 'nodes/commands' singletons resources; do
    cd "$rootdir/scripts/classes/$subdir" || continue
    printf "\tlooking inside $subdir...\n"
    convert
done
