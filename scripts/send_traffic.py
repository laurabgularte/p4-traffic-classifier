#!/usr/bin/env python3
import argparse
from scapy.all import IP, TCP, sendp, get_if_hwaddr, get_if_list

def get_interface():
    interfaces = get_if_list()
    for iface in interfaces:
        if "eth0" in iface:
            return iface
    return "eth0"

def generate_traffic(dst_ip, count):
    iface = get_interface()
    print(f"[*] Enviando {count} pacotes TCP via {iface} para {dst_ip}...")
    
    for i in range(count):
        pkt = (
            IP(dst=dst_ip) / 
            TCP(sport=12345, dport=80) / 
            ("X" * 1000)
        )
        sendp(pkt, iface=iface, verbose=False)
        if i % 500 == 0 and i > 0:
            print(f" -> {i}/{count} pacotes enviados...")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dst", help="IP destino", default="10.0.0.2")
    parser.add_argument("--count", help="Quantidade de pacotes", type=int, default=1000)
    args = parser.parse_args()
    
    generate_traffic(args.dst, args.count)