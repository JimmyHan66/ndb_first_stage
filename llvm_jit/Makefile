# TPC-H JIT System Makefile

CC = /usr/bin/clang
CFLAGS = -std=c11 -O2 -Wall -Wextra
INCLUDES = -I../include -I. -I/opt/homebrew/include
LIBS = -L../build -L/opt/homebrew/lib -lndb_scan_filter -larrow -lparquet -ldl
LDFLAGS =

# Main target
all: tpch_jit_test

# Generate LLVM IR for all queries
ir:
	@echo "Generating LLVM IR for all queries..."
	cd q1 && ./generate_ir.sh && cd ..
	cd q6 && ./generate_ir.sh && cd ..

# Build main test executable
tpch_jit_test: tpch_jit_test.c common/tpch_jit_driver.c ir
	@echo "Building TPC-H JIT test..."
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ tpch_jit_test.c common/tpch_jit_driver.c $(LIBS)
	@echo "✅ Build complete!"

# Test targets
test-q1: tpch_jit_test
	@echo "Running Q1 JIT test..."
	DYLD_LIBRARY_PATH=../build:$$DYLD_LIBRARY_PATH ./tpch_jit_test q1

test-q6: tpch_jit_test
	@echo "Running Q6 JIT test..."
	DYLD_LIBRARY_PATH=../build:$$DYLD_LIBRARY_PATH ./tpch_jit_test q6

test: test-q1 test-q6

# Clean targets
clean:
	rm -f tpch_jit_test
	rm -f /tmp/jit_lib_*.dylib

clean-ir:
	rm -f common/*.ll q1/*.ll q6/*.ll

clean-all: clean clean-ir

# Help target
help:
	@echo "TPC-H JIT System Build Targets:"
	@echo "  all         - Build main test executable"
	@echo "  ir          - Generate LLVM IR for all queries"
	@echo "  test-q1     - Run Q1 JIT test"
	@echo "  test-q6     - Run Q6 JIT test"
	@echo "  test        - Run all JIT tests"
	@echo "  clean       - Clean executables"
	@echo "  clean-ir    - Clean generated IR files"
	@echo "  clean-all   - Clean everything"

.PHONY: all ir test-q1 test-q6 test clean clean-ir clean-all help
