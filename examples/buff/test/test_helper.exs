swole_config = [
  name: Buff.Swole,
  writers: [
    %{
      encoder: Swole.JSONEncoder,
      path: "api.json"
    }
  ],
  default_path: "doc/source/index.html.md",
  env_var: "DOC",
  swagger: %{
    host: "localhost:4000",
    schemes: ["http"],
    basePath: "/api",
    consumes: ["application/json"],
    produces: ["application/json"]
  },
  info: %{
    title: "Buff API",
    version: "0.1.0"
  },
  tags: [
    %{
      name: "plants",
      description: "Manage Plants"
    }
  ],
  summary: "JSON API for Buff",
  description: "Buff is a plant management system for swole plants.",
]

Swole.start_link(swole_config)

ExUnit.configure(swole: swole_config)

ExUnit.start(formatters: [Swole.Formatter])
Ecto.Adapters.SQL.Sandbox.mode(Buff.Repo, :manual)
