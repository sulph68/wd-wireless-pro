## Add-ons

The addons in this folders assumes that the additional enhancements has been deployed. Please read the README.
No promises that these addons works perfectly for you.

## Installation

Copy the files to the same directory locations under the `addons` directory.

For example:-
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

**Update:** notify now starts `inotifywait` in the background and watches a file based FIFO queue. Better handles spaces in directory names but file and directory names _should not_ contain commas ",". Will also cleanly stop `inotifywait` on termination of `notify.sh`

- rc.local

The rc.local file has been included to start notify.sh on boot. As the `DataVolume` might not be available at point of launch of `rc.local`, sleep is introduced to wait for the mount such that `notify.sh` can start properly.

- rclone

https://downloads.rclone.org/v1.58.1/rclone-v1.58.1-linux-arm-v7.zip

Download rclone from the https://rclone.org site and copy it into `/usr/local/bin`.

rclone was installed to provide a flexible way to allow the WDW to sync to various sources. It includes a web GUI with the default username and password of `admin`. 
A reverse proxy is implemented to forward https://mypassport.local/rclone to the configured port of `:8043`. Edits were made to `ifplugd.action` so that `run-parts` is executed to activate changes when wireless state is changed.
A `htpasswd` file is also setup in the `/home/root/.config` directory to store the basic auth prompt auth file. Please check the `/etc/init.d/S99rclone` script to adjust the arguments. The result of installing this is a way to be able to copy your cloud storage files and have them with you when not connected to the internet. Please see https://rclone.org for more details around setting up rclone. If installed correctly, https://mypassport.local/rclone should go to the rclone web gui.

- xinetd

xinetd configuration and a service directory included in `/etc/xinetd.conf` and `/etc/xinetd.d`/

-- vsftpd service

This allows vsftpd to always be available without having to turn it on/off. This copies the same configuration as the default vsftpd, with slight edits to make it compatible with xinetd.

- cronweb and cron

https://www.fisherinnovation.com/

Cronweb included to help cron configuration for timed jobs. `cron` also updated such that cron scripts can be layered on without being lost on reboot. This works well with rclone to sync files from remote configs into the drive.

- filebrowser

https://filebrowser.org

Slight adjustments to the configuration to include a cache directory. better performance that way

- vips

https://www.libvips.org/

Included static binaries for vips to improve speed of thumbnail generation for supported formats. `convert_raw`, `convert_heic` and `video_thumbnail` also adjustoed to use `vips` whenever possible. Will fall back on errors.

- GNU Parallel

https://www.gnu.org/software/parallel/

Static compile for GNU parallel.

- MOTD screen to display important system information upon login

```
  __  __      ___            ___         _   
 |  \/  |_  _| _ \__ _ _____| _ \___ _ _| |_ 
 | |\/| | || |  _/ _` (_-(_-|  _/ _ | '_|  _|
 |_|  |_|\_, |_| \__,_/__/__|_| \___|_|  \__|
         |__/ Wireless Drive                 

System Information:
Power : charging     | Batt: 91%        | CPUGov: ondemand      | MCUTemp: 42 deg
RootFS: 990.898MB    | Free: 238.422MB  | Used  : 685.328MB     | Percent: 74%
DiskFS: 1858.93GB    | Free: 1700.17GB  | Used  : 158.755GB     | Percent: 9%
LAN IP: xxx.xxx.xx.x | SSID: xxxxxxxxxx | WAN IP: xxx.xxx.x.xxx | Clients: 0

Device Hotspot Information:
SSID 2.4GHz                    | SSID 5GHz                    | Security Key | 
My Passport (2.4 GHz) - xxxxxx | My Passport (5 GHz) - xxxxxx | xxxxxxxx     | 

Current time is: Sat May xx xx:xx:xx SGT 20xx, Welcome!

```

- throttle_temp

Added `throttle_temp` script that provides ability to SIGSTOP whitelisted high CPU processes based on `top`. A function allows if/else determination of commands that will be allowed to stop. Prevents accidental stopping of critical processes. This also integrates and adds ability to define start up scripts in root directory without editing into rc.local all the time. Temperature limits are defined in script. Tested with sync jobs started with rclone. Works well. 
