%%%-------------------------------------------------------------------
%%% @author J
%%% @email j-som@foxmail.com
%%% @copyright (C) 2019, <suyougame>
%%% @doc
%%%   Client2Server
%%% @end
%%% @created : 25. March 2019 10:10
%%%-------------------------------------------------------------------

-module(c2s).
-behaviour(gen_server).

%% API
-export([start/1, stop/1, start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
    socket = undefined,
    reader = undefined,
    rest = <<>>
}).

%%
%% bug：假如被某处kill掉，terminate不会执行也就无法进行清理操作
%%

start(Args) ->
   c2s_sup:start_child(Args).

start_link(Args) ->
    gen_server:start_link(?MODULE, [Args], []).

stop(Pid) ->
   gen_server:call(Pid, stop).

init([Socket]) ->
    inet:setopts(Socket, [{active, 1}]),
    Reader = jpt, %% TODO 从配置中获取
    State = #state{socket = Socket, reader = Reader},
    {ok, State}.

handle_call(stop, _From, State) ->
   {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
   {noreply, State}.

handle_info({tcp, Socket, NewBin}, #state{socket = Socket, rest = Bin, reader = Reader} = State) ->
    case read(Reader, <<Bin/binary, NewBin/binary>>, Socket) of 
        {ok, RestBin} ->
            inet:setopts(Socket, [{active, 1}]),
            {noreply, State#state{rest = RestBin}};
        _ ->
            {stop, protocol_error, State}
    end;

handle_info({tcp_closed, Socket}, #state{socket = Socket} = State) ->
    io:format("~p closed~n", [Socket]),
    {stop, normal, State};

handle_info(_Info, State) ->
    io:format("info ~p~n", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    io:format("c2s terminate~n"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

read(Reader, BinData, Socket) ->
    case Reader:decode(BinData) of 
        {ok, Data, Rest1} ->
            Reader:service(Data, Socket),
            read(Reader, Rest1, Socket);
        wait ->
            {ok, BinData}
    end.


