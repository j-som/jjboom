%%-----------------------------------------------------------------------------
%% @Module  :       tcp_acceptor.erl
%% @Author  :       J
%% @Email   :       j-som@foxmail.com
%% @Created :       2016-08-10
%% @Description:    Socket二进制流接收器
%%-----------------------------------------------------------------------------

%% TODO 
%% 1.设置socket的active以控制流量 ok.
%% 2.创建消息处理进程 mhpid
%% 3.监听失败了的处理方案
%% 4.连接池 ok

-module (tcp_acceptor).
-behaviour (gen_server).
-export ([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export ([new/1]).
new(LSocket) ->
    gen_server:start_link(?MODULE, [LSocket], []).

-record(state, {
    lsocket         %% 服务端socket local socket
}).


init([LSocket]) ->
    io:format("tcp acceptor init~n"),
    {ok, #state{lsocket = LSocket}, 0}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(timeout, #state{lsocket = LSocket} = State) ->
    %% 配置
    case gen_tcp:accept(LSocket, 60000) of
        {ok, Socket} ->
            % {ok, _} = socket_pool:start_child(), %% 新创建一个接收器
            {ok, Pid} = c2s:start([Socket]),
            case gen_tcp:controlling_process(Socket, Pid) of 
                ok -> ok;
                _ ->
                    c2s:stop(Pid)
            end,
            {noreply, State, 0}; 
        {error, timeout} -> %% 清理一下消息列表
            {noreply, State, 0};
        {error, Reason} ->
            {stop, Reason, State}
    end;

handle_info(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.