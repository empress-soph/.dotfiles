macro-paths := $(shell find . -type f -name '*macros.fnl')
src-paths := $(filter-out $(macro-paths),$(shell find . -type f -name '*.fnl'))

output-paths := $(src-paths)
output-paths := $(patsubst %.fnl,%.lua,$(output-paths))
output-paths := $(patsubst ./fnl/%,./lua/%,$(output-paths))

ifeq (${FENNEL_PATH},)
FENNEL_PATH := $(shell command -v fennel)
endif

.PHONY: all
all: $(output-paths)

$(output-paths): $(src-paths)

macro-args := $(foreach path,$(macro-paths),--add-macro-path "$(path)")

lua/%.lua: fnl/%.fnl
	@mkdir -p $(dir $@)
	"${FENNEL_PATH}" $(macro-args) --compile "$<" > "$@"

%.lua: %.fnl
	@mkdir -p $(dir $@)
	"${FENNEL_PATH}" $(macro-args) --compile "$<" > "$@"

clean:
	rm $(output-paths)
