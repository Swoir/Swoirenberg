.PHONY: build
.PHONY: frameworks

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: clean build framework

clean:
	$(CWD)/Scripts/clean.sh

build:
	$(CWD)/Scripts/build.sh

framework:
	$(CWD)/Scripts/create-framework.sh
