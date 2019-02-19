
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var morgan = require('morgan');
var methodOverride = require('method-override');
var errorhandler = require('errorhandler')

var app = express();

// all environments
app.set('port', process.env.PORT || 8081);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(methodOverride());
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(errorhandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/youtube_mp3/:youtube_video_id', routes.youtube_mp3);

app.get('/', routes.index);
app.get('/', routes.index);
app.get('/', routes.index);
app.get('/', routes.index);
app.get('/', routes.index);
app.get('/', routes.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});


