# CoreOS VirtualBox Guest Additions Builder

[![Build Status](https://travis-ci.org/troywilson/coreos-vboxguest-builder.svg?branch=master)](https://travis-ci.org/troywilson/coreos-vboxguest-builder)


This repository automatically builds VirtualBox Guest Additions for each CoreOS Container Linux release.

The CoreOS build environment is based on the docker container: [bugroger/coreos-developer](https://github.com/BugRoger/coreos-developer-docker) and the build is heavily influenced by [BugRoger/coreos-nvidia-driver](https://github.com/BugRoger/coreos-nvidia-driver) and [YungSang/coreos-vboxguest](https://github.com/YungSang/coreos-vboxguest/).

Nightly Travis builds are performed against CoreOS stable, beta and alpha channels and the ouput is pushed as a release to this repository with a tag matching the CoreOS version.

See: [troywilson/coreos-vboxguest](https://github.com/troywilson/coreos-vboxguest) for example usage of the releases.
