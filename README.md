### Build `docker-compose.yml` from templates

`mkdcontmpl` : MaKe Docker Compose ON TeMPLates.

Implements build `docker-compose.yml` and `.env` files from templates. 
The system operates with the concept of context and service.


#### Main commands (makefile targets)

| Command       | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| help			| Show this help; `help.%`  —  detail helps check `help.about` |
| initCtx       | Create new 'context' from .default: `NEWCTX=<context>`       |
| listCtx       | List all contexts                                            |
| listSrv       | List all services in context                                 |
| listSrvVersion| List services with versions: `CTX=<context>` `SRV=<name>` |
| addCtxSrv     | Add service to context:      `CTX=<context>` `SRV=<name>` |
| enableCtxSrv  | Enable service in context:   `CTX=<context>` `SRV=<name>` |
| disableCtxSrv | Disable service in context:  `CTX=<context>` `SRV=<name>` |
| rmCtxSrv      | Remove service from context: `CTX=<context>` `SRV=<name>` |
| buildCtx      | Build context: `CTX=<context>`                               |

#### Example

+ Initialize context 'myctx' from template '.default'

```bash
$ make initCtx NEWCTX=myctx
```

+ Add service `nginx`to context `myctx` — that is, copy files from folder:
  
  - `.template/docker-compose/template/*.tmpl` > ./.context/myctx/.tmpl/
    
    and create directories:
  
  - `.context/myctx/.tmpl/`
  
  - `.context/myctx/.yml/`
  
  - `.context/myctx/.environ/`

+ Add service 'nginx' to context 'myctx'
  
  ```bash
  $ make addCtxSrv CTX=myctx SRV=nginx
  ```

+ Now you can edit files in directories to castomize configuration of the 'nginx' service:
  
  - `.context/myctx/.environ/nginx.env`
  - `.context/myctx/.yml/nginx.service.env`
  - `.context/myctx/.yml/nginx.volume.env`

+ Build context `myctx` — create files
  - `.context/myctx/docker-compose.yml`
  - `.context/myctx/.env`

```bash
$ make buildCtx CTX=myctx
```

#### Dependencies

The main utility on which the Jinja template engine depends is  
—  [MiniJinja](https://github.com/mitsuhiko/minijinja)

The scripts also use standard Unix utilities : 

| Command                      | Description |
| ---------------------------- | --------------------------------- |
| <nobr>`minijinja-cli`</nobr> | a powerful but minimal dependency template engine for Rust compatible with Jinja/Jinja2 |
| `sed`                        | stream editor for filtering and transforming text |
| `cp`                         | copy files and directories |
| `ln -s`                      | make links between files |
| `mkdir`                      | make a directory |
| `sort`                       | sort lines of text files |
| `truncate`                   | shrink or extend the size of a file to the specified size |
| `uniq`                       | report or omit repeated lines |
| `awk`                        | using by `keymap` functions |

#### Installation

+ [MiniJinja](https://github.com/mitsuhiko/minijinja) 

MiniJinja is also available as an (optionally pre-compiled) command line executable
called [`minijinja-cli`](https://github.com/mitsuhiko/minijinja/tree/main/minijinja-cli)

```bash
$ curl -sSfL https://github.com/mitsuhiko/minijinja/releases/latest/download/minijinja-cli-installer.sh | sh
$ echo "Hello {{ name }}" | minijinja-cli - -Dname=World
Hello World
```

Alternatively, if you have [Rust](https://www.rust-lang.org/tools/install) and the [Cargo](https://doc.rust-lang.org/stable/cargo/) package manager installed, you also can install the 'minijinja-cli' using the command

```bash
$ cargo install minijinja-cli
```

---
#### How it work
```bash
$ make help.about
```

Shortly, `context` — is a directory with a name set by the environment variable `CTX`, context-directory is located at the folder named `.context`.
The `.context/$(CTX)/` directory contains templates (Jinja/Jinja2) 
at the `.context/$(CTX)/.tmpl` folder for build `docker-compose.yml`.
YML-files from the `.context/$(CTX)/.yml/` directory describe the services available for this context, every file `$(SRV).service.yml` describe some service with name `$(SRV)` .
Env-files from the directory `.context/$(CTX)/.environ/`  set environment variables for each service  `$(SRV).env`.
The command like:
```
$ make buildCtx CTX=test
```
created 'docker-compose.yml' & '.env' files at the `./.context/test` folder.
