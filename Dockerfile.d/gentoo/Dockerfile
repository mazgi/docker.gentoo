ARG GENTOO_ARCH='amd64'
ARG GENTOO_MIRROR

# ================================
FROM busybox as downloader

LABEL org.opencontainers.image.source="https://github.com/mazgi/dockerfiles/blob/main/Dockerfile.d/gentoo/Dockerfile"

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}
ENV GENTOO_MIRROR=${GENTOO_MIRROR:-'https://gentoo.osuosl.org/'}

WORKDIR /mnt/gentoo

COPY get-gentoo-archives.sh /tmp/
COPY working-dir /tmp/working-dir/

# Get Gentoo archives
RUN :\
  && /tmp/get-gentoo-archives.sh\
  && tar xpf /tmp/working-dir/$(cat /tmp/working-dir/latest-stage3-${GENTOO_ARCH}-filename.txt)\
  && mkdir -p var/db/repos/gentoo\
  && tar xf /tmp/working-dir/portage-latest.tar.xz -C var/db/repos/gentoo

# ================================
FROM scratch as builder

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}

# Copy extracted files
COPY --from=downloader /mnt/gentoo /
# Copy configurations
COPY rootfs.${GENTOO_ARCH} .

# Sync the gentoo repository
RUN :\
  && locale-gen\
  && emaint sync --repo gentoo\
  # Fall back
  || emerge-webrsync
# Install packages
RUN emerge -uNDvq --buildpkg --usepkg\
  app-portage/eix\
  app-portage/gentoolkit\
  app-misc/screenfetch\
  app-shells/zsh\
  app-text/tree\
  dev-vcs/git\
  net-analyzer/netcat\
  net-dns/avahi\
  sys-apps/systemd\
  sys-auth/nss-mdns\
  && :
# Sync all repositories
RUN emaint sync -a
# Clean up
RUN rm -rf\
  /var/cache/binpkgs/*\
  /var/db/repos/*\
  /var/lib/portage\
  /var/log/*

# ================================
FROM scratch
LABEL maintainer="docker@mazgi.com"
CMD ["/bin/zsh"]
COPY --from=builder / /