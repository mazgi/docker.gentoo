ARG GENTOO_ARCH='amd64'
ARG GENTOO_MIRROR
ARG GENTOO_PROFILE="default/linux/${GENTOO_ARCH}/17.1"

# ================================
FROM alpine/git as downloader

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}
ENV GENTOO_MIRROR=${GENTOO_MIRROR:-'https://gentoo.osuosl.org/'}

WORKDIR /mnt/gentoo

COPY get-gentoo-archives.sh /tmp/
COPY working-dir /tmp/working-dir/

# Get and extract Gentoo stage3 archive
RUN :\
  && /tmp/get-gentoo-archives.sh\
  && tar xpf /tmp/working-dir/$(cat /tmp/working-dir/latest-stage3-${GENTOO_ARCH}-filename.txt)
# Clone portage repository from GitHub
RUN :\
  && mkdir -p var/db/repos/\
  && git clone --depth=1 git://github.com/gentoo-mirror/gentoo.git var/db/repos/gentoo\
  && rm -rf var/db/repos/gentoo/.git

# ================================
FROM scratch as builder

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}
ENV GENTOO_PROFILE=${GENTOO_PROFILE:-"default/linux/${GENTOO_ARCH}/17.1"}

# Copy extracted files
COPY --from=downloader /mnt/gentoo /
# Copy configurations
COPY rootfs/${GENTOO_ARCH} .
# Restore cache
COPY cache/${GENTOO_ARCH} .

RUN locale-gen
# RUN : sync the portage repository\
#   && emaint sync --repo gentoo\
#   # Fall back
#   || emerge-webrsync --quiet
RUN : set the profile\
  && eselect profile set ${GENTOO_PROFILE}
RUN : emerge packages\
  emerge -uNDvq --buildpkg --usepkg\
  app-admin/sudo\
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
# # Sync all repositories
# RUN emaint sync --auto

# ================================
FROM scratch as reducer

ENV GENTOO_ARCH=${GENTOO_ARCH:-amd64}

# Copy extracted files
COPY --from=builder / /
RUN cp -Rp /var/db/repos/gentoo/profiles /tmp/
# Clean up
RUN rm -rf\
  /var/cache/binpkgs/*\
  /var/db/repos/*\
  /var/lib/portage\
  /var/log/*
RUN mkdir -p /var/db/repos/gentoo/\
  && mv /tmp/profiles /var/db/repos/gentoo/

# ================================
FROM scratch
LABEL maintainer="docker@mazgi.com"
LABEL org.opencontainers.image.source="https://github.com/mazgi/docker.gentoo/blob/main/Dockerfile.d/gentoo/Dockerfile"
CMD ["/bin/zsh"]
COPY --from=reducer / /
