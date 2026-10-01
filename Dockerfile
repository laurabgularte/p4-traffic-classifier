FROM p4lang/p4dev:latest

# Instala utilitários de rede e dependências Python necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    net-tools \
    tcpdump \
    iperf3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Dependências Python para Scapy e comunicação gRPC com P4Runtime
RUN pip3 install --no-cache-dir \
    scapy \
    grpcio \
    protobuf \
    p4runtime

WORKDIR /app

# Mantém o container ativo
CMD ["/bin/bash"]