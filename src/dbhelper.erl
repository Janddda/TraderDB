% Mnesia as storage
% Jon Romero 07/06/2013
% jon@bugsense.com

-module(dbhelper).
-export([start/0, stop/0, add/3, find/1]).

-record(stocks, {{datetime, name}, name, price}).

start() ->
	% starting mnesia
	mnesia:create_schema(node()),
	mnesia:start(),

	mnesia:create_table(stocks, [{type, order_set},
									   {ram_copies,[node()]},
									   {local_content, true},
									   {attributes, record_info(fields, stocks)}]).
stop() ->
	mnesia:stop().


%% TODO: datetime should be converted to ms since unix
add(StockName, DateTime, Price) ->	
	T = fun() -> 
                mnesia:write(#stocks{{datetime=DateTime, name=StockName}, name=StockName, price=Price})
		end,
	mnesia:transaction(T).


find(StockName) ->	
	T = fun() ->
				mnesia:read({stocks, StockName})
		end,
	{atomic, Result} = mnesia:transaction(T),
	Result.

