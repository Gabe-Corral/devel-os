FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso base-devel git sudo && \
    pacman -Scc --noconfirm

WORKDIR /workspace
