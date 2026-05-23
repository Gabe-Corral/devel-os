# DevelOS Packages

These PKGBUILDs package the custom sources currently kept under `install/`.

Build all local packages from the repository root:

```bash
./scripts/build-packages.sh
```

The helper creates local source tarballs next to each PKGBUILD, then runs `makepkg` in each package directory.
