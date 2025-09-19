macro-paths := $(shell find . -type f -name '*macros.fnl')
src-paths := $(filter-out $(macro-paths),$(shell find . -type f -name '*.fnl'))

output-paths := $(src-paths)
output-paths := $(patsubst %.fnl,%.lua,$(output-paths))
output-paths := $(patsubst ./fnl/%,./lua/%,$(output-paths))

ifeq (${NVIM_PATH},)
NVIM_PATH := $(shell command -v nvim)
NVIM_APPNAME := neovim
endif

.PHONY: all
all: $(output-paths)

$(output-paths): $(src-paths)

macro-args := $(foreach path,$(macro-paths),--add-macro-path "$(path)")

lua/%.lua: fnl/%.fnl
	"${NVIM_PATH}" --headless -n -i NONE "$<" +NfnlCompileFile +q
	@echo ""

%.lua: %.fnl
	"${NVIM_PATH}" --headless -n -i NONE "$<" +NfnlCompileFile +q
	@echo ""

clean:
	"${NVIM_PATH}" --headless -n -i NONE "$<" +NfnlDeleteOrphans +q
	rm $(output-paths)
