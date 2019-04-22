# TeslaMojito

```elixir
defmodule APP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Tesla.Adapter.Mojito.child_spec
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: APP.Supervisor)
  end
end
```

```elixir
defmodule DemoClient do
  use Tesla

  adapter Tesla.Adapter.Mojito, pool: true
  plug Tesla.Middleware.BaseUrl, "https://http2.golang.org"
  plug Tesla.Middleware.Timeout, timeout: 1_00

  def index do
    get("/")
  end
end
```

```elixir
defmodule KugouClient do
  use Tesla

  adapter Tesla.Adapter.Mojito, pool: true
  plug Tesla.Middleware.BaseUrl, "http://m.kugou.com"
  plug Tesla.Middleware.Timeout, timeout: 1_000
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.JSON, engine: Poison, engine_opts: [keys: :atoms]

  def list do
    get("/rank/list", query: [json: true])
  end
end
```

## Installation

```elixir
defp deps do
  [
    {:tesla, "~> 1.2.1"},
    {:mojito, "~> 0.1.1"},
    {:tesla_mojito, "~> 0.1.0"}
  ]
end
```