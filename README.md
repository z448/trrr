# NAME

trrr - search torrents 

# VERSION

This document describes trrr version 0.23

# GIF

![trrr](https://raw.githubusercontent.com/z448/trrr/master/trrr.gif)

# DESCRIPTION

Tool for searching torrents. Results are sorted by number of seeders and each is mapped to keyboard key. Pressing the key will open magnet link in your default torrent client. On iOS magnet link is placed into clipboard instead.

# INSTALLATION

On Debian/Ubuntu linux download .deb [release](https://github.com/z448/trrr/releases) and install.

```bash
sudo dpkg -i trrr_Linux.deb
```

On different linux or macOS, clone build and install.

```bash
sudo cpan URL::Encode JSON::PP
git clone https://github.com/z448/trrr
cd trrr
perl Makefile.PL
make
sudo make install
```

# USAGE

\- Search with as many keywords as needed.

> `trrr keyword1 keyword2 keywordN`

\- trrr uses source option from '~/.trrr' conf. To use different torrent source add one of the following options. 

> `-p` piratebay

> `-r` rarbg 
>
> `-y` yts
>
> `-k` kickasstorrents
>
> `-x` 1337x
>
> `-l` limetorrents

\- start it without any parameter and it'll use clipboard content as keywords. ( this needs 'xclip' or 'xsel' to be installed on Linux )

\- To automaticaly open some magnet link from results add its key -\[A-O\] as an option. 
  E.g: to open first (A) magnet link use following command.

> `trrr keyword1 keyword2 keywordN -A`

On Windows running 'Git/Bash for Windows' you have to specify key upfront so first make search without any option to see the results, then repeat the command and add key -\[A-O\] as an option. 

\- To see help use `-h` option

# AUTHOR

Zdenek Bohunek. <zdenek@cpan.org>

App::Trr::HotKey is taken from StackOverflow post by brian d foy

# COPYRIGHT AND LICENSE

Copyright 2016 by Zdenek Bohunek

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
