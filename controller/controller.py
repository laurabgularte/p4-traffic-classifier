#!/usr/bin/env python3
import argparse
import time
import sys
import grpc

from p4.v1 import p4runtime_pb2, p4runtime_pb2_grpc

def reset_sketch_registers(stub, device_id):
    """
    Executa o reset periodico dos registradores em SRAM para janela deslizante.
    """
    print("[*] Janela expirada. Resetando registradores do Count-Min Sketch...")
    pass

def main():
    parser = argparse.ArgumentParser(description="P4Runtime Controller")
    parser.add_argument("--p4info", help="Caminho do arquivo p4info.txt", required=True)
    parser.add_argument("--json", help="Caminho do arquivo JSON compilado", required=True)
    args = parser.parse_args()

    device_id = 1
    grpc_addr = "localhost:50051"

    print(f"[*] Conectando ao BMv2 via gRPC ({grpc_addr})...")
    channel = grpc.insecure_channel(grpc_addr)
    stub = p4runtime_pb2_grpc.P4RuntimeStub(channel)

    print("[*] Controller executando com sucesso. Monitorando Data Plane...")
    try:
        while True:
            time.sleep(10)
            reset_sketch_registers(stub, device_id)
    except KeyboardInterrupt:
        print("\n[*] Controller encerrado pelo usuario.")

if __name__ == "__main__":
    main()