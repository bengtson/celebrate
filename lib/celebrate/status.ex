defmodule CelebrateStatus do

  defmodule Status do
    defstruct [ :name, :icon, :status, :state, :link, :hover, :metrics, :text ]
  end

  defmodule Metric do
    defstruct [ :name, :value ]
  end



  def start do
    spawn(__MODULE__,:update_status,[])
  end

  #------------ Tack Status
  def update_status do
#    IO.inspect {:update_status, :now}
    Process.sleep(10000)
    send_status()
    update_status()
  end

  def send_status do

    celebrates =
      Celebrate.get_upcoming_celebrates(60)
      |> Enum.take(5)
      |> Enum.map(fn e -> %Metric{name: e.name, value: "#{e.day} #{Wiring.get_short_month_name(e.month)}"} end)


    stat = %Status{
      name: "Celebrate",
      icon: get_icon("priv/static/images/newcelebrate.png"),
      status: "Celebrate Running",
      metrics: celebrates,
      state: :nominal,
      link: "http://10.0.1.202:4405"
    }

    with  {:ok, packet} <- Poison.encode(stat),
          {:ok, socket} <- :gen_tcp.connect('localhost', 21200,
                           [:binary, active: false]),
              _send_ret <- :gen_tcp.send(socket, packet),
             _close_ret <- :gen_tcp.close(socket)
    do
      nil
    else
      _ -> nil
    end
  end


  def get_icon path do
    {:ok, icon} = File.read path
    icon = Base.encode64 icon
    icon
  end

end