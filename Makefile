main:
	mkdir -p build
	spasm -E src/main.asm build/test.8xp

clean:
	rm -rf build/*
