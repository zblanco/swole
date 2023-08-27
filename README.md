# Swole

Generates OpenAPI based specs and docs from Phoenix/Plug ConnTests.

Swole is fork/rewrite of [Bureaucrat](https://github.com/api-hogs/bureaucrat) that builds an `%Swole.APISpec{}` struct used as a common target for encoding to other formats like JSON, Markdown, etc.

### Background

Another team at our org wanted to generate some scaffolding based on our API spec. 

We were using a lightly modified version of Bureaucrat for our Phoenix app to generate markdown documentation of our APIs. This was a great solution for a while considering it took almost no time at all. 

We had a large API with wide surface area and writing an OpenAPI YAML/JSON document by hand was a lot of work - Bureaucrat allowed us to generate the docs by hooking into ConnTests but it only output markdown targets and we needed a spec doc other programmers could use.

The solution was `Swole` a quick fork of Bureaucrat. The core design change was to build an intermediate struct that could be used as a functional target closely modeling the [OpenAPI v3.1.0 spec](https://spec.openapis.org/oas/latest.html) for other outputs.

Swole and Bureaucrat work by hooking into ExUnit test runs as a [Formatter](https://hexdocs.pm/ex_unit/1.15.0/ExUnit.Formatter.html) which lets it hook into a `:suite_finished` that informs us when we can build our Spec from the recorded test runs.

Swole differs from Bureaucrat in that it doesn't use an OTP Application and instead starts a supervision tree when calling `Swole.start_link/1` with a `:name`.

Having a common `%Swole.APISpec{}` payload means extending is simply implementing the `Swole.Encoder` behaviour and configuring a `writer`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `swole` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:swole, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/swole>.

