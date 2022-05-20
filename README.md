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

# Installation

# Other Notes

