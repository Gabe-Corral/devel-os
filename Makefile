.PHONY: iso packages packges repo qemu-live qemu help

help:
	@printf 'Targets:\n'
	@printf '  make iso        Build packages, local repo, and ISO\n'
	@printf '  make packages   Build local packages\n'
	@printf '  make repo       Create archiso local package repo\n'
	@printf '  make qemu-live  Boot ISO in QEMU, optionally ISO=path/to.iso\n'

iso:
	./scripts/build-iso.sh

packages:
	./scripts/build-packages.sh -s --noconfirm

packges: packages

repo:
	./scripts/build-repo.sh

qemu-live:
	./scripts/run-qemu.sh $(ISO)

qemu: qemu-live
