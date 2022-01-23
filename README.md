# WordleSolver

This is a very simple, CLI-based program to solve password/word games of the likes of 
[Wordle](https://www.powerlanguage.co.uk/wordle/). You will need to download a lexicon of words
for the language you want to play it with. For portuguese/br, you can find a great one [right here]
(https://www.ime.usp.br/~pf/dicios/index.html). I didn't include it in the project because even
though it is generated under a GPL licence, it has probably taken IME a lot of effort in order to
create it and they should be given credit where credit is due.

This software works in a very simple manner. Given a list of words, you can choose what you want
to do with it: you can convert all words to lowercase, filter valid/invalid words using regex, trim
whitespaces, convert diacritics into base ascii letters, etc. Currently, only Portuguese and English
languages processing are supported, but feel free to add more parsers under 
`language/your_language.ex`.

You will need Elixir/Erlang installed. To run the program, simply type into command line:

```bash
iex -S mix
```

In order to start using, let's say you want to play a game in PT-BR. If you donwloaded your
lexicon into `lexicons/pt_br.txt`, you can start a simple Wordle game by running:

```elixir
iex> words = "lexicons/pt_br.txt"
iex> |> Lexicon.import()        # reads a dict file and converts it into a list of strings
iex> |> Lexicon.trim()                     # trims all trailing whitespace
iex> |> Language.normalize(:pt_br)        # removes accents and diacritics
iex> |> Lexicon.filter_by_number_of_graphenes(5) # drops words with 6+ or 4- letters
iex> |> Lexicon.filter_valid()             # removes words that aren't exclusively lowcase a-z
iex> |> Grapheme.order_by_scores()       # calculates each word's score based on how many good letters it has and then sorts in desc score order
["rosea", "serao", "roias", "roais", "raios", "orais", "raies", "areis",
 "aires", "seria", "sarei", "reais", "eiras", "meiao", "moera", "aremo",
 "remoa", "aureo", "ecoai", "ecoar", "ateio", "terao", "rotea", "reato",
 "lerao", "ecoas", "coesa", "secao", "acoes", "escoa", "aceso", "estao",
 "tesao", "onera", "aloes", "leoas", "lesao", "odeia", "eroda", "rodea",
 "adore", "doera", "maior", "irmao", "roiam", "mario", "morai", "riamo",
 "raiou", "apeio", ...]
```

The first element from the list is always the best guess this program has for the current word.
Let's say you input that suggestion `ROSEA` and you get: green, yellow, black, black,
black. You should translate green to 2, yellow to 1 and black (or red) to 0. Our feedback is,
therefore, "21000", meaning that R is in the right place, O is correct but in the wrong place, and
S, E, A are not found in our word. Let's input this feedback:

```elixir
iex> Wordle.feedback(words, "21000")
["ruimo", "rimou", "ritmo", "ruido", "ruivo", "rifou", "rindo",
 "rirmo", "rublo", "rigor", "rumor", "rumou", "rugou", "rufou", "rubro"]
```

Again, `ruimo` is the best guess. Let's say, however, you don't like that suggestion very much, and
you think `ruido` is a better guess. If you try that word in the game and you get a feedback like
"22202", you pass the word of choice as third input to `Wordle.feedback/3`:

```elixir
iex> |> Wordle.feedback("ruido", "22202")
["ruimo", "ruivo"]
```
Now, there are only 2 possible words. Let's say `ruivo` is the right one:

```elixir
iex> |> Wordle.feedback("22222", "ruivo")
["ruivo"]
```

And that's it!

You can also invoke `Wordle.solve/2` to check how many attempts it takes for the software to find
your chosen word.
