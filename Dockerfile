# Use the official Arch Linux base image
FROM archlinux:latest

# Install required packages
RUN pacman -Sy --noconfirm \
    base-devel \
    git \
    xorg-server \
    xorg-xinit \
    xf86-video-dummy \
    tigervnc \
    && pacman -Scc --noconfirm

RUN useradd -m -G wheel builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER builder
# Install yay for AUR package management
RUN git clone https://aur.archlinux.org/yay.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm && \
    rm -rf /tmp/yay

# Install noVNC from AUR
RUN yay -S --noconfirm novnc

USER root
# Create a user to run the VNC server
RUN useradd -m vncuser && echo "vncuser:password" | chpasswd

# Set environment variables
#ENV USER=vncuser
#ENV HOME=/home/vncuser
ENV DISPLAY=:1
ENV RESOLUTION=1920x1080

RUN mkdir ~/.vnc && echo "SecurityTypes=None" > ~/.vnc/config

RUN pacman -Sy --noconfirm lxde

# Expose VNC and noVNC ports
EXPOSE 5901 6080

# Start the VNC server and noVNC
CMD ["/bin/bash", "-c", "su - $USER -c 'vncserver :1 & novnc --vnc localhost:5901 --listen 6080 :1 '"]

