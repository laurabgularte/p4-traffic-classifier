#include <core.p4>
#include <v1model.p4>

#include "headers.p4"
#include "parsers.p4"

#define SKETCH_DEPTH 1024
#define ELEPHANT_THRESHOLD 500000 // Limiar de 500KB acumulados

control c_ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {

    register<bit<32>>(SKETCH_DEPTH) sketch_bank_0;
    register<bit<32>>(SKETCH_DEPTH) sketch_bank_1;

    action drop_packet() {
        mark_to_drop(std_meta);
    }

    action ipv4_forward(bit<9> port) {
        std_meta.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table t_forwarding {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop_packet;
        }
        size = 512;
        default_action = drop_packet();
    }

    action process_sketch() {
        hash(meta.flow_hash_1, HashAlgorithm.crc32, (bit<32>)0, {
            hdr.ipv4.srcAddr,
            hdr.ipv4.dstAddr,
            hdr.ipv4.protocol,
            hdr.tcp.srcPort,
            hdr.tcp.dstPort
        }, (bit<32>)SKETCH_DEPTH);

        hash(meta.flow_hash_2, HashAlgorithm.csum16, (bit<32>)0, {
            hdr.ipv4.srcAddr,
            hdr.ipv4.dstAddr,
            hdr.ipv4.protocol,
            hdr.tcp.srcPort,
            hdr.tcp.dstPort
        }, (bit<32>)SKETCH_DEPTH);

        bit<32> count1;
        bit<32> count2;

        sketch_bank_0.read(count1, meta.flow_hash_1);
        sketch_bank_1.read(count2, meta.flow_hash_2);

        bit<32> new_count1 = count1 + (bit<32>)std_meta.packet_length;
        bit<32> new_count2 = count2 + (bit<32>)std_meta.packet_length;

        sketch_bank_0.write(meta.flow_hash_1, new_count1);
        sketch_bank_1.write(meta.flow_hash_2, new_count2);

        if (new_count1 > ELEPHANT_THRESHOLD && new_count2 > ELEPHANT_THRESHOLD) {
            meta.is_heavy_hitter = 1;
            hdr.ipv4.diffserv = 8; // Rebaixa prioridade para DSCP CS1
        } else {
            meta.is_heavy_hitter = 0;
        }
    }

    apply {
        if (hdr.ipv4.isValid()) {
            if (hdr.tcp.isValid()) {
                process_sketch();
            }
            t_forwarding.apply();
        }
    }
}

control c_egress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    apply {
        if (hdr.ipv4.isValid()) {
            hdr.int_hdr.setValid();
            hdr.int_hdr.switch_id = 1;
            hdr.int_hdr.ingress_timestamp = (bit<32>)std_meta.ingress_global_timestamp;
            hdr.int_hdr.egress_queue_depth = (bit<19>)std_meta.enq_qdepth;
            hdr.int_hdr.flow_category = (bit<8>)meta.is_heavy_hitter;
        }
    }
}

control c_checksum_verify(inout headers hdr, inout metadata meta) {
    apply {}
}

control c_checksum_update(inout headers hdr, inout metadata meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            {
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.totalLen,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragOffset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr
            },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
    }
}

V1Switch(
    TopParser(),
    c_checksum_verify(),
    c_ingress(),
    c_egress(),
    c_checksum_update(),
    TopDeparser()
) main;