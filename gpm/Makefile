all: build manifest

build:
	go mod tidy
	go build -o gpm .

manifest:
	./gpm manifest -H gpm -f "plugin/gpm.vim"
	cp -rf plugin/gpm.vim ../plugin/gpm.vim

clean:
	rm -rf gpm logs
