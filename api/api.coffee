restify = require 'restify'
mongojs = require 'mongojs'
db = mongojs 'directory'
employees = db.collection 'employees'
items_per_page = 40

server = restify.createServer()

server.use restify.queryParser()
# server.use restify.jsonp()

server.get '/', (req, res, next) ->
	res.send
		status: 1
	next()

server.get '/employees.json', (req, res, next) ->
	employees.find().count (err, count) ->
		data = 
			total: count
			items: null

		if req.params.page
			data.page = parseInt req.params.page
		else
			data.page = 1

		options = {_id: 0, limit: items_per_page, skip: (data.page - 1) * items_per_page}

		employees.find {}, options, (err, docs) ->
			if docs
				data.items = docs
			res.send data 

	next()

server.get '/employees/:name', (req, res, next) ->
    uid = req.params.name.replace '.json', ''

    options = _id: 0
    employees.findOne {uid: uid}, options, (err, doc) ->
        res.send doc

    next()

server.get '/groups/:name', (req, res, next) ->
    uid = req.params.name.replace '.json', ''

    options = _id: 0
    data =
        total: 0
        members: null
    employees.findOne {uid: uid}, options, (err, doc) ->
        name = doc.preferred_name

        employees.find {manager: name}, options, (err, docs) ->
            if docs
                data.total = docs.length
                data.members = docs
            res.send data

    next()

server.listen 6080, ->
    console.log 'ready on %s', server.url