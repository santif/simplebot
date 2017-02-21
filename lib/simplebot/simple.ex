defmodule Simplebot.Simple do

  @moduledoc """
  State machine business logic
  """

  require Logger
  alias Simplebot.Simple.State
  alias Simplebot.Service.Echo, as: EchoService

  defmodule State do
    defstruct current: nil,
      last_request_at: nil
  end


  ##
  ## Public API
  ##

  @doc """
  Initializes state
  """
  def init() do
    {:ok, %State{}}
  end

  @doc """
  Process user request
  """
  @spec handle_message(message :: map(), state :: Simplebot.Simple.State.t, DateTime.t) ::
    {:reply, reply :: map(), Simplebot.Simple.State.t} |
    {:noreply, Simplebot.Simple.State.t}
  def handle_message(message, state = %State{}, now \\ DateTime.utc_now()) do
    Logger.debug fn ->
      ">> Start operation: #{inspect message} - Current state: #{inspect state}"
    end
    result = message
    |> process_request(state)
    |> update_state_timestamp(now)
    Logger.debug fn -> ">> Operation result: #{inspect result}" end
    result
  end

  @doc """
  Returns DateTime of the last request
  """
  def get_timestamp!(%State{last_request_at: last_request_at}) do
    last_request_at
  end


  ##
  ## Internal API
  ##

  def process_request(%{text: "/start"}, _state) do
    welcome = """
    Welcome to Simplebot! Please enter any command or just type "help"
    """
    {:reply, %{text: welcome}, %State{}}
  end


  def process_request(%{text: "/q"}, state) do
    Logger.debug "Cancel current operation"
    {:noreply, %State{state | current: nil}}
  end

  def process_request(%{text: "/echo"}, state = %State{current: nil}) do
    {:reply, %{text: "Please, say something:"}, %State{state | current: :echo}}
  end

  def process_request(%{text: text}, state = %State{current: :echo}) do
    Logger.debug "Cancel current operation"
    case EchoService.echo(text) do
      {:ok, result} ->
        {:reply, %{text: result}, %State{state | current: nil}}
      {:error, reason} ->
        {:reply, %{text: "#{reason}"}, %State{state | current: :echo}}
    end
  end

  def process_request(%{text: _text}, state) do
    mod = """
    *Commands*:
    /echo: Echo next message (reversed!)
    """
    {:reply, %{text: mod}, %State{state | current: nil}}
  end


  ##
  ## Private functions
  ##

  defp update_state_timestamp({:reply, reply, state}, now) do
    {:reply, reply, %State{ state | last_request_at: now }}
  end
  defp update_state_timestamp({:noreply, state}, now) do
    {:noreply, %State{ state | last_request_at: now }}
  end
end