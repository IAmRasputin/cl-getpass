# cl-getpass

An attempt to replicate Python's getpass functionality, allowing CLI users
to enter secrets (like passwords) without echoing them to their terminal's
history, and without needing too much familiarity with termios.

Currently supports SBCL, CCL, Allegro, and ECL.  And a few others.

Eventually, it would be nice for this to work in as many places as possible,
like SLIME.

## License

MIT
