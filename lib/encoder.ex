defmodule Swole.Encoder do
  @moduledoc """
  Behaviour for Encoding API specs into other formats.
  """
  alias Swole.APISpec

  @type encoded_from_spec() :: any()
  @type error_message() :: String.t() | Exception.t()

  @callback encode(%APISpec{}, opts :: keyword()) ::
              {:ok, encoded_from_spec()} | {:error, error_message()}
end
