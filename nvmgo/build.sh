#!/bin/bash

cd lib
go mod tidy
cd -

cd gcmp
go mod tidy
go build -o gcmp
./gcmp manifest -H gcmp -f "plugin/gcmp.vim"
cp plugin/gcmp.vim ~/.config/nvim/plugin/gcmp.vim
cd -

cd gpm
go mod tidy
go build -o gpm
./gpm manifest -H gpm -f "plugin/gpm.vim"
cp plugin/gpm.vim ~/.config/nvim/plugin/gpm.vim
cd -