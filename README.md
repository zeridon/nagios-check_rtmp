check_rtmp
================

nagios plugin for checking rtmp streams

It uses the rtmpdump (http://rtmpdump.mplayerhq.hu/) utility for connecting to an rtmp stream for some seconds
and determine if it's working or not.

Notes:
  - The plugin leaves temporary files under /tmp
  - The current is the first version, so test it and fork it.
