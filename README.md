# Typepipe

A small Spotlight-like application for MacOS that accepts stdin and outputs text to stdout. Convenient for usage with for example translation apps or similar.

Note: This is an internal tool and it comes with no guarantees or promises whatsoever.

![Alt image of the Typepipe application](./resources/Typepipe.png)

## Requirements

MacOS Sonoma+

## Installation

```bash
brew tap antonsivertsson/tap
brew install typepipe
```

## Usage

```bash
typepipe -a
```

## Options

`typepipe -a` - Open and close with animation

`typepipe -v` - Print the version and exit

`typepipe -p "Placeholder text"` - Opens application with placeholder text

`echo "put this text in typepipe" | typepipe` - pipes text from stdin into the text field

## Examples

```bash
# Convert number to hex and copy to clipboard on submit
typepipe -a -p 'Number to Hex' | xargs printf '#%X\n' | typepipe -a | pbcopy
```
