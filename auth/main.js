const express = require('express')
const app = express()

const body_parser = require('body-parser')
app.use(body_parser.urlencoded({extended: true}))

// use redis to store valid streamkey, password combinations
const Redis = require('ioredis')
const data = new Redis('redis')

const master_password = "hogghall"

function authenticate(mountpoint, password){
	if (password == master_password) return true
	return data.sismember('auth-tokens', `${mountpoint}:${password}`)
}

app.post('/auth_rtmp', async function(req, res){
	streamkey = req.body.name
	password = req.body.password

	if(await authenticate(streamkey, password)){
		res.sendStatus(200)
	} else {
		res.sendStatus(404)
	}
})

app.post('/auth_icecast', async function(req, res){
	// console.log(req.body)
	try {
		mountpoint = req.body.mount.replace('/','')
		password = req.body.pass
		valid = await authenticate(mountpoint, password)
	} catch(e){
		res.sendStatus(400)
		return
	}

	if(valid) {
		res.set('icecast-auth-user', 1)
		res.sendStatus(200)
	} else {
		res.sendStatus(400)
	}

})


app.listen(80, '0.0.0.0')
console.log('listening on port 80')
