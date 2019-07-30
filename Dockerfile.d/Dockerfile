# ================================
# download and extract archives
# --------------------------------
FROM busybox as downloader
# Choose a mirror that is near you.
# mirror list: https://www.gentoo.org/downloads/mirrors/
ARG GENTOO_MIRROR='https://ftp.jaist.ac.jp/pub/Linux/Gentoo'
ARG GENTOO_ARCH='amd64'
WORKDIR /mnt/gentoo
# Workaround: copy archives if exist in the build context.
COPY .keep stage3-${GENTOO_ARCH}-*.tar.xz portage-latest.tar.x[z] /tmp/
# Resolve latest stage3 archive filename.
RUN wget -P /tmp/ "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/latest-stage3-${GENTOO_ARCH}.txt"
RUN grep -vE '^\s*(#|$)' /tmp/latest-stage3-${GENTOO_ARCH}.txt | awk '{print $1}' | tee /tmp/latest-stage3-${GENTOO_ARCH}-path.txt
RUN basename $(cat /tmp/latest-stage3-${GENTOO_ARCH}-path.txt) > /tmp/latest-stage3-${GENTOO_ARCH}-filename.txt
# Download and extract the stage3 archive.
RUN [[ -f /tmp/$(cat /tmp/latest-stage3-${GENTOO_ARCH}-filename.txt) ]] || wget -P /tmp/ "${GENTOO_MIRROR}/releases/${GENTOO_ARCH}/autobuilds/$(cat /tmp/latest-stage3-${GENTOO_ARCH}-path.txt)"
RUN tar xpf /tmp/$(cat /tmp/latest-stage3-${GENTOO_ARCH}-filename.txt)
# Download and extract portage repository archive.
# see also: https://wiki.gentoo.org/wiki//var/db/repos/gentoo
RUN [[ -f /tmp/portage-latest.tar.xz ]] || wget -P /tmp/ "${GENTOO_MIRROR}/snapshots/portage-latest.tar.xz"
RUN tar xf /tmp/portage-latest.tar.xz -C /tmp/ \
  && mv /tmp/portage var/db/repos/gentoo

# ================================
# install packages
# --------------------------------
FROM scratch as builder
# Set CMD for debug
CMD ["/bin/bash"]
ARG GENTOO_ARCH='amd64'
COPY --from=downloader /mnt/gentoo /
COPY ${GENTOO_ARCH} /

RUN locale-gen
# Required git for portage git repositories.
# see also: https://wiki.gentoo.org/wiki/Project:Portage/Sync
RUN emerge -uvq dev-vcs/git
# accept any return code, because rsync servers sometimes return errors.
RUN timeout 3m emerge --sync --quiet; exit 0
# basic packages
RUN emerge -uvq \
  app-admin/sudo \
  app-portage/eix
# useful packages
RUN emerge -uvq \
  app-misc/screenfetch \
  app-text/tree \
  sys-process/htop \
  sys-process/lsof
# packages for shell
RUN emerge -uvq \
  app-misc/tmux \
  app-shells/zsh
# editors and edit environment
RUN emerge -uvq \
  app-editors/vim \
  app-eselect/eselect-fontconfig \
  media-fonts/powerline-symbols
# other utilities
RUN emerge -uvq app-misc/jq
# update all installed packages
RUN emerge -uNDvq @world
# clean up
RUN rm -rf /var/db/repos/* /var/lib/portage /var/log/*

# ================================
# main: extract artifacts and reduct the image size
# --------------------------------
FROM scratch
LABEL maintainer="docker@mazgi.com"
CMD ["/bin/bash"]
COPY --from=builder / /
