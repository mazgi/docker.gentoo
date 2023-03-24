FROM gentoo/portage as portage
FROM gentoo/stage3
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo
COPY rootfs /
RUN :\
  && emerge --buildpkgonly --usepkg -uvq @world\
  && :
