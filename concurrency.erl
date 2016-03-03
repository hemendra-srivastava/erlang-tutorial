-module(concurrency).

-compile(export_all).

%F = fun() -> 
%            2 + 2 end.

% spawn(fun() -> io:format("~p~n",[2 + 2]) end).

% G = fun(X) -> timer:sleep(10), io:format("~p~n", [X]) end.

% [spawn(fun() -> G(X) end) || X <- lists:seq(1,10)].

% self().

% self() ! hello.

% messages are always ordered.

dolphin1() ->    
    receive
        do_a_flip ->    
            io:format("How about no?~n");
        fish ->
            io:format("So long and thanks for all the fish!~n");
        _ ->
            io:format("Heh, we're smarter than you humans.~n")
end.

% Pid = spawn(concurrency, dolphin1, [])
% Pid ! fish.
% Pid ! flip.
% Pid ! "Aw So Cute".

dolphin2() ->
    receive
        {From, do_a_flip} ->
            From ! "How about no?";
        {From, fish} ->
            From ! "So long and thanks for all the fish!";
        _ ->
            io:format("Heh, we're smarter than you humans.~n")
    end.

% 11> c(dolphins).
% {ok,dolphins}
% 12> Dolphin2 = spawn(dolphins, dolphin2, []).
% <0.65.0>
% 13> Dolphin2 ! {self(), do_a_flip}.         
% {<0.32.0>,do_a_flip}
% 14> flush().
% Shell got "How about no?"
% ok

dolphin3() ->
    receive
        {From, do_a_flip} ->
            From ! "How about no?",
            dolphin3();
        {From, fish} ->
            From ! "So long and thanks for all the fish!";
        _ ->
            io:format("Heh, we're smarter than you humans.~n"),
            dolphin3()
    end.
