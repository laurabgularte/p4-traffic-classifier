#!/usr/bin/env python3
import argparse
from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI

class P4SingleSwitchTopo(Topo):
    def build(self):
        s1 = self.addSwitch('s1')
        h1 = self.addHost('h1', ip='10.0.0.1/24', mac='00:00:00:00:00:01')
        h2 = self.addHost('h2', ip='10.0.0.2/24', mac='00:00:00:00:00:02')
        
        self.addLink(h1, s1, port1=0, port2=1)
        self.addLink(h2, s1, port1=0, port2=2)

def run_topology(json_path):
    topo = P4SingleSwitchTopo()
    net = Mininet(topo=topo, controller=None)
    net.start()
    
    info("[*] Rede Mininet iniciada com sucesso.\n")
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    parser = argparse.ArgumentParser()
    parser.add_argument('--json', help='Compiled JSON path', required=True)
    parser.add_argument('--p4info', help='P4Info text path', required=False)
    args = parser.parse_args()
    
    run_topology(args.json)