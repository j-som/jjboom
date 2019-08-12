%%%-------------------------------------------------------------------
%%% @author J
%%% @email j-som@foxmail.com
%%% @copyright (C) 2019, <suyougame>
%%% @doc
%%%   协议
%%% @end
%%% @created : 09. August 2019 18:45
%%%-------------------------------------------------------------------

-module(jpt).

%% API exports
-export([
    decode/1,
    encode/5
]).

-export([
    service/2
    ]).

%%====================================================================
%% API functions
%%====================================================================
decode(BinData) ->
    case BinData of 
        <<Len:32, Zip:8, C:8, M:8, D:8, Data:Len/binary-unit:8, Rest/binary>> ->
            UnZipData = zip:unzip(Zip, Data),
            Protocol = protocol_router:route(C, M),
            {ok, Obj} = Protocol:decode(D, UnZipData),
            {ok, [C, M, D, Obj], Rest};
        _ ->
            wait
    end.


encode(C, M, D, Data, Zip) ->
    Protocol = protocol_router:route(C, M),
    {ok, BinData} = Protocol:encode(D, Data),
    ZipData = zip:zip(Zip, BinData),
    Len = byte_size(ZipData),
    <<Len:32, Zip:8, C:8, M:8, D:8, ZipData/binary>>.


service([C, M, D, Obj], FromSocket) ->
    todo.

%%====================================================================
%% Internal functions
%%====================================================================
