#!/bin/bash

#https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-14-69596.tar.xz
#46ca48b9db04d7aba8c03b98a00fbd83

#https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz
#9b0ab83c0ae1365b58fd77307dfba769

# AI = AppImage
AI_SURI="https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
AI_CSUM="8897f478bb7b701fcd107503a08f62c4"
AI_NAME="${AI_SURI##*/}"

# FS = FireStorm
FS_SURI="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz"
FS_CSUM="9b0ab83c0ae1365b58fd77307dfba769"
FS_NAME="${FS_SURI##*/}"

# VC = Voice Chat
# 3p-slvoice from the FirestormViewer GitHub profile (commit d2977eb)
# Used to supply dated 32-bit binaries that don't ship with the tarball but are required for SLVoice (a.k.a Vivox) to run
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

# Install scripts defeat the purposes of appimages, removing in case it causes end-user confusion
rm "AppDir/install.sh" "AppDir/FIRESTORM_DESKTOPINSTALL.txt"

# It's the normal way to start FireStorm but AppRun is what an AppImage will execute first
echo "#!/bin/bash" > "AppDir/AppRun"
echo "APPDIR=\"$(dirname \"$(readlink -f \"\$0\")\")"
echo "exec \$APPDIR/firestorm \"\$@\"" >> "AppDir/AppRun"
chmod +x "AppDir/AppRun"

# Create a modified desktop entry to work within appimage
echo "[Desktop Entry]" > "AppDir/firestorm.desktop"
echo "Name=Firestorm Viewer" >> "AppDir/firestorm.desktop"
echo "Comment=Client for accessing 3D virtual worlds" >> "AppDir/firestorm.desktop"
echo "Exec=firestorm" >> "AppDir/firestorm.desktop"
echo "Icon=firestorm_icon" >> "AppDir/firestorm.desktop"
echo "Terminal=false" >> "AppDir/firestorm.desktop"
echo "Type=Application" >> "AppDir/firestorm.desktop"
echo "Categories=Network;" >> "AppDir/firestorm.desktop"
echo "StartupNotify=true" >> "AppDir/firestorm.desktop"
echo "X-Desktop-File-Install-Version=3.0" >> "AppDir/firestorm.desktop"
echo "StartupWMClass=do-not-directly-run-firestorm-bin" >> "AppDir/firestorm.desktop"

OUTPUT="${FS_NAME%%.*}-x86_64.AppImage"

# Remove Releasex64 from the AppImage name.
# Appimage standardize putting the ISA on the end of the file name
OUTPUT="${OUTPUT//-Releasex64}"

echo "Creating AppImage $OUTPUT..."

ARCH=x86_64 "./$AI_NAME" -n AppDir "$OUTPUT"

echo
echo "Zipping $OUTPUT into ${OUTPUT%%.*}.zip..."

zip -0 "${OUTPUT%%.*}.zip" "$OUTPUT"

echo "Cleaning up..."

rm -R AppDir "$OUTPUT"

echo "$OUTPUT successfully made and stored in ${OUTPUT%%.*}.zip"
