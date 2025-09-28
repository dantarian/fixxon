defmodule Fixxon.RateLimit do
  use Hammer, backend: :ets, algorithm: :sliding_window
end
