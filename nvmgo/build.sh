#!/bin/bash

cd gcmp
go mod tidy
go build -o gcmp
cd -

cd gpm
go mod tidy
go build -o gpm
cd -