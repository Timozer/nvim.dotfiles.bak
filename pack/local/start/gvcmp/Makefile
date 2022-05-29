all: build manifest

build:
	go mod tidy
	go build -o gvcmp .

manifest:
	./gvcmp manifest -H gvcmp -f "plugin/gvcmp.vim"

clean:
	rm -rf gvcmp logs
