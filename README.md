### About

From a birds-eye view, the primary goal of this project is to build a websocket-based web application.

The secondary goal is to make a command-line client which can be reused by the browser client for primitive server-side rendering (using [w3m](http://w3m.sourceforge.net/))

The architecture is a little unconventional:

```txt

Base Server => CLI clients => Web clients

```

Only one base server needs to be running. It can dispatch for many CLI clients.

However, dynamic CLI-client launching is not yet implemented. So a web client is for a single user only.

### Usage overview

- First, clone the repo and run `bundle install`
- Then, `cd server` and run `thin start` to run the base server
- In a new terminal, `cd client`
- `cp .env.example .env` and customize it
- run the cli-client with `sh paned_repl.sh`
- To start the web interface, run `start_server` in the repl.
- Then visit `localhost:3000` or `ENV[CHATTERER_BASE_URL]`, if it's set.
- Some special exit commands are provided in the repl:
  - `stop_server` (closes the server pane)
  - `stop_tmux` (exits the repl)

### Components

- "server" is the base websocket server.
  - From this was extracted the generator gem [sinatra_sockets](http://github.com/maxpleaner/sinatra_sockets), which provides boilerplate for sinatra with faye-websockets (eventmachine)
  - The server accepts two types of websocket requests, sent as JSON objects:
    - **subscribe**:

                {
                  'type': 'subscribe',
                  'channels': ['some_channel']
                }
    - **action**:

                {
                  'type': 'action',
                  'channel': 'some_channel',
                  name: 'something',
                  data: 'hello'
                }
      - actions require a channel that has previously been subscribed to. Otherwise no message will be sent.
      - The semantics of `name` and `data` are irrelevant to the base server.
      They originate from and are interpreted by the clients

- "client" was initially a simple IO wrapper over server. However it's been
revised to use [paned_repl](https://github.com/maxpleaner/paned_repl), which was written for this use-case.
  - The `paned_repl` gem launches a [pry](http://pryrepl.org) repl in Tmux, and provides a Ruby API for the Tmux session.
  - Each subscription is launched in a separate Tmux pane. Incoming messages are displayed there, and are also saved to file to be read by the web wrapper.

- "web wrapper" is a script launched by the client that mirrors the cli **todo more explanation**
