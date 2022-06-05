package types

import (
	"fmt"
	"gpm/cmn"
	"os"
	"path/filepath"
	"strings"

	"github.com/go-git/go-git/v5"
)

type Event struct {
	Name    string `msgpack:"name"`
	Pattern string `msgpack:"pattern"`
}

type Plugin struct {
	Type    string  `msgpack:"type"`
	Path    string  `msgpack:"path"`
	Opt     bool    `msgpack:"opt"`
	Event   []Event `msgpack:"event"`
	Disable bool    `msgpack:"disable"`

	Name        string `msgpack:"-"`
	InstallPath string `msgpack:"-"`

	status string
}

func (p *Plugin) SyncGit() {
	p.status = "start sync from git ..."

	p.Name = strings.TrimSuffix(filepath.Base(p.Path), ".git")
	p.InstallPath = filepath.Join(p.InstallPath, p.Name)

	p.status = "checking install path ..."
	exist, err := cmn.FileExists(p.InstallPath)
	if err != nil {
		p.status = err.Error()
		return
	}
	if exist {
		p.status = "install path exist, checking if need update ..."
		repo, err := git.PlainOpen(p.InstallPath)
		if err != nil {
			p.status = "install path exist, but not is a valid repository, removing ..."
			err = os.RemoveAll(p.InstallPath)
			if err != nil {
				p.status = fmt.Sprintf("remove exist install path fail, err: %s", err.Error())
				return
			}
		} else {
			p.status = fmt.Sprintf("updating %s ...", p.Name)
			wt, err := repo.Worktree()
			if err != nil {
				p.status = fmt.Sprintf("get worktree fail, err: %s", err)
				return
			}
			err = wt.Pull(&git.PullOptions{})
			if err != nil && err != git.NoErrAlreadyUpToDate {
				p.status = fmt.Sprintf("update %s fail, err: %s", p.Name, err)
			} else {
				p.status = fmt.Sprintf("update %s done", p.Name)
			}
			return
		}
	} else {
		p.status = fmt.Sprintf("installing %s ...", p.Name)
	}

	_, err = git.PlainClone(p.InstallPath, false, &git.CloneOptions{
		URL: p.Path,
	})
	if err != nil {
		p.status = fmt.Sprintf("install %s fail, err: %s", p.Name, err.Error())
		return
	}
	p.status = fmt.Sprintf("install %s done.", p.Name)
}

func (p *Plugin) SyncLocal() {
	p.status = "start sync from local"

}

func (p *Plugin) SyncLuarocks() {
	p.status = "start sync from luarocks"

}

func (p *Plugin) SyncHttp() {
	p.status = "start sync from http"

}

func (p *Plugin) Sync() {
	p.InstallPath = filepath.Join(p.InstallPath, p.Type)
	if p.Opt {
		p.InstallPath = filepath.Join(p.InstallPath, "opt")
	} else {
		p.InstallPath = filepath.Join(p.InstallPath, "start")
	}
	switch p.Type {
	case "git":
		p.SyncGit()
	case "local":
		p.SyncLocal()
	case "luarocks":
		p.SyncLuarocks()
	case "http":
		p.SyncHttp()
	}
}

func (p *Plugin) GetLines() [][]byte {
	line := fmt.Sprintf("path: %s, status: %s", p.Path, p.status)
	return [][]byte{[]byte(line)}
}
