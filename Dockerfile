FROM debian:latest

# Set the working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    make \
    clang \
    gcc \
    inotify-tools \
    openjdk-17-jdk \
    gnupg2 \
    uuid-runtime \
    jq \
    lsb-release \
    sudo \
    docker.io \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set the path for cargo binaries and make it persistent
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS /app

# Add the new user and make sure they have sudo access
RUN useradd -m USER && echo "USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add USER to the Docker group
RUN usermod -aG docker USER

# Change ownership of the /app directory to the new user
RUN chown -R USER:USER /app

# Run 'make all' without user input, and 'make rootfs' with input "2"
RUN make all && \
    expect -c ' \
    spawn make rootfs; \
    expect "Choose an option"; \
    send "2\r"; \
    expect eof;'

# Switch to the new user
USER USER

# Expose the application port
EXPOSE 8000

# Default command to run the application
CMD ["make", "server"]
