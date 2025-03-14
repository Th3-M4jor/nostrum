defmodule Nostrum.Store.UnavailableGuild.ETS do
  @moduledoc """
  Stores guilds that are currently unavailable using `:ets`.

  If programmatic access to the ETS table is needed, please use the `table/0`
  function.

  Please do not use this module directly, apart from special functions such as
  `tabname/0`. Use `Nostrum.Store.UnavailableGuild` to call the configured
  mapping instead.
  """
  @moduledoc since: "0.8.0"

  alias Nostrum.Bot
  alias Nostrum.Store.UnavailableGuild
  alias Nostrum.Struct.Guild
  use Supervisor

  @behaviour UnavailableGuild

  @base_table_name :nostrum_unavailable_guilds

  @doc "Retrieve the ETS table reference used for the store."
  @spec table :: :ets.table()
  def table, do: :"#{@base_table_name}_#{Bot.fetch_bot_name()}"

  @doc "Start the supervisor."
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl Supervisor
  @doc "Set up the store's ETS table."
  def init(opts) do
    table_name = :"#{@base_table_name}_#{Keyword.fetch!(opts, :name)}"
    _tid = :ets.new(table_name, [:set, :public, :named_table])
    Supervisor.init([], strategy: :one_for_one)
  end

  @impl UnavailableGuild
  @doc "Create the given guild as an unavailable guild."
  @spec create(Guild.id()) :: :ok
  def create(guild_id) do
    :ets.insert(table(), {guild_id})
    :ok
  end

  @impl UnavailableGuild
  @doc "Return whether the given guild is unavailable."
  @spec is?(Guild.id()) :: boolean()
  def is?(guild_id) do
    case :ets.lookup(table(), guild_id) do
      [{_guild_id}] -> true
      [] -> false
    end
  end
end
