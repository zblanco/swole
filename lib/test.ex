defmodule Swole.Test do
  @moduledoc """
  Provides the `doc` macro for documenting ConnTests.

  ## Examples

      defmodule MyAppWeb.UserControllerTest do
        use MyAppWeb.ConnCase, async: true

        alias MyApp.Accounts

        test "create user", %{conn: conn} do
          conn = conn()
            |> post("/users", user: @valid_attrs)
            |> doc(MyAppWeb.Swole, "Create user")

          assert json_response(conn, 201)["data"]["id"]
        end
      end
  """

  alias Plug.Conn
  alias Swole.Recorder

  @doc """
  Adds a conn to the generated documentation.

  The name of the test currently being executed will be used as a description for the example.
  """
  defmacro doc(conn, swole_name) do
    quote bind_quoted: [conn: conn, swole_name: swole_name] do
      doc(conn, swole_name, [])
    end
  end

  @doc """
  Adds a conn to the generated documentation

  The description, and additional options can be passed in the second argument:

  ## Examples

      conn = conn()
        |> get("/api/v1/products")
        |> doc(MySwole, "List all products")

      conn = conn()
        |> get("/api/v1/products")
        |> doc(MySwole, description: "List all products", operation_id: "list_products")
  """
  defmacro doc(conn, swole_name, desc) when is_binary(desc) do
    quote bind_quoted: [conn: conn, swole_name: swole_name, desc: desc] do
      doc(conn, swole_name, description: desc)
    end
  end

  defmacro doc(conn, swole_name, opts) when is_list(opts) do
    # __CALLER__returns a `Macro.Env` struct
    #   -> https://hexdocs.pm/elixir/Macro.Env.html
    mod = __CALLER__.module
    fun = __CALLER__.function |> elem(0) |> to_string
    # full path as binary
    file = __CALLER__.file
    line = __CALLER__.line

    titles = Application.get_env(:swole, :titles)

    opts =
      opts
      |> Keyword.put_new(:description, format_test_name(fun))
      |> Keyword.put_new(:group_title, group_title_for(mod, titles))
      |> Keyword.put(:module, mod)
      |> Keyword.put(:file, file)
      |> Keyword.put(:line, line)

    quote bind_quoted: [conn: conn, swole_name: swole_name, opts: opts] do
      default_operation_id = get_default_operation_id(conn)

      opts =
        opts
        |> Keyword.put_new(:operation_id, default_operation_id)

      Recorder.doc(Swole.recorder_name(swole_name), conn, opts)
      conn
    end
  end

  def format_test_name("test " <> name), do: name

  def group_title_for(_mod, []), do: nil
  def group_title_for(_mod, nil), do: nil

  def group_title_for(mod, [{other, path} | paths]) do
    if String.replace_suffix(to_string(mod), "Test", "") == to_string(other) do
      path
    else
      group_title_for(mod, paths)
    end
  end

  def get_default_operation_id(%Conn{private: private}) do
    %{phoenix_controller: elixir_controller, phoenix_action: action} = private
    controller = elixir_controller |> to_string() |> String.trim("Elixir.")

    "#{controller}.#{action}"
  end

  # def get_default_operation_id(%Message{topic: topic, event: event}) do
  #   "#{topic}.#{event}"
  # end

  # def get_default_operation_id(%Broadcast{topic: topic, event: event}) do
  #   "#{topic}.#{event}"
  # end

  # def get_default_operation_id(%Reply{topic: topic}) do
  #   "#{topic}.reply"
  # end

  @doc """
  Helper function for adding the phoenix_controller and phoenix_action keys to
  the private map of the request that's coming from the test modules.

  For example:

  test "all items - unauthenticated", %{conn: conn} do
    conn
    |> get(item_path(conn, :index))
    |> plug_doc(module: __MODULE__, action: :index)
    |> doc()
    |> assert_unauthenticated()
  end

  The request from this test will never touch the controller that's being tested,
  because it is being piped through a plug that authenticates the user and redirects
  to another page. In this scenario, we use the plug_doc function.
  """
  def plug_doc(conn, module: module, action: action) do
    controller_name = module |> to_string |> String.trim("Test")

    conn
    |> Conn.put_private(:phoenix_controller, controller_name)
    |> Conn.put_private(:phoenix_action, action)
  end
end
