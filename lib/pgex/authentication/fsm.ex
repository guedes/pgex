#defmodule PGEx.Authentication.FSM do
#  alias PGEx.Connection.ConnectionInfo, as: ConnectionInfo
#  alias :gen_fsm,                       as: F
#  
#  @behaviour :gen_fsm
#  
#  #API
#  def start(ConnectionInfo[] = conninfo) do
#    F.start(__MODULE__, [conninfo], [])
#  end
#
#  def start_link(ConnectionInfo[] = conninfo) do
#    F.start_link(__MODULE__, [conninfo], [])
#  end
#
#  def send_auth(pid) do
#    F.sync_send_event( pid, _)
#
#
#  # FSM
#
#  def init(conninfo) do
#    { :ok, :connecting, conninfo }
#  end
#
#  def handle_sync_event(_event, _from, _state_name, _state_data) do
#  end
#
#  def handle_info(_info, _state_name, _state_data) do
#  end
#
#  def handle_event(_event, _state_name, _state_data) do
#  end
#
#  def code_change(_old, _state_name, _state_data, _extra) do
#  end
#
#  def terminate(_reason, _state_name, _state_data) do
#  end
#end
