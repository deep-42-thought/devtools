V=$(shell git describe --exact-match)

PREFIX = /usr/local
MANDIR = $(PREFIX)/share/man

IN_PROGS = \
	archco \
	arch-nspawn \
	archrelease \
	archbuild \
	checkpkg \
	commitpkg \
	crossrepomove\
	finddeps \
	find-libdeps \
	lddd \
	makerepropkg \
	mkarchroot \
	makechrootpkg \
	offload-build \
	rebuildpkgs \
	sogrep

BINPROGS = \
	$(IN_PROGS)

GENERATED_CONFIGFILES = \
	pacman-extra-i486.conf \
	pacman-extra-i686.conf \
	pacman-extra-pentium4.conf \
	pacman-testing-i486.conf \
	pacman-testing-i686.conf \
	pacman-testing-pentium4.conf \
	pacman-staging-i486.conf \
	pacman-staging-i686.conf \
	pacman-staging-pentium4.conf \
	pacman-staging-with-build-support-i486.conf \
	pacman-staging-with-build-support-i686.conf \
	pacman-staging-with-build-support-pentium4.conf \
	pacman-kde-unstable-i486.conf \
	pacman-kde-unstable-i686.conf \
	pacman-kde-unstable-pentium4.conf \
	pacman-gnome-unstable-i486.conf \
	pacman-gnome-unstable-i686.conf \
	pacman-gnome-unstable-pentium4.conf \
	makepkg-i486.conf \
	makepkg-i686.conf \
	makepkg-pentium4.conf

CONFIGFILES = \
	makepkg-x86_64.conf \
	pacman-extra.conf \
	pacman-testing.conf \
	pacman-staging.conf \
	pacman-multilib.conf \
	pacman-multilib-testing.conf \
	pacman-multilib-staging.conf \
	pacman-kde-unstable.conf \
	pacman-gnome-unstable.conf \
	$(GENERATED_CONFIGFILES)

SETARCH_ALIASES = \
	armv6h \
	pentium4

COMMITPKG_LINKS = \
	extrapkg \
	testingpkg \
	stagingpkg \
	communitypkg \
	community-testingpkg \
	community-stagingpkg \
	multilibpkg \
	multilib-testingpkg \
	multilib-stagingpkg \
	kde-unstablepkg \
	gnome-unstablepkg

ARCHBUILD_LINKS = \
	extra-i486-build \
	extra-i686-build \
	extra-pentium4-build \
	extra-x86_64-build \
	testing-i486-build \
	testing-i686-build \
	testing-pentium4-build \
	testing-x86_64-build \
	staging-i486-build \
	staging-i686-build \
	staging-pentium4-build \
	staging-x86_64-build \
	staging-with-build-support-i486-build \
	staging-with-build-support-i686-build \
	staging-with-build-support-pentium4-build \
	multilib-build \
	multilib-testing-build \
	multilib-staging-build \
	kde-unstable-i486-build \
	kde-unstable-i686-build \
	kde-unstable-pentium4-build \
	kde-unstable-x86_64-build \
	gnome-unstable-i486-build \
	gnome-unstable-i686-build \
	gnome-unstable-pentium4-build \
	gnome-unstable-x86_64-build

CROSSREPOMOVE_LINKS = \
	extra2community \
	community2extra

BASHCOMPLETION_LINKS = \
	archco \
	communityco


MANS = \
	doc/lddd.1 \
	doc/checkpkg.1 \
	doc/offload-build.1 \
	doc/sogrep.1 \
	doc/makerepropkg.1 \
	doc/mkarchroot.1 \
	doc/find-libdeps.1 \
	doc/find-libprovides.1


all: $(GENERATED_CONFIGFILES) $(BINPROGS) bash_completion zsh_completion man
man: $(MANS)

edit = sed -e "s|@pkgdatadir[@]|$(PREFIX)/share/devtools|g"

makepkg-i486.conf: makepkg-x86_64.conf
	@echo "GEN $@"
	@sed 's,\(["=]\)x86[-_]64\([-" ]\),\1i486\2,g' "$<" > "$@"

makepkg-i686.conf: makepkg-x86_64.conf
	@echo "GEN $@"
	@sed 's,\(["=]\)x86[-_]64\([-" ]\),\1i686\2,g' "$<" > "$@"

makepkg-pentium4.conf: makepkg-i686.conf
	@echo "GEN $@"
	@sed '/^CHOST=/ ! s,\(["=]\)i686\([-" ]\),\1pentium4\2,g' "$<" > "$@"

pacman-%-i486.conf: pacman-%.conf
	@echo "GEN $@"
	@sed " \
	s,/mirrorlist\$$,\032,; \
	/^Architecture = / s/^.*\$$/Architecture = i486/; \
	" "$<" > "$@"

pacman-%-i686.conf: pacman-%.conf
	@echo "GEN $@"
	@sed " \
	s,/mirrorlist\$$,\032,; \
	/^Architecture = / s/^.*$$/Architecture = i686/ \
	" "$<" > "$@"

pacman-%-pentium4.conf: pacman-%.conf
	@echo "GEN $@"
	@sed " \
	s,/mirrorlist\$$,\032,; \
	/^Architecture = / s/^.*$$/Architecture = pentium4/ \
	" "$<" > "$@"

%: %.in Makefile lib/common.sh
	@echo "GEN $@"
	@$(RM) "$@"
	@{ echo -n 'm4_changequote([[[,]]])'; cat $@.in; } | m4 -P | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"
	@bash -O extglob -n "$@"

$(MANS): doc/asciidoc.conf doc/footer.asciidoc

doc/%: doc/%.asciidoc
	a2x --no-xmllint --asciidoc-opts="-f doc/asciidoc.conf" -d manpage -f manpage -D doc $<

clean:
	rm -f $(GENERATED_CONFIGFILES) $(IN_PROGS) bash_completion zsh_completion $(MANS)

install:
	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -dm0755 $(DESTDIR)$(PREFIX)/share/devtools/setarch-aliases.d
	install -m0755 ${BINPROGS} $(DESTDIR)$(PREFIX)/bin
	install -m0644 ${CONFIGFILES} $(DESTDIR)$(PREFIX)/share/devtools
	for a in ${SETARCH_ALIASES}; do install -m0644 setarch-aliases.d/$$a $(DESTDIR)$(PREFIX)/share/devtools/setarch-aliases.d; done
	for l in ${COMMITPKG_LINKS}; do ln -sf commitpkg $(DESTDIR)$(PREFIX)/bin/$$l; done
	for l in ${ARCHBUILD_LINKS}; do ln -sf archbuild $(DESTDIR)$(PREFIX)/bin/$$l; done
	for l in ${CROSSREPOMOVE_LINKS}; do ln -sf crossrepomove $(DESTDIR)$(PREFIX)/bin/$$l; done
	ln -sf find-libdeps $(DESTDIR)$(PREFIX)/bin/find-libprovides
	install -Dm0644 bash_completion $(DESTDIR)/usr/share/bash-completion/completions/devtools
	for l in ${BASHCOMPLETION_LINKS}; do ln -sf devtools $(DESTDIR)/usr/share/bash-completion/completions/$$l; done
	install -Dm0644 zsh_completion $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_devtools
	ln -sf archco $(DESTDIR)$(PREFIX)/bin/communityco
	for manfile in $(MANS); do \
		install -Dm644 $$manfile -t $(DESTDIR)$(MANDIR)/man$${manfile##*.}; \
	done;

uninstall:
	for f in ${BINPROGS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${CONFIGFILES}; do rm -f $(DESTDIR)$(PREFIX)/share/devtools/$$f; done
	for f in ${SETARCH_ALIASES}; do rm -f $(DESTDIR)$(PREFIX)/share/devtools/setarch-aliases.d/$$f; done
	for l in ${COMMITPKG_LINKS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$l; done
	for l in ${ARCHBUILD_LINKS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$l; done
	for l in ${CROSSREPOMOVE_LINKS}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$l; done
	rm $(DESTDIR)/usr/share/bash-completion/completions/devtools
	rm $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_devtools
	rm -f $(DESTDIR)$(PREFIX)/bin/communityco
	rm -f $(DESTDIR)$(PREFIX)/bin/find-libprovides
	for manfile in $(MANS); do \
		rm -f $(DESTDIR)$(MANDIR)/man$${manfile##*.}/$${manfile#doc/}; \
	done;

TODAY=$(shell date +"%Y%m%d")
tag:
	@sed -E "s|^V=[0-9]{8}|V=$(TODAY)|" -i Makefile
	@git commit --gpg-sign --message "Version $(TODAY)" Makefile
	@git tag --sign --message "Version $(TODAY)" $(TODAY)

dist:
	git archive --format=tar --prefix=devtools32-$(V)/ $(V) | gzip -9 > devtools32-$(V).tar.gz
	gpg --detach-sign --use-agent devtools32-$(V).tar.gz

upload:
	scp devtools32-$(V).tar.gz devtools32-$(V).tar.gz.sig sources.archlinux32.org:sources/

check: $(BINPROGS) bash_completion makepkg-x86_64.conf PKGBUILD.proto
	shellcheck $^

.PHONY: all clean install uninstall dist upload check tag
.DELETE_ON_ERROR:
