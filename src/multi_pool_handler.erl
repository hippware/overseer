-module(multi_pool_handler).

-behaviour(hackney_pool_handler).

-export([start/0,
  checkout/4,
  checkin/2,
  notify/2
]).

-include("../deps/hackney/include/hackney.hrl").

-define(POOLS, 6).

start() ->
    lists:foreach(fun(N) -> add_pool(N) end, lists:seq(0, ?POOLS - 1)),
    ok.

checkout(Host, Port, Transport, Client) ->
    Name = erlang:phash2(self(), ?POOLS),
    hackney_pool:checkout(Host, Port, Transport, Client#client{options = [{pool, Name} | Client#client.options]}).

checkin({_Name, _CheckingReference, _Dest, _Owner, _Transport} = Info, Socket) ->
    hackney_pool:checkin(Info, Socket).

notify(Pool, Message) ->
    hackney_pool:notify(Pool, Message).

add_pool(N) ->
    hackney_pool:start_pool(N, [{timeout, 20000}, {max_connections, 100000}]).
