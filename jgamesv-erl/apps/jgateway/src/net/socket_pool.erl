%%%-------------------------------------------------------------------
%%% @author J
%%% @email j-som@foxmail.com
%%% @copyright (C) 2019, <suyougame>
%%% @doc
%%%   套接字监视器
%%% @end
%%% @created : 21. March 2019 20:19
%%%-------------------------------------------------------------------

-module(socket_pool).
-behaviour(supervisor).

-export([
    init/1,
    start_link/0,
    start_child/0,
    create_connections/1
    ]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child() ->
    supervisor:start_child(?MODULE, []).

create_connections(N) when N =< 0 -> ok;
create_connections(N) ->
    start_child(),
    create_connections(N - 1).

init([]) ->
    Port = 6578,
    Options = [binary, {packet, 0}, {active, false}, {reuseaddr, true}],
    {ok, LSocket} = gen_tcp:listen(Port, Options),
    Child = #{
        id => tcp_acceptor,
        start => {tcp_acceptor, new, [LSocket]},
        restart => temporary,
        shutdown => 5000,
        type => worker,
        modules => [tcp_acceptor]
    },
    Flag = #{
        strategy => simple_one_for_one,
        intensity => 0,
        period    => 1
    },
    {ok, {Flag, [Child]}}.