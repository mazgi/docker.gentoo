# FROM ghcr.io/mazgi/gentoo-binhost as cache
FROM gentoo/portage as portage
FROM gentoo/stage3 as builder
# COPY --from=cache /var/cache/distfiles /var/cache/distfiles
# COPY --from=cache /var/cache/binpkgs /var/cache/binpkgs
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo
COPY rootfs /

RUN :\
  && eselect news read all\
  && tar cf /tmp/portage-settings.tar.gz --no-same-owner --no-same-permissions /etc/portage\
  && emerge --buildpkgonly --usepkg -uvq @world\
  && :

FROM nginx:alpine as binhost
ARG GIT_SHORT_SHA
COPY --from=builder /tmp/portage-settings.tar.gz /usr/share/nginx/html
COPY --from=builder /var/cache/binpkgs /usr/share/nginx/html/var/cache/binpkgs
