# node-yt-to-mp3

**Proxy server converting YouTube videos to mp3s on the fly.**

I needed a web service that would take a YouTube video id and return an mp3 stream of the video.

It's based on the work of [Paul Bergeron](http://pauldbergeron.com/articles/streaming-youtube-to-mp3-audio-in-nodejs.html) with the addition of a simple cache and [HTTP byte range headers](http://en.wikipedia.org/wiki/Byte_serving).

## Usage
The server can easily be started using the command: node app.js

By default it's listening on port 8081. Requesting a stream is done by making a GET request to ip:port/youtube_mp3/[videoid]

example: localhost:8081/youtube_mp3/dQw4w9WgXcQ

The repository contains configuration files to easily run the server out of the box on [Heroku](http://heroku.com) as well as [AWS Beanstalk](http://aws.amazon.com/elasticbeanstalk/).

## Future work
- Improved caching: Currently the cache is never deleted. I added a script (clearMusicCache) that can be called as a cron job to clean the directory, but that's far from ideal

