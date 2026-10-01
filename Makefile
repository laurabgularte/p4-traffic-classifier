P4C = p4c-bm2-ss
P4_SRC = p4src/classifier.p4
BUILD_DIR = build
JSON_OUT = $(BUILD_DIR)/classifier.json
P4INFO_OUT = $(BUILD_DIR)/classifier.p4info.txt

.PHONY: all compile run controller clean

all: compile

compile:
	@mkdir -p $(BUILD_DIR)
	$(P4C) --p4v 16 --p4runtime-files $(P4INFO_OUT) -o $(JSON_OUT) $(P4_SRC)

run: compile
	sudo python3 topology/topology.py --json $(JSON_OUT) --p4info $(P4INFO_OUT)

controller:
	python3 controller/controller.py --p4info $(P4INFO_OUT) --json $(JSON_OUT)

clean:
	sudo mn -c
	rm -rf $(BUILD_DIR) *.log *.pcap