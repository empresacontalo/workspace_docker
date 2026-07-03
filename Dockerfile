FROM debian:bookworm-slim

# Evitar prompts interativos durante a instalação do apt
ENV DEBIAN_FRONTEND=noninteractive

# Atualizar pacotes e instalar dependências básicas, XFCE e XRDP
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    curl \
    wget \
    git \
    ca-certificates \
    build-essential \
    xrdp \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar o ambiente do XFCE para o XRDP
RUN echo "xfce4-session" > /etc/skel/.xsession

# Instalar Node.js e NPM (necessário para a maioria das ferramentas)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Adicionar permissão global de instalação para npm (se necessário)
RUN mkdir -p /usr/local/lib/node_modules && \
    chown -R root:root /usr/local/lib/node_modules

# Copiar scripts de instalação e entrypoint
COPY install-tools.sh /usr/local/bin/install-tools.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Dar permissão de execução
RUN chmod +x /usr/local/bin/install-tools.sh /usr/local/bin/entrypoint.sh

# Executar a instalação das ferramentas via NPM
RUN /usr/local/bin/install-tools.sh

# Expor a porta padrão do RDP
EXPOSE 3389

# Entrypoint para gerenciar os serviços e o usuário
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
