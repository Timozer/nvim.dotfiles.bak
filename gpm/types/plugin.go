package types

import (
	"fmt"
	"gpm/cmn"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/go-git/go-git/v5"
)

type Plugin struct {
	Name  string   `msgpack:"name"`
	Type  string   `msgpack:"type"`
	Path  string   `msgpack:"path"`
	Opt   bool     `msgpack:"opt"`
	Event []string `msgpack:"event"`

	status string
}

func (p *Plugin) SyncGit(dst string) {
	p.status = "start sync from git..."
	if p.Opt {
		dst = filepath.Join(dst, "opt")
	} else {
		dst = filepath.Join(dst, "start")
	}
	dst = filepath.Join(dst, filepath.Base(p.Path))
	dst = strings.TrimSuffix(dst, ".git")
	time.Sleep(3 * time.Second)
	p.status = "checking install dir..."
	exist, err := cmn.FileExists(dst)
	if err != nil {
		p.status = err.Error()
		return
	}
	if exist {
		time.Sleep(3 * time.Second)
		p.status = "dst dir exist, removing ..."
		err = os.RemoveAll(dst)
		if err != nil {
			p.status = err.Error()
			return
		}
	}
	time.Sleep(3 * time.Second)
	p.status = "start clone git repo from " + p.Path

	_, err = git.PlainClone(dst, false, &git.CloneOptions{
		URL: p.Path,
	})
	if err != nil {
		p.status = "clone failed, err " + err.Error()
		time.Sleep(3 * time.Second)
		return
	}
	p.status = "clone succeed."
	time.Sleep(3 * time.Second)
}

func (p *Plugin) SyncLocal(dst string) {
	p.status = "start sync from local"

}

func (p *Plugin) SyncLuarocks(dst string) {
	p.status = "start sync from luarocks"

}

func (p *Plugin) SyncHttp(dst string) {
	p.status = "start sync from http"

}

func (p *Plugin) Sync(dst string) {
	switch p.Type {
	case "git":
		p.SyncGit(dst)
	case "local":
		p.SyncLocal(dst)
	case "luarocks":
		p.SyncLuarocks(dst)
	case "http":
		p.SyncHttp(dst)
	}
}

func (p *Plugin) GetLines() [][]byte {
	line := fmt.Sprintf("name: %s, status: %s", p.Name, p.status)
	return [][]byte{[]byte(line)}
}
