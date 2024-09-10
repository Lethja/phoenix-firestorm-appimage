#!/bin/bash

# AI = AppImage
AI_SURI="https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
AI_CSUM="8897f478bb7b701fcd107503a08f62c4"
AI_NAME="${AI_SURI##*/}"

# FS = FireStorm
FS_SURI="$2"
FS_CSUM="$1"
FS_NAME="${FS_SURI##*/}"

# VC = Voice Chat
# 3p-slvoice from the FirestormViewer GitHub profile (commit d2977eb)
# Used to supply dated but required 32-bit libraries for SLVoice (a.k.a Vivox) to run
VC_SURI="https://github.com/FirestormViewer/3p-slvoice/archive/refs/heads/master.zip"
VC_CSUM="274aa9261b9d4b360bcf2bc8c9760cb9"
VC_NAME="3p-slvoice.zip"

download_and_verify() {
	local name="$1"
	local suri="$2"
	local csum="$3"

	if [ ! -f "$name" ]; then
		echo "Downloading $suri..."
		wget -O "$name" "$suri"
	fi

	if [ ! -f "$name.md5" ]; then
		echo "$csum  $name" > "$name.md5"
	fi

	if ! md5sum -c "$name.md5"; then
		echo "MD5 failed for $fs_name"
		exit 1
	fi
}

create_desktop_file() {
	local path="$1"
	cat << 'EOF' > "$path"
[Desktop Entry]
Name=Firestorm Viewer
Comment=Client for accessing 3D virtual worlds
Exec=firestorm
Icon=firestorm_icon
Terminal=false
Type=Application
Categories=Game;RolePlaying;Network;Chat;
StartupNotify=true
X-Desktop-File-Install-Version=3.0
StartupWMClass=do-not-directly-run-firestorm-bin
EOF
}

create_apprun_script() {
	local path="$1"
	cat << 'EOF' > "$path"
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "$0")")"
exec "$APPDIR/firestorm" "$@"
EOF

chmod +x "$path"
}

echo "Downloading and verifying content"

download_and_verify "$AI_NAME" "$AI_SURI" "$AI_CSUM"
download_and_verify "$FS_NAME" "$FS_SURI" "$FS_CSUM"
download_and_verify "$VC_NAME" "$VC_SURI" "$VC_CSUM"

# Download and verify has checked appimage against a good hash
# Can now confidently be marked as an executable
chmod +x "$AI_NAME"

echo "Extracting $FS_NAME..."

# Always work on a fresh extraction
if [ -e AppDir ]; then
	rm -R AppDir
fi

mkdir -p AppDir
tar -xf "$FS_NAME" -C AppDir --strip-components=1

echo "Extracting missing Vivox 32-bit libraries from $VC_NAME..."
unzip -qnj "$VC_NAME" "3p-slvoice-master/bin/lib32/*" -d "AppDir/lib32"

echo "Reconfiguring files in preperation for AppImage..."

# Install scripts defeat the purposes of appimages
# Could cause end-user confusion if the appimage is extracted
rm "AppDir/install.sh" "AppDir/FIRESTORM_DESKTOPINSTALL.txt"

# It's the normal way to start FireStorm but AppRun is what an AppImage will execute first
create_apprun_script "AppDir/AppRun"

# Create a modified desktop entry to work within appimage
create_desktop_file "AppDir/firestorm.desktop"

OUTPUT="${FS_NAME%%.*}-x86_64.AppImage"

# Remove Releasex64 from the AppImage name.
# Appimage standardize putting the ISA on the end of the file name
OUTPUT="${OUTPUT//-Releasex64}"

echo "Creating AppImage $OUTPUT..."

ARCH=x86_64 "./$AI_NAME" -n AppDir "$OUTPUT"

echo "Zipping $OUTPUT into ${OUTPUT%%.*}.zip..."

zip -0 "${OUTPUT%%.*}.zip" "$OUTPUT"

echo "Cleaning up..."

rm -R AppDir "$OUTPUT"

echo "$OUTPUT successfully made and stored in ${OUTPUT%%.*}.zip"
