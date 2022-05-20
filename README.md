# wd-wireless-pro
System enhancements to WD Wireless Pro portable wifi drive

# WD MyPassport Wireless Pro (WDW for short)

I love the idea of a portable wireless drive which i can work off and provide flexible features such as file backup, storage, possibly file/movie/music streaming. The WDW provides the hardware for making this potentially possible, but the provided firmware seems limited. At least it has SSH and FTP. But i needed more. Good thing they released their build root which allows me to enhance its features so that it behaves a little better. I've been playing with this since its intial release and recently took the effort to revisit enhancing this hardware.

This repo serves as an archive for the enhacements.

## References
- https://www.westerndigital.com/en-ap/products/portable-drives/wd-my-passport-wireless-pro-hdd#WDBVPL0010BBK-NESN
- https://support-en.wd.com/app/products/product-detail/p/261#WD_downloads
- https://filebrowser.org
- https://www.dechifro.org/dcraw/
- https://github.com/monostream/tifig
- https://github.com/strukturag/libheif
- https://www.vim.org/

*Note - Licenses of the various tools belongs to the respective owners as stated by them.*

## Enhancements
The base firmware used for these enhancements is 1.04.17. The exact firmware filename is `MyPassportWirelessGen2_1.04.17.bin`.

*Note - Licenses of the various tools belongs to the respective owners as stated by them.*

## Enhancements
Enhancements made to the drive includes the building of additional binaries which is included as part of their GPL buildroot.
This includes software and libraries such as:-
- JPEG libraries
- ffmpeg
- PNG libraries
- PERL5
- xz utils
- SAMBA utils
- ImageMagick
- nmap - uses 7.8 insteadl of 6.47 (supports --script option)
- htop
- bwm-ng
- ntpd
- bc
- GIT tools
- gperf
- LUA
- tmux
- jq
- xinetd
- plus some other smaller tools that i forget...

Additions made to the drive includes:-
- dcraw - for RAW photo processing (static)
- tifig - for fast HEIC photo processing (iOS 11 and above) (static)
- libheif examples - for HEIF files process (static)
- vim - this is better than busybox vi (static) - includes vim files e.g. for syntax highlighting
- exiftool - to read file information (requires perl5)
- filebrowser - to provide a web interface to browsing files on (no app required!)

Changes in config and files in the drive includes:-
- updated list of trusted root certs so CURL or wget can work properly
- added filebrowser.service to systemctl to start on boot
- Adjusted WWW Root directory to give an option to link to WD UI or filebrowser.
- Reverse proxy to filebrowser or direct connection to filebrowser for websockets use (adjust as you see fit)
- added profile.d/enhance.sh to include new environment variables to use new binaries where required
- added config to samba to have minimum protocol version of SMB2

Recommendations to WD settings:-
- Turn on SSH and change your passport
- Disable plex and WD server scanning. You might want to edit the init.d script for their wdmcserver and exit immediately.

Once enhanced, you should have a more decent WDW drive at your disposal.

Enjoy!

# Configuration and Building

## Building based on WD provided buildroot

Based on the original WDW GPL buildroot, use the provided `config/korra_spi_defconfig` file and replace the original `defconfig` file in the `projects/korra_spi/config` folder. Back in the buildroot folder, run the build just for `korra_spi`. Upon the completion of the build, you should inspect the `output_korra_spi/build` folder. It would contain al lthe various copmiled binaries based on their provided root.

Create a deploy directory and you can `make install` specifically to the binaries that you are interested in. This will place the files into the deply directory. You can then move these files to the WDW.

```
$ ./SDKBuild korra_spi build
$ cd output_korra_spi/build
$ ls
$ mkdir ${HOME}/deploy
$ cd nmap
$ make DESTDIR=${HOME}/deploy prefix=/usr install

```
The above will install the new `nmap` into the deploy directory. Repeat for each package/tool you want to replace

*Note that i did the build on Ubuntu 12.04. Some issues might arise with the compile steps but their provided buildroot download should provide all that is basically necessary to do a basic build. Most issues encountered has more to do with outdated certificates or links to the toolchain.*

## Selecting packages based on WD buildroot

If you are interested in selecting other paackages in the WD buildroot, copy the config file into the `buildroot-GPL` directory as `.config`.you can then select the various options for the build that you are interested in. Note that some of the packages may be out of date. You would have to dig into the `Config.in` and its corresponding `*.mk` file to edit or update.

```
$ cd buildroot-GPL
$ cp projects/korra_spi/config/korra_spi_defconfig .config
$ make menuconfig
$ cp .config projects/korra_spi/config/korra_spi_defconfig
```
Once package selection is done, replace the original config file and repeat the build and install steps as above.

## Building static binaries

*I have to thank the deveoper of tifig as the static build script via docker idea made it so much easier to compile the binaries. Please check out the project using the link above. Its a v fast HEIC image processor too.*

The static builds are done on a Raspberry Pi version 1 which sports an armv7l CPU which is similar to the one in WDW. The build requires docker to ensure a pristine environment. I have had the most and simplest success using this method rather than cross compiling which can result in a mess of library requirements. So make sure you have these and docker installed. A fast internet connection is also recommended.

On the Raspberry Pi with the right tools installed:-
```
$ cd static-build
# this builds tifig with a small patch to vips
$ sudo ./compile.sh 
# the resulting tifig binary will be avialable in the io directory
# building libheif
$ sudo ./compile-heif.sh
# this builds libheif. The resulting tools will be in io/deps/libheif/examples
# you can then move the files you want to the desired location in the WDW
```

# Installation

If all the above is too hard, just use the pre-compiled files that i made and overlay them into your WDW. While i think the instuctions are pretty simple, you should have an idea of what you are trying to do.

```
$ cd install
$ scp deploy.tar.gz root@mypassport.local:/CacheVolume/
$ scp deploy.sh root@mypassport.local:/DataVolume/
$ ssh root@mypassport.local
$ cd /DataVolume
$ ./deploy.sh
#... lots of scrolling untar messages
$ reboot

```

Do know that there are no include files or man files to save space.

# Other Notes

If for some reason you want to revert to the original firmware, do the following:-
1) take an SDard formatted as FAT32
2) create a directory called "update"
3) copy the firmware you want from WD into the directory
4) put the SDcard into the WDW.
5) ensure that the WDW is OFF.
6) Press the power on button AND press and hold the SD button at the same time.
7) Release the SD button after about 10 seconds.
8) the HDD LED should start to blink after a while. This means that it is updating.
9) WAIT! until all lights stops blinking and remains stable.
10) power off and eject the SDcard. If you inspect the SDCard, it should say "UpdateDone" in the  "update" folder.

The unit should be reverted to the original firmware.

