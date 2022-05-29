package handler

type autocmdEvalExample struct {
	Cwd string `eval:"getcwd()"`
}
