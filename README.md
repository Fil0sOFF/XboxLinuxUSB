## Description:

A tool to prepare a USB sticks for XBOX Dev Mode usage. Works on Linux. Alternative to [XboxMediaUSB](https://github.com/SvenGDK/XboxMediaUSB/)


So you want to create a USB drive to use it with DevMode on Xbox One/Series console, but you don't have Windows on your PC?
XBOX Homebrew can't see files you've placed on a USB stick?
Don't worry, I got you.


### Requirements:
- USB Flash drive
- Computer with Linux
- Basic terminal usage knowledge (how to run commands in terminal)

## Usage:

### Initial setup
1. Partition the USB stick, create NTFS filesystem on the first partition. `gparted` is a wonderful tool to do this. __THIS WILL DESTROY ALL DATA ON A USB DRIVE__
2. Mount it __with ntfs-3g__. `mount.ntfs-3g /dev/sdc1 /mnt`
It is important to use `ntfs-3g` for the first time, because it's impossible to set initial NTFS ACLs for the root inode when using kernel __ntfs3__ driver due to a bug. This will make Xbox apps unable to write to folders they created. You can use `ntfs3` later on.
3. Create a directory structure with `mkdirs.sh /mnt` (Optional)
3. Copy data to it
4. Fix NTFS ACLs of all files on USB stick by running the `setntfsacl.sh` script or by running a `find` command manually
5. Unmount the drive and plug in into an Xbox

### Any consecutive usage
1. Mount the flash drive with either `ntfs3` or `ntfs-3g`
2. Copy data to it
3. Fix NTFS ACLs of all files on USB stick by running the `setntfsacl.sh` script or by running a `find` command manually
4. Unmount the drive and plug in into an Xbox


## Using the script
`setntfsacl.sh` script automatically detects correct attribute name for `ntfs3`/`ntfs-3g` mounts, performs some additional checks before doing anything

`
sh setntfsacl.sh /media/MY_FLASH_DRIVE_MOUNT_POINT/
`

### Using the `find` command manually
There are 2 different attribute names depending on what driver is used (ntfs-3g vs. ntfs3). Trying to set incorrect one will just spit errors, but won't do any harm. Just run one the following `find` command:

#### for `ntfs3` kernel driver
`
find /media/MY_FLASH_DRIVE_MOUNT_POINT/ -exec setfattr --name=system.ntfs_security --value="0sAQAEhFwAAABoAAAAAAAAABQAAAACAEgAAwAAAAATFAD/AR8AAQEAAAAAAAUSAAAAABMUAP8BHwABAQAAAAAABQsAAAAAExgA/wEfAAECAAAAAAAPAgAAAAEAAAABAQAAAAAABRIAAAABBQAAAAAABRUAAAAGsbBbubMHygak2qABAgAA" {} \; -ls
`

#### for `ntfs-3g`
`
find /media/MY_FLASH_DRIVE_MOUNT_POINT/ -exec setfattr --name=system.ntfs_acl --value="0sAQAEhFwAAABoAAAAAAAAABQAAAACAEgAAwAAAAATFAD/AR8AAQEAAAAAAAUSAAAAABMUAP8BHwABAQAAAAAABQsAAAAAExgA/wEfAAECAAAAAAAPAgAAAAEAAAABAQAAAAAABRIAAAABBQAAAAAABRUAAAAGsbBbubMHygak2qABAgAA" {} \; -ls
`

## F.A.Q.

**Q**: What does this horrible `0sAQAEhFwAAABoAAAAAAAAABQAAAACAEgAAwAAAAATFAD/AR8AAQEAAAAAAAUSAAAAABMUAP8BHwABAQAAAAAABQsAAAAAExgA/wEfAAECAAAAAAAPAgAAAAEAAAABAQAAAAAABRIAAAABBQAAAAAABRUAAAAGsbBbubMHygak2qABAgAA` mean?

**A**: It's a value I got by setting a correct file permissions on Windows and then reading them on linux with `getfattr`.

**Q**: I have the following errors while tryin to mount Flash drive in Linux after it was ejected from Xbox.
```
  "Error mounting /dev/sdc1 at /media/user/128G: wrong fs type, bad option, bad superblock on /dev/sdc1, missing codepage or helper program, or other error"
```

 or dmesg has the following:

```
  ntfs3(sdc1): It is recommened to use chkdsk.
  ntfs3(sdc1): volume is dirty and "force" flag is not set!
```

**A**: Filesystem was not cleanly unmounted and ntfs3 kernel driver doesn't want to mount such filesystem. That's what "Safely Remove Hardware and Eject Media" function in Windows for. Unfortunately, there is no such function on Xbox, so the only way to do this is to __power down an Xbox completely (not sleep mode) before ejecting a USB drive__.
You may want to run `ntfsfix -d /dev/sdc1` to clear the volume dirty flag.
