ARG GENTOO_ARCH='amd64'
ARG GENTOO_MIRROR

# ================================
FROM busybox as downloader

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
COPY rootfs/${GENTOO_ARCH} .

RUN locale-gen
# Sync the gentoo repository
RUN :\
  && emaint sync --repo gentoo\
  # Fall back
  || emerge-webrsync --quiet
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
  sys-auth/nss-mdns\
  && :
# Sync all repositories
RUN emaint sync --auto

# ================================
FROM scratch as reducer

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}

# Copy extracted files
COPY --from=builder / /
# Clean up
RUN rm -rf\
  /var/cache/binpkgs/*\
  /var/db/repos/*\
  /var/lib/portage\
  /var/log/*

# ================================
FROM scratch
LABEL maintainer="docker@mazgi.com"
LABEL org.opencontainers.image.source="https://github.com/mazgi/docker.gentoo/blob/main/Dockerfile.d/gentoo/Dockerfile"
CMD ["/bin/zsh"]
COPY --from=reducer / /
