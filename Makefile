sprites := $(wildcard assets/sprites/*.png)
scripts := $(wildcard src/*.asm)
sprites-generated := $(wildcard src/generated/sprites/*.asm)
asset-builder := asset-builder/target/release/asset-builder

.PHONY: all
all: $(sprites-generated) | build/space.8xp

.PHONY: clean 
clean:
	rm -rf "build/*.8xp"

$(sprites-generated): $(sprites) assets/sprites/sprites.toml
	rm -f "$(sprites-generated)"
	./$(asset-builder) -s "assets/sprites/sprites.toml" -o "src/generated/sprites/"
	$(info Generated sprites.)

$(asset-builder):
	cargo build --release --manifest-path "asset-builder/Cargo.toml"

build/space.8xp: $(scripts) build/ $(sprites-generated)
	spasm -E "src/main.asm" "build/space.8xp"
	$(info Built game)

build/:
	mkdir "build/"

