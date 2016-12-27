# razerd
Application profile-based Razer Chroma keyboard configurator for Linux.

## Dependencies
Requires [razer-drivers](https://github.com/terrycain/razer-drivers).

## Installation

    # make install

Then configure your window manager (or similar) to run `/usr/local/bin/razerd` at login.

## Configuration

Configuration is done using files in the ~/.razerd/ directory (there's
no system-wide configuration yet). The only two files required in this
directory are `razerd.cfg` and `default.cm`.

The configuration is split into the profile list (`razerd.cfg`) and
the individual color maps (`*.cm`.)

### `razerd.cfg` format

`razerd.cfg` consists of lines formatted as follows:

    regex:colorscheme

The regular expressions here are interpreted as in Perl. Any window
with a title matching `regex` will have `colorscheme` applied. If
multiple `regex`es match, the first match is used. If none match,
`default.cm` is used (the default `*:default.cm` entry is **not**
required).

### colormap format

A colormap file consists of several individual lines, each of which
may be a variable definition, a color assignment, or an include statement.

Variables may be defined as key positions, lists of variables, or
colors. Their syntax is as follows:

    variable = x : y                   # key position
    variable = variable (variable) ... # list
    variable = \[red green blue\]      # color

By convention, color variables are capitalized.

Color assignments may assign specific RGB colors or variables. They
look like this:

    variable \[red green blue\]  # RGB
    variable #variable           # color variable

Include statements are simple:

    include file.cm

### Example configuration notes

The example configuration given in `example-config/` can be installed
with `make copy-config` (as local user). It includes a `razerd.cfg`,
`default.cm`, and some other colormaps useful in creating your own
configurations. The file `keys.cm` contains key mappings valid for (at
least) the Razer Blade QHD, and `colors.cm` contains some basic color
definitions. The idea behind `colors.cm` is that you can quite easily
set up, and later change, a consistent color scheme by altering this
file.

## Bugs

This will probably not work on anything that isn't a Blade QHD,
because I don't have any other Chroma devices to test on.
    
    
