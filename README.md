## Classificador de Tráfego de Plano de Dados Programável em P4 e Telemetria INT

Proposta de arquitetura de alta performance utilizando **P4_16** no target **BMv2 (v1model)** para classificação de tráfego em linha e telemetria contínua.

## Arquitetura

- **Count-Min Sketch em SRAM:** Contagem probabilística de bytes por fluxo (5-Tuple).
- **Classificação em Tempo Real:** Identificação de _Elephant Flows_ vs _Mice Flows_ no Ingress.
- **Injeção de INT (In-band Network Telemetry):** Injeção de metadados no Egress (Switch ID, Timestamp, Egress Queue Depth).
- **Diferenciação de Serviços (QoS):** Marcação dinâmica do campo IPv4 DSCP.
- **Control Plane Integrado:** Controller P4Runtime em Python para monitoramento.

## Estrutura do Projeto

- `p4src/`: Código fonte em P4_16 (cabeçalhos, parsers, pipeline).
- `controller/`: Controlador P4Runtime para comunicação com o Data Plane.
- `topology/`: Script de topologia Mininet com suporte a BMv2 gRPC.
- `scripts/`: Geradores de tráfego Scapy para simulação de cargas.

## Como Executar

1. **Compilar e iniciar a rede:**
   ```bash
    make run
   ```
2. **Em outro terminal, iniciar o controller**

```bash
     make controller
```

3. **Gerar tráfego para teste:**

```bash
mininet> h1 python3 scripts/send_traffic.py --dst 10.0.0.2 --count 5000
```

4. **Limpar ambiente:**

```bash
make clean
```
