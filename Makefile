sprites := $(wildcard assets/sprites/*.png)
scripts := $(wildcard src/*.asm src/**/*.asm)
sprites-generated := $(wildcard src/generated/sprites/*.asm)
asset-builder := asset-builder/target/release/asset-builder

.PHONY: all
all: $(sprites-generated) $(texts-generated) | build/space.8xp

.PHONY: clean 
clean:
	rm -rf "$(wildcard build/*.8xp)"

$(sprites-generated): $(sprites) assets/sprites/sprites.toml $(asset-builder)
	rm -f "$(sprites-generated)"
	./$(asset-builder) sprites "assets/sprites/sprites.toml" "src/generated/sprites/"
	$(info Generated sprites.)

src/generated/texts.asm: $(sprites) assets/texts.toml $(asset-builder)
	./$(asset-builder) text "assets/texts.toml" "src/generated/texts.asm"
	$(info Generated texts.)

$(asset-builder): asset-builder/Cargo.toml $(wildcard asset-builder/src/*.rs)
	cargo build --release --manifest-path "asset-builder/Cargo.toml"

build/space.8xp: $(scripts) build/
	spasm -E "src/main.asm" "build/space.8xp"
	$(info Built game)

build/:
	mkdir "build/"

