%% -*- tab-width: 4;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ft=erlang ts=4 sw=4 et
%% Licensed under the Apache License, Version 2.0 (the "License"); you may not
%% use this file except in compliance with the License. You may obtain a copy of
%% the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
%% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
%% License for the specific language governing permissions and limitations under
%% the License.

%% @doc Library for PPSPP over UDP, aka Swift protocol
%%
%% This module implements a library of functions necessary to
%% handle the wire-protocol of PPSPP over UDP, including
%% functions for encoding and decoding messages.
%% @end

-module(channel_sup).
-include("swirl.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-behaviour(supervisor).

%% api
-export([start_link/0,
         start_child/1]).

%% callbacks
-export([init/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% api

-spec start_link() -> {ok, pid()} | ignore | {error, any()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

-spec start_child([ppspp_datagram:endpoint() |
                   ppspp_options:options()]) ->
    {error,_} | {ok, pid()}.
start_child([Peer_endpoint, Swarm_options]) ->
    supervisor:start_child(?MODULE, [Peer_endpoint, Swarm_options]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% callbacks

-spec init([]) -> {ok,{{simple_one_for_one, 10,60}, [supervisor:child_spec()] }}.

init([])->
    RestartStrategy = simple_one_for_one,
    MaxRestarts = 10,
    MaxSecondsBetweenRestarts = 60,
    Options = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    Restart = transient,
    Shutdown = 1000,
    Type = worker,

    Worker = {channel_worker, {channel_worker, start_link, []},
              Restart,
              Shutdown,
              Type,
              [channel_worker]},

    {ok, {Options, [Worker]}}.
