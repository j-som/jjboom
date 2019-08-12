%%%-------------------------------------------------------------------
%%% @author J
%%% @email j-som@foxmail.com
%%% @copyright (C) 2019, <suyougame>
%%% @doc
%%%   客户端-服务端 消息管理进程监护者
%%% @end
%%% @created : 26. March 2019 15:17
%%%-------------------------------------------------------------------

-module(c2s_sup).
-behaviour(supervisor).

-export([
    init/1,
    start_link/0,
    start_child/1,
    start/0
    ]).

start() ->
    game_sub:start_child(?MODULE).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_child(Args) ->
    supervisor:start_child(?MODULE, [Args]).

init([]) ->
    Child = #{
        id => c2s,
        start => {c2s, start_link, []},
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