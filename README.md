# NAME

trrr - search torrents 

# DESCRIPTION

CLI tool to search torrents. Results are sorted by number of seeders and each is mapped to key. Pressing the key with assigned letter will open magnet link in your default client. On iOS, magnet link is placed into clipboard.

# INSTALLATION

```
# switch to root
# install dependency module URI::Encode
cpan URI::Encode
# install trrr
git clone https://github.com/z448/trrr && cd trrr
perl Makefile.PL
make
make install
```

# USAGE

Search with as many parameters as needed. Uses KAT by default, `-P` will switch to TPB.

> `trrr keyword1 keyword2 keywordN`
>
> `trrr keyword1 keyword2 keywordN -P`

\_

On Linux, start it without any parameter and it'll use clipboard content as keywords. ( needs 'xclip' or 'xsel' to be installed )

> `trrr`

\_

Limit results which have at least 100 seeders.

> `trrr keyword1 keyword2 keywordN -100`

\_

To get another torrent from previous search add key as parameter. This is mandatory on Windows running 'Git/Bash for Windows' where you have to specify key on CLI upfront.

> `trrr keyword1 keyword2 keywordN -b`

\_

See this perdoc.

> `trrr -h`

# AUTHOR

Zdenek Bohunek. <zdenek@cpan.org>

App::Trr::HotKey is taken from StackOverflow post by brian d foy

# COPYRIGHT AND LICENSE

Copyright 2016 by Zdenek Bohunek

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
