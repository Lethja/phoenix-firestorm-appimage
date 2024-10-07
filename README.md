# Summary
SecondLife viewers can be cumbersome to install and run on Linux. 
A typical viewer will ship as a tarball and contain an installation script that may have to run as root to work.
While this script can be ignored, extracting these tarballs somewhere in your home directory
where a directory hierarchy must be maintained is also less than ideal.

This repository contains two small bash scripts that download official Linux tarball releases of several Second Life
third party viewers and converts it into an easy to use AppImage.

Using an AppImage is as easy as extracting the zip somewhere and double-clicking it.
For more information visit https://appimage.org/

# Download
Appimage builds are available on the [Releases](https://github.com/Lethja/phoenix-firestorm-appimage/releases) page.
Download and extract the zip then double-click on the extracted appimage to run

# Build yourself
## Dependencies
You will need a Linux x86_64 machine to build an appimage

On a terminal run the following to make sure scripts dependencies are installed
```shell
which md5sum sed sha256sum tar unzip wget zip > /dev/null
```
The command will exit without printing anything if all dependencies are satisfied.
If this is not the case, refer to your distribution documentation to determine what packages to install.

## Build a LTS version
Run the manifest script in a terminal
```shell
./manifest.sh
```
You should see options like this appear:
```
0: Phoenix-Firestorm-Releasex64-6-6-14-69596
1: Phoenix-Firestorm-Releasex64-6-6-17-70368
2: Phoenix-Firestorm-Releasex64-7-1-9-74745
3: Alchemy_Beta_7_1_9_2501_x86_64
4: Phoenix-Firestorm-Releasex64-7-1-10-75913
Select options by numbers separated by space or a letter: 
```
Type the number(s) for the viewer(s) you wish to make an appimage of and press enter.

The appimage will be created and stored in a zip automatically.
Storing an appimage in a zip preserved the executable permission
which will make deployment feel more streamlined to macOS and Windows users

## Build an unlisted version
Run the fsAppImg script with hash checksum string and the URL to the tarball.
Example:
```shell
./fsAppImg.sh "md5 9b0ab83c0ae1365b58fd77307dfba769" "https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz"
```