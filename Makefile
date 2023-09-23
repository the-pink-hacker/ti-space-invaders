EXNAME = space

main:
	mkdir -p build
	spasm -E "src/main.asm" "build/$(EXNAME).8xp"

clean:
	rm -rf build/*
