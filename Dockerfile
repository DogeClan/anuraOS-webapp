# Use the latest Debian image
FROM debian:latest

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    openjdk-17-jdk \
    inotify-tools \
    git \
    python3 \
    python3-pip \
    sudo \
    jq \
    docker.io \
    make \
    uuid \
    uuid-runtime \
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
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the PATH for Cargo binaries
ENV PATH="/root/.cargo/bin:${PATH}"

# Create a user named USER with root access
RUN useradd -m -s /bin/bash USER && \
    echo "USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -aG docker USER

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS.git /anuraOS

# Set the working directory
WORKDIR /anuraOS

# Build the repository
RUN make all

# Command to run the server
CMD ["make", "server"]
