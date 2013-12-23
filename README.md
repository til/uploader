# Uploader

A self-contained web app that shows an upload form, and a continously
updated progress bar while an upload is active.

Written with the evented ruby web server [goliath][].

It is in use at the community radio station [o94][] to allow the
upload of sound files for preproduced radio shows, was written
specifically for their use case. I'm publishing it to github mostly
for reference and feedback.

It only allows files of certain types and within a size limit. Most
importantly with large files, in case of an invalid file, it aborts
with an error message early and does not have to wait until the file
is fully uploaded.

Uploads are put into slots which are defined by a numerical id.
Access is authenticated through a slot-specific token in the
URL. Other services can create authenticated URLs using a hashing
algorithm.

It assigns friendly filenames to make it easy to deal with the
uploaded files directly on the filesystem: they consist of the slot
id, an incremented number, and a normalized version of the user's
local filename. E.g. uploading `Foo Bar.MP3` to slot 1234 becomes
`1234_01_Foo_Bar.mp3` in the uploads directory.

Uploads are streamed directly to disk without being buffered in
memory.


## Installation

Make sure you have ruby >= 2.0 installed, then

    git clone
    cd uploader
    cat /dev/urandom | head | sha1sum > config/secret.txt
    bundle install
    bin/uploader -s

Then visit:

http://localhost:9000/

You'll need some trickery in order to be able to see an upload
form. Either create a valid token or disable authentication, check the
source.


## Notes

A restart currently kills all active uploads. This is not easy to fix.

Pedantic people may argue that the name `uploader` isn't correct since
it does not itself upload anything.


## Contact

Tilmann Singer <tils@tils.net>

Thanks for sponsoring goes to [o94][]


## Copyright

(C) Copyright 2013 Tilmann Singer <tils@tils.net>

All files licensed under AGPL v3 or any later version, see
http://www.gnu.org/licenses/agpl-3.0, except where stated otherwise
explicitely at the beginning of the file.

[goliath]: https://github.com/postrank-labs/goliath
[o94]: http://o94.at/
