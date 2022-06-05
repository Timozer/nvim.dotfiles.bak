package lib

import (
	"errors"
	"os"
)

func IsSpace(c byte) bool {
	switch c {
	case '\t', '\n', '\v', '\f', '\r', ' ', 0x85, 0xA0:
		return true
	default:
		return false
	}
}

func FileExists(fpath string) (bool, error) {
	_, err := os.Stat(fpath)
	if err == nil {
		return true, nil
	}
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	return false, err
}

func CreateDirIfNotExist(dir string) error {
	_, err := os.Stat(dir)
	if err == nil || !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return os.MkdirAll(dir, os.ModePerm)
}
