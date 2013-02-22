#!/usr/bin/env bash
# This script installs VirtualBox guest additions in a Ubuntu guest VirtualBox. 
# It ensures the version of VirtualBox guest additions matches the VirtualBox host version.
# Thus, it (re-)intsalls VirtualBox guest additions:
# 1) If the VirtualBox guest additions are not installed, or
# 2) If the VirtualBox guest additions are installed, but their version does not match that of the VirtualBox host
# It does nothing if VirtualBox guest additions are already installed with the correct version

# CONFIGURATION OPTIONS
VBOX_HOST_VERSION=4.1.24
VBOX_ISO_URL=http://download.virtualbox.org/virtualbox/${VBOX_HOST_VERSION}/VBoxGuestAdditions_${VBOX_HOST_VERSION}.iso
DESKTOP_PACKAGE=

#--------------------------------------------------------------------
# NO MORE CONFIGURATION OPTIONS BELOW THIS POINT
#--------------------------------------------------------------------
if [ "$(modinfo vboxguest | grep -iw version | awk '{print $2}')" != $VBOX_HOST_VERSION ]
then
	# Install core dependencies for install of VirtualBox guest additions
	apt-get -y install dkms build-essential linux-headers-$(uname -r)
	
	# If necessary, install GUI dependencies for install of VirtualBox guest additions
	if [ -n "${DESKTOP_PACKAGE}" ]
	then
		# dictionaries-common is typically a dependency of desktop packages,
		# but we need to install it separately because it might not play nice
		# when installed/upgraded at the same time as other packages
		# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=621913
		apt-get -y install dictionaries-common
		apt-get -y install xserver-xorg ${DESKTOP_PACKAGE}
	fi
	
	# Download ISO of VirtualBox guest additions
	apt-get -y install curl
	vbox_iso_temp=$(mktemp)
	curl -L -o ${vbox_iso_temp} ${VBOX_ISO_URL}
	
	# Install VirtualBox guest additions
	umount /mnt || [ $? -eq 1 ]
	mount ${vbox_iso_temp} -o loop /mnt
	sh /mnt/VBoxLinuxAdditions.run
	rm ${vbox_iso_temp}
	
	# TODO: Re-mount shared folders
fi
