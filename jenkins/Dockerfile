FROM jenkins/jenkins:lts

USER root

# Install basic tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 + npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.37.1/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Allow Jenkins to use Docker socket
RUN groupadd -f docker \
    && usermod -aG docker jenkins

USER jenkins