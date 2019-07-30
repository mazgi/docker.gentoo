# docker.gentoo

## Build the image

_(optional)_ Download archives from a [mirror](https://www.gentoo.org/downloads/mirrors/) and place in the top of the docker build context.

```shellsession
$ wget -P Dockerfile.d/ http://ftp.jaist.ac.jp/pub/Linux/Gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20190728T214502Z.tar.xz
$ wget -P Dockerfile.d/ http://ftp.jaist.ac.jp/pub/Linux/Gentoo/snapshots/portage-latest.tar.xz
```

_(optional)_ Run the `scripts/collect.sh` script if you build the image on the Gentoo Box.  
This step helps reduce build time if you already have binary packages.

See also: [Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)

```shellsession
$ scripts/collect.sh
```

Let's build your image :whale:

```shellsession
$ docker build Dockerfile.d
```
