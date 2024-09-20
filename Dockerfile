# Use the latest Debian image
FROM debian:latest

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    openjdk-11-jdk \
    inotify-tools \
    git \
    python3 \
    python3-pip \
    sudo \
    docker.io \
    make \
    clang \
    gcc \
    g++ \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source $HOME/.cargo/env

# Create a user named $USER with root access
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -aG docker $USER

# Set permissions for the Docker socket
RUN chmod 666 /var/run/docker.sock

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS.git /anuraOS

# Set the working directory
WORKDIR /anuraOS

# Build the repository
RUN make all

# Automate the input for make rootfs
RUN echo "2" | make rootfs

# Command to run the server
CMD ["make", "server"]
