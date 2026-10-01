#ifndef _HEADERS_P4_
#define _HEADERS_P4_

typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgPtr;
}

// In-band Network Telemetry (INT) Header
header int_header_t {
    bit<8>  switch_id;
    bit<32> ingress_timestamp;
    bit<19> egress_queue_depth;
    bit<8>  flow_category; // 0 = Mouse Flow, 1 = Elephant Flow
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    tcp_t        tcp;
    int_header_t int_hdr;
}

struct metadata {
    bit<32> flow_hash_1;
    bit<32> flow_hash_2;
    bit<1>  is_heavy_hitter;
}

#endif