#!/bin/bash

declare -A manifest

# Manifest array [x, 0] = MD5 checksum
# Manifest array [x, 1] = Tarball URL

manifest[0,0]="46ca48b9db04d7aba8c03b98a00fbd83"
manifest[0,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-14-69596.tar.xz"

manifest[1,0]="9b0ab83c0ae1365b58fd77307dfba769"
manifest[1,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz"

manifest[2,0]="c5638069ec5ad9dee3f4e44e7e18116e"
manifest[2,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-7-1-9-74745.tar.xz"

MAX=3 # Total number of manifest entries

# Print the options
for ((i = 0; i < MAX; i++)); do
    url="${manifest[$i,1]}"
    filename="${url##*/}"
    filename="${filename%%.*}"
    echo "$i: $filename"
done

read -p "Select a option by number: " row

if [[ $row -ge 0 && $row -lt $MAX ]]; then
	./fsAppImg.sh "${manifest[$row,0]}" "${manifest[$row,1]}"
else
	echo "Invalid selection."
fi
