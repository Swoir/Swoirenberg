.PHONY: build
.PHONY: frameworks

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: build framework

build:
	$(CWD)/Scripts/build.sh

framework:
	$(CWD)/Scripts/create-framework.sh
