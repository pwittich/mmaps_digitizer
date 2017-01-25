var express = require('express');
var app = express();
var router = express.Router();

router.use(function(req, res, next) {
	console.log(req.method, req.url);

	next();
});

router.use(express.static(__dirname + '/public'));

app.use('/', router);

app.listen(8081, function() {
	console.log('Listening in port 8081...');
});

