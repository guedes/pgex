defmodule PGEx.Connection.Server do
  alias PGEx.Connection.State
  alias :gen_fsm, as: FSM
  alias :gen_tcp, as: TCP

  @behaviour :gen_fsm

  # public API
  def start_link() do
    FSM.start_link(__MODULE__, [], [])
  end

  def connect(conn) do
    FSM.sync_send_evend(conn.pid, { :connect, conn })
  end

  def stop(conn) do
    FSM.send_all_state_event(conn.pid, :stop)
  end

  def init() do
    IO.puts conn
    { :ok, conn }
  end

end
