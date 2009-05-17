%% Copyright (c) 2008-2009 
%% Pablo Polvorin <ppolv@jabberes.org> [http://ppolv.wordpress.com]
%% Jacob Vorreuter <jacob.vorreuter@gmail.com>
%% 
%% Permission is hereby granted, free of charge, to any person
%% obtaining a copy of this software and associated documentation
%% files (the "Software"), to deal in the Software without
%% restriction, including without limitation the rights to use,
%% copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following
%% conditions:
%% 
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%% 
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%% HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%% WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%% OTHER DEALINGS IN THE SOFTWARE.
%%
%% @doc Utility functions, mainly for type conversion
%% Conversion rules taken from http://www.w3.org/TR/1999/REC-xpath-19991116
%% created on 2008-05-07
-module(mochiweb_xpath_utils).

-export([string_value/1,
        number_value/1,
        node_set_value/1,
        boolean_value/1,
        convert/2]).


string_value(N) when is_list(N)->
    case N of
        [X|_] -> string_value(X);
        [] -> <<>>
    end;
string_value({_,_,Contents}) ->
    L = lists:filter(fun
                    ({_,_,_}) ->false;
                    (B) when is_binary(B) -> true
        end,Contents),
    list_to_binary(L);

string_value(N) when is_integer(N) ->
    list_to_binary(integer_to_list(N));

string_value(B) when is_binary(B) ->
    B;
string_value(B) when is_atom(B) ->
    list_to_binary(atom_to_list(B)).

node_set_value(N) when is_list(N) ->
    N;
node_set_value(N) ->
    throw({node_set_expected,N}).

number_value(N) when is_integer(N) or is_float(N) ->
    N;

number_value(N) when is_binary(N)->
    String = binary_to_list(N),
    case erl_scan:string(String) of
        {ok, [{integer,1,I}],1} -> I;
        {ok, [{float,1,F}],1} -> F
    end;
    
number_value(N) ->
    number_value(string_value(N)).

boolean_value([]) ->
    false;
boolean_value([_|_]) ->
    true;
boolean_value(N) when is_number(N) ->
    N /= 0;
boolean_value(B) when is_binary(B) ->
    size(B) /= 0;
boolean_value(B) when B == true;
                      B == false ->
              B.
              
convert(Value,number) ->
    number_value(Value);
convert(Value,string) ->
    string_value(Value);
convert(Value,node_set) ->
    node_set_value(Value).
