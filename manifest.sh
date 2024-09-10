#!/bin/bash

declare -A manifest

# Manifest array [x, 0] = Checksum
# Manifest array [x, 1] = Tarball URL
# Manifest array [x, 2] = Bitflags, 0x1 = Vivox

manifest[0,0]="md5 46ca48b9db04d7aba8c03b98a00fbd83"
manifest[0,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-14-69596.tar.xz"
manifest[0,2]=0x1

manifest[1,0]="md5 9b0ab83c0ae1365b58fd77307dfba769"
manifest[1,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz"
manifest[1,2]=0x1

manifest[2,0]="md5 c5638069ec5ad9dee3f4e44e7e18116e"
manifest[2,1]="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-7-1-9-74745.tar.xz"
manifest[2,2]=0x1

manifest[3,0]="sha256 370fa700c4cf1ccf9e16a933d5bb056fc3adb783971aba4c238797ff0324301e"
manifest[3,1]="https://github.com/AlchemyViewer/Alchemy/releases/download/7.1.9.2501-beta/Alchemy_Beta_7_1_9_2501_x86_64.tar.xz"
manifest[3,2]=0x0 # This viewer uses WebRTC for voice chat

MAX=4 # Total number of manifest entries

# Print the options
for ((i = 0; i < MAX; i++)); do
	url="${manifest[$i,1]}"
	filename="${url##*/}"
	filename="${filename%%.*}"
	echo "$i: $filename"
done

read -p "Select a option by number: " row

if [[ $row -ge 0 && $row -lt $MAX ]]; then
	./fsAppImg.sh "${manifest[$row,0]}" "${manifest[$row,1]}" "${manifest[$row,2]}"
else
	echo "Invalid selection."
fi
