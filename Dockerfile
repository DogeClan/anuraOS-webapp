# Use the official Docker-in-Docker image
FROM docker:20.10-dind

# Set the working directory
WORKDIR /app

# Install necessary packages
RUN apk add --no-cache \
    git \
    curl \
    wget \
    make \
    clang \
    gcc \
    g++ \
    inotify-tools \
    openjdk17 \
    gnupg \
    util-linux \
    jq \
    sudo \
    nodejs \
    npm \ 
    bash \  
    python3 \ 
    py3-pip 

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && ln -s /root/.cargo/bin/rustc /usr/local/bin/ \
    && ln -s /root/.cargo/bin/cargo /usr/local/bin/

# Set the path for cargo binaries
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS /app

# Create a new user and give them sudo access
RUN adduser -D USER && echo "USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Ensure the Docker group exists and add USER to it
RUN addgroup docker || true && adduser USER docker

# Change ownership of the /app directory to the new user
RUN chown -R USER:USER /app

# Add the dind-entrypoint.sh script directly into the Dockerfile
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
# Start Docker daemon in the background\n\
dockerd &\n\
\n\
# Wait for Docker to start\n\
sleep 5\n\
\n\
# Execute the CMD command passed to the container\n\
exec "$@"' > /usr/local/bin/dind-entrypoint.sh && \
    chmod +x /usr/local/bin/dind-entrypoint.sh

# IMPORTANT: Run make all and automatically send '2' for make rootfs
RUN make all -B && (echo "2" | make rootfs V=1)

# Switch to the new user
USER USER

# Expose the Docker daemon and application port
EXPOSE 2375 8000

# Default command to run the application
CMD ["make", "server"]
