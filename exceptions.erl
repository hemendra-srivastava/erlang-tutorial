-module(exceptions).

-compile(export_all).

myproc() ->
    timer:sleep(5000),
    exit(reason).

% 1> c(linkmon).
% {ok,linkmon}
% 2> spawn(fun linkmon:myproc/0).
% <0.52.0>
% 3> link(spawn(fun linkmon:myproc/0)).
% true
% ** exception error: reason

chain(0) ->
    receive
        _ ->
            ok
    after 2000 ->
            exit("chain dies here")
    end;
chain(N) ->
    Pid = spawn(fun() -> chain(N-1) end),
    link(Pid),
    receive
        _ ->
            ok
    end.

% 4> c(linkmon).              
% {ok,linkmon}
% 5> link(spawn(linkmon, chain, [3])).
% true
% ** exception error: "chain dies here"

% process_flag(trap_exit, true).






% 1> erlang:monitor(process, spawn(fun() -> timer:sleep(500) end)).
% #Ref<0.0.0.77>
% 2> flush().
% Shell got {'DOWN',#Ref<0.0.0.77>,process,<0.63.0>,normal}
% ok



start_critic() ->
    spawn(?MODULE, critic, []).

judge(Pid, Band, Album) ->

    Pid ! {self(), {Band, Album}},
    receive
        {Pid, Criticism} ->
            Criticism
    after 2000 ->

            timeout
    end.

critic() ->
    receive
        {From, {"Rage Against the Turing Machine", "Unit Testify"}} ->
            From ! {self(), "They are great!"};
        {From, {"System of a Downtime", "Memoize"}} ->
            From ! {self(), "They're not Johnny Crash but they're good."};
        {From, {"Johnny Crash", "The Token Ring of Fire"}} ->
            From ! {self(), "Simply incredible."};
        {From, {_Band, _Album}} ->
            From ! {self(), "They are terrible!"}
    end,
    critic().



start_critic2() ->
    spawn(?MODULE, restarter, []).

restarter() ->
    process_flag(trap_exit, true),
    Pid = spawn_link(?MODULE, critic, []),
    receive
        {'EXIT', Pid, normal} -> % not a crash
            ok;
        {'EXIT', Pid, shutdown} -> % manual termination, not a crash
            ok;
        {'EXIT', Pid, _} ->
            restarter()
    end.

restarter2() ->
    process_flag(trap_exit, true),
    Pid = spawn_link(?MODULE, critic, []),
    register(critic, Pid),
    receive
        {'EXIT', Pid, normal} -> % not a crash
            ok;
        {'EXIT', Pid, shutdown} -> % manual termination, not a crash
            ok;
        {'EXIT', Pid, _} ->
            restarter2()
    end.

judge2(Band, Album) ->
    Ref = make_ref(),
    critic ! {self(), Ref, {Band, Album}},
    Pid = whereis(critic),
    receive
        {Ref, Criticism} -> Criticism
    after 2000 ->
            timeout
    end.
