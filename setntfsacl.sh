#!/bin/sh

print_usage() {
	echo "Usage:	$0 <PATH>"
	echo '	Fix NTFS ACLs on all files under <PATH> to make them reaadable/writable by XBOX One/Series'
	echo '	It allows full access to files for "Authenticated Users" and "ALL APPLICATION PACKAGES" groups'
	echo '	Works for both NTFS-3G (fuse) and ntfs3 (kernel) mounts'
	echo
}

[ ! -e "$1" ] && print_usage

# magic string which was obtained by setting correct permissions in Windows and then getting an output of getfattr command
XATTR_VALUE='0sAQAEhFwAAABoAAAAAAAAABQAAAACAEgAAwAAAAATFAD/AR8AAQEAAAAAAAUSAAAAABMUAP8BHwABAQAAAAAABQsAAAAAExgA/wEfAAECAAAAAAAPAgAAAAEAAAABAQAAAAAABRIAAAABBQAAAAAABRUAAAAGsbBbubMHygak2qABAgAA'
err() {
	echo "Error: $1"
	exit 1
}
command -v getfattr >/dev/null || err "getfattr: command not found"
command -v setfattr >/dev/null || err "setfattr: command not found"

FSTYPE=$(findmnt -n -o FSTYPE --target "$1")
case "$FSTYPE" in
ntfs3)
	echo "Detected ntfs3 mount"
	XATTR_NAME="system.ntfs_security"
	;;
fuse*)
	if getfattr --name=system.ntfs_attrib "$1" >/dev/null 2>&1; then
		echo "Detected ntfs-3g mount"
		XATTR_NAME="system.ntfs_acl"
	else
		err "Filesystem at $1 is $FSTYPE, not NTFS"
	fi
	;;
*) err "Filesystem at $1 is $FSTYPE, not NTFS" ;;
esac

echo "Changing permissions for $1 recursively"
find "$1" -exec setfattr --name=${XATTR_NAME} --value="${XATTR_VALUE}" {} \; -ls
echo "All Done"
