%%%-------------------------------------------------------------------
%%% @author J
%%% @email j-som@foxmail.com
%%% @copyright (C) 2019, <suyougame>
%%% @doc
%%%   启动逻辑
%%% @end
%%% @created : 26. March 2019 17:06
%%%-------------------------------------------------------------------

-module(launch).

-export([
    fire/0
    ]).

fire() ->
    socket_pool:create_connections(16),
    ignore.