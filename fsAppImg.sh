#!/bin/bash

# AI = AppImage
AI_SURI="https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
AI_CSUM="md5 8897f478bb7b701fcd107503a08f62c4"
AI_NAME="${AI_SURI##*/}"

# SL = SecondLife Viewer
SL_SURI="$2"
SL_CSUM="$1"
SL_NAME="${SL_SURI##*/}"

# VC = Voice Chat
# 3p-slvoice from the FirestormViewer GitHub profile (commit d2977eb)
# Used to supply dated but required 32-bit libraries for SLVoice (a.k.a Vivox) to run
VC_SURI="https://github.com/FirestormViewer/3p-slvoice/archive/refs/heads/master.zip"
VC_CSUM="md5 274aa9261b9d4b360bcf2bc8c9760cb9"
VC_NAME="3p-slvoice.zip"

download_and_verify() {
	local name="$1"
	local suri="$2"

	if [ ! -f "$name" ]; then
		echo "Downloading $suri..."
		wget -O "$name" "$suri"
	fi

	local array=()

	# Split the hash type from the checksum
	for element in $3; do
		array+=("$element")
	done

	if [ ! -f "$name.${array[0]}" ]; then
		echo "${array[1]}  $name" > "$name.${array[0]}"
	fi

	if ! "${array[0]}sum" -c "$name.${array[0]}"; then
		echo "Checksum failed for $SL_name"
		exit 1
	fi
}

create_desktop_file() {
	cat << EOF > "$1"
[Desktop Entry]
Name=${2^} Viewer
Comment=Client for accessing 3D virtual worlds
Exec=${2}
Icon=${2}_icon
Terminal=false
Type=Application
Categories=Game;RolePlaying;Network;Chat;
StartupNotify=true
X-Desktop-File-Install-Version=3.0
StartupWMClass=do-not-directly-run-${2}-bin
EOF
}

create_apprun_script() {
	cat << EOF > "$1"
#!/bin/bash
APPDIR="\$(dirname "\$(readlink -f "\$0")")"
exec "\$APPDIR/$2" "\$@"
EOF

	chmod +x "$1"
}

echo "Downloading and verifying content"

download_and_verify "$AI_NAME" "$AI_SURI" "$AI_CSUM"
download_and_verify "$SL_NAME" "$SL_SURI" "$SL_CSUM"

if (($3 & 0x1)); then
	download_and_verify "$VC_NAME" "$VC_SURI" "$VC_CSUM"
fi

# Download and verify has checked appimage against a good hash
# Can now confidently be marked as an executable
chmod +x "$AI_NAME"

echo "Extracting $SL_NAME..."

# Always work on a fresh extraction
if [ -e "AppDir" ]; then
	rm -R "AppDir"
fi

mkdir -p AppDir
tar -xf "$SL_NAME" -C AppDir --strip-components=1

if (($3 & 0x1)); then
echo "Extracting missing Vivox 32-bit libraries from $VC_NAME..."
unzip -qnj "$VC_NAME" "3p-slvoice-master/bin/lib32/*" -d "AppDir/lib32"
fi

echo "Reconfiguring files in preperation for AppImage..."

# Install scripts defeat the purposes of appimages
# Could cause end-user confusion if the appimage is extracted
if [ -e "AppDir/install.sh" ]; then rm "AppDir/install.sh"; fi
if [ -e "AppDir/FIRESTORM_DESKTOPINSTALL.txt" ]; then rm "AppDir/FIRESTORM_DESKTOPINSTALL.txt"; fi

# Get the viewer name we're working with
if [ -f "AppDir/alchemy" ]; then
	BIN="alchemy"
elif [ -f "AppDir/firestorm" ]; then
	BIN="firestorm"
else
	echo "Unknown viewer, can't continue"
	exit 1
fi


# It's the normal way to start FireStorm but AppRun is what an AppImage will execute first
create_apprun_script "AppDir/AppRun" "${BIN}"

# Create a modified desktop entry to work within appimage
create_desktop_file "AppDir/${BIN}.desktop" "${BIN}"

OUTPUT="${SL_NAME%%.*}-x86_64.AppImage"

# Remove Releasex64 from the AppImage name.
# Appimage standardize putting the ISA on the end of the file name
OUTPUT="${OUTPUT//-Releasex64}"
OUTPUT="${OUTPUT//_x86_64}"

echo "Creating AppImage $OUTPUT..."

ARCH=x86_64 "./$AI_NAME" -n AppDir "$OUTPUT"

echo "Zipping $OUTPUT into ${OUTPUT}.zip..."

zip -0 "${OUTPUT}.zip" "$OUTPUT"

echo "Cleaning up..."

rm -R AppDir "$OUTPUT"

echo "$OUTPUT successfully made and stored in ${OUTPUT%%.*}.zip"
