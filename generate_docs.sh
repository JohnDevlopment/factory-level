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

# Registered classes or singletons
for subdir in nodes 'nodes/commands' singletons resources; do
    cd "$rootdir/scripts/classes/$subdir" || continue
    printf "\tlooking inside $subdir...\n"
    #$classdoc Actor.gd > /dev/null

    #for infile in *.gd; do
    #    outfile="$rootdir/docs/${outsubdirs[$subdir]}/${infile%.gd}.html"
    #    $classdoc "$infile" > "$outfile" || rm "$outfile" 2> /dev/null
    #done

    convert
done

# Autoloads under scenes/
#cd "$rootdir/scenes/autoloads"
#for infile in *.gd; do
#    outfile="$rootdir/docs/singletons/${infile%.gd}.html"
#    $classdoc "$infile" > "$outfile" || rm "$outfile" 2> /dev/null
#done

# Other documented nodes
#cd "$rootdir"
#exec 3<docs.txt

#while read -u 3 infile; do
#    temp=$(basename "$infile")
#    outfile="$rootdir/docs/other/${temp%.gd}.html"; unset temp
#    $classdoc "$infile" > "$outfile" || rm "$outfile" 2> /dev/null
#done

#exec 3<&-
