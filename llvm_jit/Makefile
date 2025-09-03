# TPC-H JIT Benchmark System Makefile

CC = /usr/bin/clang
CFLAGS = -std=c11 -O2 -Wall -Wextra
INCLUDES = -I../include -I. -I/opt/homebrew/include
LIBS = -L../build -L/opt/homebrew/lib -lndb_scan_filter -larrow -lparquet -ldl
LDFLAGS =

# 主要目标
all: benchmark_framework

# 生成所有 LLVM IR
ir:
	@echo "Generating LLVM IR for all components..."
	cd pipelines && ./generate_all_ir.sh

# 编译基准测试框架
benchmark_framework: benchmark_framework.c ir
	@echo "Building benchmark framework..."
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ benchmark_framework.c $(LIBS)
	@echo "✅ Benchmark framework built!"

# 运行所有基准测试
benchmark: benchmark_framework
	@echo "Running comprehensive benchmark tests..."
	chmod +x run_all_benchmarks.sh
	./run_all_benchmarks.sh

# 运行单个测试 (例如: make test-sf1-q1-exec)
test-%-%-exec:
	./benchmark_framework $(shell echo $* | cut -d'-' -f1 | tr '[:lower:]' '[:upper:]') $(shell echo $* | cut -d'-' -f2-) exec

test-%-%-e2e:
	./benchmark_framework $(shell echo $* | cut -d'-' -f1 | tr '[:lower:]' '[:upper:]') $(shell echo $* | cut -d'-' -f2-) e2e

# 快速测试 (仅 SF1)
quick-test: benchmark_framework
	@echo "Running quick tests on SF1..."
	./benchmark_framework SF1 scan_filter_q1 exec
	./benchmark_framework SF1 scan_filter_q1 e2e
	./benchmark_framework SF1 q1_full exec
	./benchmark_framework SF1 q1_full e2e

# 验证测试 (检查所有用例是否能编译和运行)
validate: benchmark_framework
	@echo "Validating all test cases..."
	@echo "Testing compilation for all cases..."
	@for case in scan_filter_q1 scan_filter_q6 agg_only_q1 sort_only_shipdate q6_full q1_full; do \
		echo "  Validating $$case..."; \
		timeout 30 ./benchmark_framework SF1 $$case exec > /dev/null 2>&1 && echo "    ✅ $$case OK" || echo "    ❌ $$case FAILED"; \
	done

# 清理
clean:
	rm -f benchmark_framework
	rm -f benchmark_results.csv benchmark_summary.csv benchmark_report.txt
	rm -f /tmp/jit_*.so

clean-ir:
	rm -f pipelines/*.ll

clean-all: clean clean-ir

# 帮助信息
help:
	@echo "TPC-H JIT Benchmark System"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Build benchmark framework"
	@echo "  ir               - Generate all LLVM IR files"
	@echo "  benchmark        - Run comprehensive benchmark tests"
	@echo "  quick-test       - Run quick tests on SF1 only"
	@echo "  validate         - Validate all test cases work"
	@echo ""
	@echo "Individual tests:"
	@echo "  test-sf1-scan_filter_q1-exec"
	@echo "  test-sf3-q6_full-e2e"
	@echo "  (pattern: test-<scale>-<case>-<mode>)"
	@echo ""
	@echo "Available cases:"
	@echo "  scan_filter_q1, scan_filter_q6, agg_only_q1"
	@echo "  sort_only_shipdate, q6_full, q1_full"
	@echo ""
	@echo "Available modes: exec, e2e"
	@echo "Available scales: sf1, sf3, sf5"
	@echo ""
	@echo "Clean:"
	@echo "  clean            - Clean executables and results"
	@echo "  clean-ir         - Clean generated IR files"
	@echo "  clean-all        - Clean everything"

.PHONY: all ir benchmark quick-test validate clean clean-ir clean-all help