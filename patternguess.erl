% This is the program file for the pattern guessing game.

-module(patternguess).
-import(rand, [uniform/1]).
-export([welcome/0, rules/0, get_fibonacci_pattern/0, get_even_pattern/0, get_odd_pattern/0, get_random_pattern/0, blank_pattern/1, get_random_unique_indices/2, random_indices/3, 
blank_numbers/2, get_user_guess/0, game_loop/2, validate_guess/2, check_guess/3, main/0]).

% Function to print a welcome message to the player.
welcome() ->
    io:format("Welcome to the Pattern Guessing Game!~n"),
    io:format("~n").

% Tell the user about the game
rules() ->
    io:format("You will be shown a random number pattern. The goal is to guess the missing numbers.~n"),
    io:format("Enter your guesses in the format: 'x, x, x, x, etc.'.~n").

% Define some patterns
get_fibonacci_pattern() ->
    [1, 2, 3, 5, 8, 13, 21, 34, 55, 89].
get_even_pattern () ->
    [2, 4, 6, 8, 10, 12, 14, 16, 18, 20].
get_odd_pattern() ->
    [1, 3, 5, 7, 9, 11, 13, 15, 17, 19].


% Get random pattern from the ones above.
get_random_pattern() ->
    % Create the list of patterns to get a random one from.
    Patterns = [
        #{type => fibonacci, pattern => get_fibonacci_pattern()},
        #{type => even, pattern => get_even_pattern()},
        #{type => odd, pattern => get_odd_pattern()}
    ],
    lists:nth(rand:uniform(length(Patterns)), Patterns).
% Blank numbers from the pattern for the user to guess.
blank_pattern(Pattern) ->
    % Generate random indices to make blank.
    BlankedIndices = get_random_unique_indices(4, length(Pattern)),

    % Blank out the numbers at those indices.
    BlankedPattern = blank_numbers(Pattern, BlankedIndices, 1, []),

    % Return the blanked pattern.
    BlankedPattern.

get_random_unique_indices(Count, Max) ->
    random_indices(Count, Max, []).
    
random_indices(0, _Max, Acc) ->
    lists:reverse(Acc);
random_indices(Count, Max, Acc) ->
    Index = rand:uniform(Max),
    case lists:member(Index, Acc) of
        true -> random_indices(Count, Max, Acc);
        false -> random_indices(Count - 1, Max, [Index | Acc])
    end.


blank_numbers(Pattern, Indices) when length(Indices) =:= 4 ->
    blank_numbers(Pattern, Indices, 1, []).
    
blank_numbers([], _Indices, _Index, Acc) ->
    lists:reverse(Acc);
    
blank_numbers([_ | Rest], [Index | Indices], Index, Acc) ->
    blank_numbers(Rest, Indices, Index + 1, ["_," | Acc]);
    
blank_numbers([_ | Rest], [Index | Indices], Index, Acc) ->
    blank_numbers(Rest, Indices, Index + 1, ["_," | Acc]);
    
blank_numbers([Item | Rest], Indices, Index, Acc) ->
    blank_numbers(Rest, Indices, Index + 1, [Item | Acc]).

get_user_guess() ->
    case io:read("Guess: ") of
        {ok, Guess} ->
            % Remove trailing period, any whitespace, and split by comma
            TrimmedGuess = string:strip(Guess, both, $\s),
            TrimmedGuessWithoutPeriod = string:strip(TrimmedGuess, right, $.),
            Tokens = string:tokens(TrimmedGuessWithoutPeriod, ","),
            GuessList = lists:map(fun(Number) -> list_to_integer(Number) end, Tokens),
            io:format("Received Input: ~s~n", [TrimmedGuessWithoutPeriod]),
            io:format("Parsed Input: ~p~n", [GuessList]),
            GuessList;
        {error, Reason} ->
            io:format("Error reading input: ~p~n", [Reason]),
            get_user_guess()  % Retry reading input
    end.

% parse_guess(GuessLine) ->
%     TrimmedGuess = string:strip(GuessLine, both, $\n),
%     Tokens = string:tokens(TrimmedGuess, ", "),
%     [string:to_integer(Token) || Token <- Tokens].

game_loop(Pattern, BlankedPattern) ->
    Guess = get_user_guess(),
    case validate_guess(Pattern, Guess) of
        correct ->
            io:format("Congratulations! You guessed the pattern correctly.~n");
        incorrect ->
            io:format("Incorrect guess. Try again.~n"),
            game_loop(Pattern, BlankedPattern)
    end.

validate_guess(Pattern, Guess) ->
    case check_guess(Pattern, Guess, 0) of
        correct ->
            if
                length(Guess) =:= length(Pattern) ->
                    correct;
                true ->
                    io:format("Incorrect guess. The guess should contain exactly ~p numbers. Try again.~n", [length(Pattern)]),
                    incorrect
            end;
        incorrect ->
            io:format("Incorrect guess. Try again.~n"),
            incorrect
    end.

check_guess([], [], 0) -> correct;
check_guess([], [], _) -> incorrect;
check_guess([PatternNum | PatternRest], [GuessNum | GuessRest], Index) when Index < 4, PatternNum == GuessNum -> 
    check_guess(PatternRest, GuessRest, Index + 1);
check_guess(_, _, _) -> incorrect.

main() ->
    welcome(),
    rules(),
    % Get the random pattern.
    RandomPatternMap = get_random_pattern(),
    RandomPatternList = maps:get(pattern, RandomPatternMap),
    io:format("Test: ~p~n", [RandomPatternList]),

    % Blank the generated pattern for the user to guess.
    BlankedPattern = blank_pattern(RandomPatternList),
    io:format("Fill in the missing numbers from the following: ~p~n", [BlankedPattern]),


    % Start a loop for the user to guess.
    game_loop(RandomPatternList, BlankedPattern).
