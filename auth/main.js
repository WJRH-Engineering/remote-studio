const express = require('express')
const app = express()

const body_parser = require('body-parser')
app.use(body_parser.urlencoded({extended: true}))

// use redis to store valid streamkey, password combinations
const Redis = require('ioredis')
const data = new Redis()

data.sadd('keys', `connor.abcd`)

app.post('/auth', async function(req, res){
	console.log(req.body)
	streamkey = request.body.name
	password = request.body.password

	if(await data.sismember('keys', `${streamkey}.${password}`)){
		res.sendStatus(200)
	} else {
		res.sendStatus(404)
	}
})

app.listen(80, '0.0.0.0')
console.log('listening on port 80')
