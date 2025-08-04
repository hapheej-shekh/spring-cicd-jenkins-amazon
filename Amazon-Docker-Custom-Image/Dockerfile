FROM jenkins/jenkins:lts

USER root

# --------------------
# 🧰 SYSTEM TOOLS
# --------------------
RUN apt-get update && \
    apt-get install -y \
        sudo \
        curl \
        unzip \
		zip \
        git \
        gnupg2 \
        lsb-release \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        maven && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# 🐳 DOCKER CLI (latest)
# --------------------
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# 🔧 AWS CLI v2
# --------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && \
    rm -rf awscliv2.zip aws && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# ☁️ AZURE CLI
# --------------------
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------
# ☸️ KUBECTL (Kubernetes CLI)
# --------------------
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# --------------------
# ⚓ HELM
# --------------------
RUN apt-get update && apt-get install -y bash && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove unnecessary locales / docs / manpages
RUN rm -rf /usr/share/doc && \
    rm -rf /usr/share/man && \
    rm -rf /usr/share/locale && \
    rm -rf /var/cache/*
	
# --------------------
# 🔑 JENKINS DOCKER ACCESS
# --------------------
RUN usermod -aG docker jenkins

# --------------------
# ✅ SET DEFAULT BACK TO JENKINS
# --------------------
USER jenkins
