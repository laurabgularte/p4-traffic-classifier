# Classificador de Tráfego de Plano de Dados Programável em P4 e Telemetria INT

Proposta de arquitetura de alta performance utilizando **P4_16** no target **BMv2 (v1model)** para classificação de tráfego em linha (_in-band_) e telemetria contínua.

## 📌 Arquitetura & Recursos

- **Count-Min Sketch em SRAM:** Contagem probabilística de bytes por fluxo (5-Tuple) em registradores de hardware.
- **Classificação em Tempo Real:** Identificação de _Elephant Flows_ vs _Mice Flows_ no Ingress Pipeline.
- **Injeção de INT (In-band Network Telemetry):** Injeção de metadados no Egress (Switch ID, Timestamp, Egress Queue Depth).
- **Diferenciação de Serviços (QoS):** Marcação dinâmica do campo IPv4 DSCP para controle de filas.
- **Control Plane Integrado:** Controller P4Runtime em Python para monitoramento e redefinição periódica de janelas temporais.
- **Ambiente Containerizado:** Suporte completo via Docker e Docker Compose para execução sem instalação local da toolchain P4.
- **Integração Contínua (CI):** Validação e compilação automática do código P4 via GitHub Actions.

---

## 📁 Estrutura do Repositório

```text
p4-traffic-classifier/
├── .github/
│   └── workflows/
│       └── ci.yml             # Workflow do GitHub Actions para validação de build
├── p4src/
│   ├── headers.p4             # Definição dos cabeçalhos Ethernet, IPv4, TCP e INT
│   ├── parsers.p4             # Parser e Deparser do pipeline P4
│   └── classifier.p4          # Pipeline principal e tabelas Match-Action
├── controller/
│   └── controller.py          # Controlador P4Runtime gRPC em Python
├── topology/
│   └── topology.py            # Topologia Mininet com suporte a BMv2 gRPC
├── scripts/
│   └── send_traffic.py        # Gerador de carga/surtos de pacotes via Scapy
├── Dockerfile                 # Imagem do ambiente com p4c, BMv2 e Scapy
├── docker-compose.yml         # Configuração de orquestração do container
├── Makefile                   # Scripts de automação de compilação e execução
└── README.md
```

## 🚀 Como executar

**Pré-requisitos:** Docker e Docker Compose instalados.

**Opção 1:** Via Docker (Recomendado)

Subir o container de desenvolvimento P4:

```Bash
docker compose up -d --build

```

Acessar o container e iniciar a topologia Mininet:

```Bash
docker compose exec p4-env make run
```

Em outro terminal, iniciar o Controller P4Runtime:

```Bash
docker compose exec p4-env python3 controller/controller.py --p4info build/classifier.p4info.txt --json build/classifier.json
```

Gerar tráfego para teste (no terminal do Mininet):

```Bash
mininet> h1 python3 scripts/send_traffic.py --dst 10.0.0.2 --count 5000
```

Finalizar o ambiente:

```Bash
docker compose down
```

**Opção 2:** Execução Local (sem Docker)

**Requer p4c, simple_switch_grpc e Mininet instalados nativamente na máquina.**

```Bash
# Compilar o código P4 e iniciar o Mininet
make run

# Em outro terminal, rodar o controller
make controller

# Limpar artefatos e ambiente Mininet
make clean
```

## 🧪 Validação Contínua (CI)

O repositório conta com um pipeline automatizado no GitHub Actions (.github/workflows/ci.yml) que:

Dispara a cada push ou pull_request nas branches main/master;

Executa a compilação do código P4 no container p4lang/p4dev:latest;

Valida a ausência de erros de sintaxe ou violações no pipeline P4_16.
