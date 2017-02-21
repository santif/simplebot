defmodule Simplebot.Bot.SimpleBot do
  @moduledoc """
  Simplebot state machine
  """

  require Logger
  alias Simplebot.Bot.SimpleBot.State
  alias Simplebot.Service.Main, as: MainService

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
    {:reply, reply :: map(), Simplebot.Bot.SimpleBot.State.t} |
    {:noreply, Simplebot.Bot.SimpleBot.State.t}
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

  def process_request(%{"text" => "/start"}, state) do
    welcome = """
    Welcome to Simplebot! Please enter any command or just type "help"
    """
    {:reply, %{"text" => welcome}, %State{state | current: nil}}
  end

  def process_request(%{"text" => "/q"}, state = %State{current: cur}) when not is_nil(cur) do
    {:reply, %{"text" => "Cancelled"}, %State{state | current: nil}}
  end

  def process_request(%{"text" => "/reverse"}, state = %State{current: nil}) do
    {:reply, %{"text" => "Please, insert text to reverse:"}, %State{state | current: :reverse}}
  end

  def process_request(%{"text" => text}, state = %State{current: :reverse}) do
    case MainService.reverse(text) do
      {:ok, result} ->
        {:reply, %{"text" => result}, %State{state | current: nil}}
      {:error, reason} ->
        Logger.error "Error processing '#{text}'. Current state is :reverse"
        {:reply, %{"text" => "An error has ocurred. Please, try again"},
          %State{state | current: :reverse}}
    end
  end

  def process_request(%{"text" => _text}, state) do
    welcome_banner = """
    *Commands*:
    /reverse: Reverse next message
    """
    {:reply, %{"text" => welcome_banner}, %State{state | current: nil}}
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