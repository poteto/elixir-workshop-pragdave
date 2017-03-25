# Hangman—Running the Dictionary as an Agent

Have a look at the code that implements the dictionary
(`lib/hangman/dictionary.ex`). Right now it is a simple module. When
you call either of its external API functions (`random_word` or
`words_of_length`), it first reads the word list from disk, then
selects either a random word or all words of a certain length. It has
no ability to store any state, and therefore has to read the word list
afresh on each call.

Your mission is to change `dictionary.ex` so that it runs as a
separate process, holding the wordlist as state. This means it only
has to read it once, when it starts up.

Although you _could_ write this using `spawn`, in the real world we'd
exploit the convenience of the built-in libraries. In this case, I'd
like you to keep the word list in an Agent, and have the `random_word`
and `words_of_length` functions invoke this agent.

Because the agent needs to be started, you'll need to implement a new
function, `start_link`. This will take an optional parameter, the name
of the word list. It will create an Agent containing the words in that
file. This agent will have the name `:dictionary`. I like to keep
things like server names in module attributes, and you'll find I've
already added

    @me :dictionary
    
to the Dictionary module.

You'll find that the tests, as well as HumanPlayer and ComputerPlayer,
have been updated to call `Dictionary.start_link` before they make use
of the dictionary API.

