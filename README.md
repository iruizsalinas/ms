# ms

Tiny millisecond conversion utility, inspired by the npm [ms](https://www.npmjs.com/package/ms) package.

## Why

Elixir's `:timer` module works but only accepts numbers:

```elixir
:timer.hours(2)    #=> 7200000
:timer.minutes(30) #=> 1800000
```

`ms` lets you use human-readable strings, which is nicer for configs, timeouts, and user input:

```elixir
Ms.parse("2h")      #=> 7200000
Ms.parse("1h 30m")  #=> 5400000
Ms.parse("7 days")  #=> 604800000
```

## Installation

Add `ms` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ms, "~> 1.0"}
  ]
end
```

## Usage

### Parsing

```elixir
Ms.parse("2h")      #=> 7200000
Ms.parse("1.5h")    #=> 5400000
Ms.parse("1h 30m")  #=> 5400000
Ms.parse("100")     #=> 100
Ms.parse("nope")    #=> :error
Ms.parse!("2h")     #=> 7200000
```

### Formatting

```elixir
Ms.format(7200000)              #=> "2h"
Ms.format(7200000, long: true)  #=> "2 hours"
Ms.format(60000)                #=> "1m"
```

### Supported units

| Unit         | Short | Aliases                         |
|--------------|-------|---------------------------------|
| milliseconds | ms    | ms, msec, msecs, millisecond(s) |
| seconds      | s     | s, sec, secs, second(s)         |
| minutes      | m     | m, min, mins, minute(s)         |
| hours        | h     | h, hr, hrs, hour(s)             |
| days         | d     | d, day(s)                       |
| weeks        | w     | w, wk, wks, week(s)            |
| months       | mo    | mo, month(s)                    |
| years        | y     | y, yr, yrs, year(s)             |

