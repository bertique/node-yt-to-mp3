{spawn, exec} = require 'child_process'
request = require 'request'
fs = require 'fs'
musiccache = "music_cache/"

exports.index = (req, res) ->
	res.render('index', { title: 'Express' })
	  
exports.youtube_mp3 = (req, res) ->
  res.setHeader('Content-Type','audio/x-mpeg')
  if(fs.existsSync(musiccache+"#{req.params.youtube_video_id}.mp3"))
   stat = fs.statSync(musiccache+"#{req.params.youtube_video_id}.mp3")
   if(req.headers.range)
    console.log("Found range header : "+req.headers.range)

    range = req.headers.range
    parts = range.replace("bytes=", "").split("-")
    partialstart = parts[0]
    partialend = parts[1]
    total = stat.size
    start = parseInt(partialstart, 10)
    end = if partialend then parseInt(partialend, 10) else total-1
 
    if (start > end) then throw new Error('whoops')
    header = {};
    header["Content-Range"] = "bytes " + start + "-" + end + "/" + (total)
    header["Accept-Ranges"] = "bytes"
    header["Content-Length"]= (end-start)+1
    header['Transfer-Encoding'] = 'chunked'
    header["Connection"] = "close"
    res.writeHead(206, header)

    readStream = fs.createReadStream(musiccache+"#{req.params.youtube_video_id}.mp3", { flags: 'r', start: start, end: end})
    readStream.pipe(res)
  
   else
    readStream = fs.createReadStream(musiccache+"#{req.params.youtube_video_id}.mp3")  
    res.setHeader('Content-Length',stat.size)
    readStream.pipe(res)
  else
   # Spawn a child process to obtain the URL to the FLV
   console.log("Yimbo I'm starting")
   youtube_dl_url_child = exec "python youtube-dl.py --no-check-certificate --simulate --get-url http://www.youtube.com/watch?v=#{req.params.youtube_video_id}", (err, stdout, stderr) ->
    # Converting the buffer to a string is a little costly so let's do it upfront
    console.log("Yimbo I'm doing 1")
    youtube_dl_url = stdout.toString()
    # there's a trailing '\n' returned from youtube-dl, let's cut it off
    youtube_dl_url = youtube_dl_url.substring(0, youtube_dl_url.length-1)       
    # Create an ffmpeg process to feed the video to.
    console.log("Yimbo I'm doing 2 "+youtube_dl_url)
    ffmpeg_child = spawn "ffmpeg", ['-i', 'pipe:0', '-acodec', 'libmp3lame','-f', 'mp3', '-']
    # Setting up the output pipe before we set up the input pipe ensures wedon't loose any data.
    ffmpeg_child.stdout.pipe(res)
    console.log("Yimbo I'm doing 3")
    writable = fs.createWriteStream(musiccache+"#{req.params.youtube_video_id}.mp3")
    ffmpeg_child.stdout.pipe(writable) 
    console.log("Yimbo I'm doing 4")
    # GET the FLV, pipe the response's body to our ffmpeg process.
    request({url: youtube_dl_url, headers: {'Youtubedl-no-compression':'True'}}).pipe(ffmpeg_child.stdin)
    