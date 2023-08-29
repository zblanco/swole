defmodule Swole.APISpec do
  @moduledoc """
  Models the API spec as a struct.

  Used as the common target for exports to other formats.

  Capable of building the API spec from a list of conns from Phoenix Conn tests supplied by the Swole.Recorder.

  Based on the (OpenAPI Document Object)[https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.1.0.md#openapi-object]
  """

  @methods ~w(GET POST PUT PATCH DELETE OPTIONS HEAD TRACE)

  defstruct ~w(
    openapi
    servers
    paths
    components
    security
    tags
    externalDocs
    info
  )a

  def new(config, conn_records) do
    %__MODULE__{
      openapi: config[:openapi] || "3.1.0",
      servers: servers(config, conn_records),
      paths: paths(conn_records),
      info: info(config[:info]),
      tags: tags(config, conn_records)
    }
  end

  defimpl Jason.Encoder do
    def encode(%Swole.APISpec{} = spec, opts) do
      spec
      |> Map.from_struct()
      |> Map.take(~w(openapi info servers paths components security tags externalDocs)a)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()
      |> Jason.Encode.map(opts)
    end
  end

  defp info(config_info) do
    config_info
    |> Map.new(fn
      {k, v} when is_atom(k) ->
        {to_string(k), v}

      {k, v} ->
        {k, v}
    end)
    |> Map.take(~w(title summary version description termsOfService contact license))
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp servers(config, conn_records) do
    servers_config = config[:servers]

    unless is_nil(servers_config) do
      servers_config
    else
      conn_records
      |> Enum.map(& &1.host)
      |> Enum.uniq()
      |> Enum.map(fn host ->
        %{
          url: host,
          description: ""
        }
      end)
    end
  end

  defp paths(conn_records) do
    conn_records
    |> Enum.group_by(&request_path_pattern/1)
    |> Map.new(fn {path, conns_for_path} ->
      {path,
       Enum.reduce(
         @methods,
         %{"summary" => "", "description" => "", "parameters" => parameters(conns_for_path)},
         fn method, acc ->
           operation_for_method = operation_for_method(conns_for_path, method)

           unless is_nil(operation_for_method) do
             Map.put(acc, String.downcase(method), operation_for_method)
           else
             acc
           end
         end
       )}
    end)
  end

  defp request_path_pattern(conn) do
    conn.path_params
    |> Enum.reduce(conn.request_path, fn {k, v}, req_acc ->
      String.replace(req_acc, v, "{#{k}}")
    end)
    # regex to remove file extension from url paths if present
    |> String.replace(~r"\.[^.]+$", "")
  end

  defp tags(%{tags: tags}, conn_records) do
    tags_config =
      Map.new(tags, fn {k, v} ->
        {to_string(k), v}
      end)

    [
      tags_config
      | tags_from_conns(conn_records)
    ]
  end

  defp tags(_config, conn_records) do
    tags_from_conns(conn_records)
  end

  defp tags_from_conns(conns) do
    conns
    |> Enum.uniq_by(& &1.private.phoenix_controller)
    |> Enum.map(fn conn ->
      controller_tag = conn.private.phoenix_controller |> to_string() |> String.trim("Elixir.")

      %{
        "name" => controller_tag,
        "description" => "#{controller_tag} Actions"
      }
    end)
  end

  defp operation_for_method(conns, method) do
    conns_for_method = conns_for_method(conns, method)

    if Enum.empty?(conns_for_method) do
      nil
    else
      build_operation(conns_for_method, method)
    end
  end

  defp build_operation(conns, method) when is_list(conns) do
    first_conn = List.first(conns)

    parameters = operation_parameters(conns)

    %{
      tags:
        conns
        |> Enum.map(&(&1.private.phoenix_controller |> to_string() |> String.trim("Elixir.")))
        |> Enum.uniq(),
      description: description(conns),
      operationId: first_conn.assigns.swole_opts[:operation_id],
      parameters: unless(Enum.empty?(parameters), do: parameters, else: nil),
      requestBody: request_body(conns, method),
      responses:
        Map.new(conns, fn conn ->
          {conn.status,
           %{
             description: conn.assigns.swole_opts[:description],
             content: build_content(conn)
           }}
        end),
      deprecated: false
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp conns_for_method(conns, method) do
    Enum.filter(conns, &(&1.method == method))
  end

  defp parameters(conns) do
    conns
    |> Enum.flat_map(fn conn ->
      Enum.map(conn.params, fn {k, v} ->
        k_in =
          cond do
            conn.path_params |> Map.has_key?(k) -> "path"
            conn.query_params |> Map.has_key?(k) -> "query"
            conn.req_headers |> MapSet.new(fn {k, _v} -> k end) |> MapSet.member?(k) -> "header"
            conn.body_params |> Map.has_key?(k) -> "body"
            true -> "query"
          end

        unless k_in == "header" and
                 String.downcase(k) in ["accept", "content-type", "authorization"] do
          %{
            name: k,
            in: k_in,
            description: param_description(conn, k, k_in),
            required: if(k_in == "path", do: true, else: false),
            schema: infer_json_schema(v, %{})
          }
        else
          nil
        end
      end)
      |> Enum.reject(&(&1.in == "body"))
    end)
    |> Enum.uniq_by(fn param -> param[:name] end)
    |> Enum.reject(&is_nil/1)
  end

  defp param_description(conn, k, "path") do
    """
    ### Path: `#{conn.request_path |> String.replace(Map.get(conn.path_params, k), ":#{k}")}`

      Example: `#{conn.host}#{conn.request_path}`
    """
  end

  defp param_description(_, _k, _kind_of_param) do
    ""
  end

  defp request_body(_conns, method) when method in ["GET", "HEAD", "DELETE"] do
    nil
  end

  defp request_body(conns, _method) do
    %{
      description: description(conns),
      content:
        Enum.reduce(conns, %{}, fn conn, acc ->
          content_type = content_type(conn)

          unless Map.has_key?(acc, content_type) do
            unless Enum.empty?(conn.body_params) do
              Map.put(acc, content_type, %{schema: request_schema(conn, content_type)})
            else
              acc
            end
          else
            existing_content = Map.get(acc, content_type)

            Map.put(
              acc,
              content_type,
              Map.put(existing_content, :schema, request_schema(conn, content_type))
            )
          end
        end),
      required: Enum.all?(conns, &(not Enum.empty?(&1.body_params)))
    }
  end

  defp operation_parameters(conns) do
    conns
    |> Enum.flat_map(fn conn ->
      Enum.map(conn.params, fn {k, v} ->
        k_in =
          cond do
            conn.path_params |> Map.has_key?(k) -> "path"
            conn.query_params |> Map.has_key?(k) -> "query"
            conn.req_headers |> MapSet.new(fn {k, _v} -> k end) |> MapSet.member?(k) -> "header"
            conn.body_params |> Map.has_key?(k) -> "body"
            true -> "query"
          end

        unless k_in == "header" and
                 String.downcase(k) in ["accept", "content-type", "authorization"] do
          %{
            name: k,
            in: k_in,
            description: operation_param_description(conn, k, k_in),
            required: if(k_in == "path", do: true, else: false),
            schema: infer_json_schema(v, %{})
          }
        else
          nil
        end
      end)
      |> Enum.reject(&(&1.in == "body"))
    end)
    |> Enum.uniq_by(fn param -> param[:name] end)
    |> Enum.reject(&is_nil/1)
  end

  defp operation_param_description(conn, k, "path") do
    """
    ### Path: `#{conn.request_path |> String.replace(Map.get(conn.path_params, k), ":#{k}")}`

      Example: `#{conn.host}#{conn.request_path}`
    """
  end

  defp operation_param_description(_, _k, _kind_of_param) do
    ""
  end

  # defp operation_param_description(conn, k, "query") do
  #   """
  #   ### Path: #{conn.request_path |> String.replace(Map.get(conn.path_params, k), "#{k}")}

  #     Example: `#{conn.host}#{conn.request_path}`
  #   """
  # end

  defp description(conns) do
    Enum.map(conns, & &1.assigns.swole_opts[:description]) |> Enum.join(" or\n")
  end

  defp build_content(conn) do
    content_type = content_type(conn)

    %{
      content_type => %{
        schema: schema(conn, content_type)
      }
    }
  end

  defp content_type(conn) do
    from_header = Plug.Conn.get_resp_header(conn, "content-type") |> List.first()

    unless is_nil(from_header) do
      from_header
      |> String.downcase()
      |> content_type_of_header()
    else
      content_type_of_body(conn.resp_body)
    end
  end

  defp content_type_of_header(header) do
    cond do
      String.contains?(header, "application/json") -> "application/json"
      String.contains?(header, "text/csv") -> "text/csv"
      true -> header
    end
  end

  defp content_type_of_body(body) when is_binary(body) do
    "text/plain"
  end

  defp content_type_of_body(_otherwise), do: "default"

  defp request_schema(conn, content_type)
       when content_type in ["json", "application/json", "text/csv"] do
    %{
      schema: infer_json_schema(conn.body_params, %{}),
      example: conn.body_params
    }
  end

  defp request_schema(_conn, _) do
    nil
  end

  # make a schema ref or build a schema based on the conn
  # schemas might could be consolidated in second step to avoid duplication
  # To avoid name clash of schemas after type is inferred we can consistent hash the schemas as nested
  # and name them off of the path and method and the hash
  defp schema(conn, content_type) when content_type in ["json", "application/json"] do
    conn.resp_body
    |> Jason.decode()
    |> case do
      {:ok, decoded} ->
        infer_json_schema(decoded, %{})

      {:error, _} ->
        %{type: "string"}
    end
  end

  # TODO: add support for other content types like ... XML if we must
  defp schema(_conn, _other) do
    %{type: "string"}
  end

  def infer_json_schema(nil, %{} = _schema), do: %{type: "object"}

  def infer_json_schema(resp_body, %{} = schema) when is_struct(resp_body, Date) do
    schema
    |> Map.put(:type, "string")
    |> Map.put(:format, "date")
  end

  def infer_json_schema(resp_body, %{} = schema)
      when is_struct(resp_body, DateTime) or is_struct(resp_body, NaiveDateTime) do
    schema
    |> Map.put(:type, "string")
    |> Map.put(:format, "date-time")
  end

  def infer_json_schema(resp_body, %{} = schema) when is_struct(resp_body) do
    schema
    |> Map.put(:type, "object")
    |> Map.put(
      :properties,
      resp_body
      |> Map.from_struct()
      |> Map.drop(~w(__meta__)a)
      |> Map.new(fn {k, v} -> {k, infer_json_schema(v, %{})} end)
    )
  end

  def infer_json_schema(resp_body, %{} = schema) when is_map(resp_body) do
    schema
    |> Map.put(:type, "object")
    |> Map.put(:properties, Map.new(resp_body, fn {k, v} -> {k, infer_json_schema(v, %{})} end))
  end

  def infer_json_schema(resp_body, %{} = schema) when is_list(resp_body) do
    schema
    |> Map.put(:type, "array")
    |> Map.put(
      :items,
      resp_body
      |> Enum.map(&infer_json_schema(&1, %{}))
      |> Enum.uniq()
    )
  end

  def infer_json_schema(resp_body, %{} = schema) when is_binary(resp_body),
    do: Map.put(schema, :type, "string")

  def infer_json_schema(resp_body, %{} = schema) when is_integer(resp_body),
    do: Map.put(schema, :type, "integer")

  def infer_json_schema(resp_body, %{} = schema) when is_float(resp_body),
    do: schema |> Map.put(:type, "number") |> Map.put(:format, "float")

  def infer_json_schema(resp_body, %{} = schema) when is_boolean(resp_body),
    do: Map.put(schema, :type, "boolean")

  def infer_json_schema(resp_body, %{} = schema) when is_atom(resp_body),
    do: Map.put(schema, :type, "string")

  def infer_json_schema({k, v}, %{} = schema), do: Map.put(schema, k, infer_json_schema(v, %{}))
end
