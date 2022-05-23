## Add-ons

The addons in this folders assumes that the additional enhancements has been deployed. Please read the README.
No promises that these addons works perfectly for you.

## Installation

Copy the files to the same directory locations under the `addons` directory.
```
$ scp addons/usr/local/bin/* root@mypassport.local:/usr/local/bin
$ scp addons/etc/rc.local root@mypassport.local:/etc/rc.local
```

## Notes

- notify.sh

This is a inotifywait daemon written to watch for file additions in the `/DataVolume/Data` (source) directory.

It works in hand with `filebrowser`. As `filebrowser` by default does not preview images other than known formats like JPEG, PNG, notify.sh leverages the various RAW and HEIC tools installed to generate thumbnails for those images in JPG format.

Files are placed into the `/DataVolume/Preview` (preview) directory in the same root format structure.

Deleting a supported file in the *source* directory also automatically cleans up the file in the *preview* directory.
If a *preview* directory is empty, it will also be removed

- rc.local

The rc.local file has been included to start notify.sh on boot. As the `DataVolume` might not be available at point of launch of `rc.local`, sleep is introduced to wait for the mount such that `notify.sh` can start properly.

- rclone

https://downloads.rclone.org/v1.58.1/rclone-v1.58.1-linux-arm-v7.zip

Download rclone from the https://rclone.org site and copy it into `/usr/local/bin`.

rclone was installed to provide a flexible way to allow the WDW to sync to various sources. It includes a web GUI with the default username and password of `admin`. 
A reverse proxy is implemented to forward https://mypassport.local/rclone to the configured port of `:8043`. Edits were made to `ifplugd.action` so that `run-parts` is executed to activate changes when wireless state is changed.
A `htpasswd` file is also setup in the `/home/root/.config` directory to store the basic auth prompt auth file. Please check the `/etc/init.d/S99rclone` script to adjust the arguments. The result of installing this is a way to be able to copy your cloud storage files and have them with you when not connected to the internet. Please see https://rclone.org for more details around setting up rclone.
