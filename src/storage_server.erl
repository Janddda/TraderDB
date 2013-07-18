-module(storage_server).

-behaviour(gen_server).

-export([start_link/0, import_from_file/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, []}.

import_from_file(Filename) ->
    gen_server:call(?MODULE, {import, Filename}).

handle_call({import, Filename}, _From, State) ->
    io:format("Importing data from filename ~p ~n", [Filename]),

    {ok, Data} = file:read_file(Filename),
    Lines = tl(re:split(Data, "\r?\n", [{return, binary}, trim])),
    lists:foreach(fun(L) -> 
                          [Time, _, _, _, Close, _] = re:split(L, ","), 
                          dbhelper:add("EURUSD", Time, Close) 
                  end,
                  Lines),

    {reply, ok, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
