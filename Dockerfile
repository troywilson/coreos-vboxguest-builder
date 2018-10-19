ARG COREOS_VERSION=1855.4.0
ARG VBOX_VERSION=5.2.18

FROM bugroger/coreos-developer:${COREOS_VERSION}

ARG COREOS_VERSION
ARG VBOX_VERSION

# We need to prepare the Container Linux Developer image. As described at
# https://coreos.com/os/docs/latest/kernel-modules.html we need to get source
# packages and prepare the linux source tree.
#
# In Docker the `/proc` filesystem does not work as expected, so a bit more magic
# is required.
RUN emerge-gitclone
RUN . /usr/share/coreos/release && \
    git -C /var/lib/portage/coreos-overlay checkout build-${COREOS_RELEASE_VERSION%%.*}
RUN emerge -gKv coreos-sources > /dev/null
RUN cp /usr/lib64/modules/$(ls /usr/lib64/modules)/build/.config /usr/src/linux/
RUN make -C /usr/src/linux modules_prepare

# Workaround for SEG FAULT during sys-devel/autoconf build (copied from lorenz/torcx-zfs)
# https://github.com/coreos/bugs/issues/2369
COPY perl-fwrapv-fix.patch /
RUN patch $(equery w dev-lang/perl) perl-fwrapv-fix.patch
RUN emerge --nodep -e dev-lang/perl > /dev/null

# Install extra packages
RUN emerge app-cdr/cdrtools > /dev/null

# Download, extract and move the vboxguest driver (it won't build in /tmp)
WORKDIR /tmp
RUN curl -L http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso -o vboxguest.iso
RUN isoinfo -i vboxguest.iso -x "/VBOXLINUXADDITIONS.RUN;1" > VBoxLinuxAdditions.run
RUN chmod +x VBoxLinuxAdditions.run
RUN mv VBoxLinuxAdditions.run /build

# Build vboxguest driver (based on YungSang/coreos-vboxguest)
WORKDIR /build
RUN sh ./VBoxLinuxAdditions.run --noexec --target .
RUN mkdir vboxguest && tar -C vboxguest -xjf VBoxGuestAdditions-amd64.tar.bz2
RUN KERN_DIR=/usr/src/linux KERN_VER=`readlink /usr/src/linux | cut -d - -f2,3` make -C /build/vboxguest/src/vboxguest-${VBOX_VERSION} all

# Prepare release
RUN mkdir /dist
RUN echo ${VBOX_VERSION} > /build/vboxguest/version.txt
RUN tar czf /dist/vboxguest.tar.gz vboxguest
