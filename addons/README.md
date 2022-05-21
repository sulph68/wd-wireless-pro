## Add-ons

The addons in this folders assumes that the additional enhancements has been deployed. Please read the README.
No promises that these addons works perfectly for you.

## Installation

Copy the files to the same directory locations under the `addons` directory.
```
$ scp addons/usr/local/bin/* root@mypassport.local:/usr/local/bin
$ scp addons/etc/rc.local root@mypassport.local:/etc/rc.local

## Notes

- notify.sh
This is a inotifywait daemon written to watch for file additions in the `/DataVolume/Data` (source) directory.

It works in hand with `filebrowser`. As `filebrowser` by default does not preview images other than known formats like JPEG, PNG, notify.sh leverages the various RAW and HEIC tools installed to generate thumbnails for those images in JPG format.

Files are placed into the `/DataVolume/Preview` (preview) directory in the same root format structure.

Deleting a supported file in the *source* directory also automatically cleans up the file in the *preview* directory.
If a *preview* directory is empty, it will also be removed

- rc.local
The rc.local file has been included to start notify.sh on boot. As the `DataVolume` might not be available at point of launch of `rc.local`, sleep is introduced to wait for the mount such that `notify.sh` can start properly.

