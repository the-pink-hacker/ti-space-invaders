EXNAME = space

main:
	mkdir -p build
	spasm -E "src/main.asm" "build/$(EXNAME).8xp"

clean:
	rm -rf build/*

sprite-gen:
	cargo run -r --manifest-path "sprite-generator/Cargo.toml" -- -s "assets/sprites/sprites.toml" -o "build/sprites/"
