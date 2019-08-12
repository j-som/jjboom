%%%-------------------------------------------------------------------
%% @doc jgateway top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(jgateway_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, {{one_for_all, 0, 1}, childrens()}}.

%%====================================================================
%% Internal functions
%%====================================================================
childrens() ->
    [
     #{
        id => socket_pool,
        start => {socket_pool, start_link, []},
        restart => permanent,
        shutdown => 5000,
        type => supervisor,
        modules => [socket_pool]
    },
    #{
        id => c2s_sup,
        start => {c2s_sup, start_link, []},
        restart => permanent,
        shutdown => 5000,
        type => supervisor,
        modules => [c2s_sup]
    },
    %% 最后一个 启动游戏
    #{
        id => launch,
        start => {launch, fire, []},
        restart => temporary,
        shutdown => 5000,
        type => worker,
        modules => [launch]
    }
    ].