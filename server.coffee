express = require 'express'
app = express()
twit = require 'twit'

t = new twit {
	consumer_key:					'1YBMowIMCMOg9FDsrjHqPscVh',
	consumer_secret:			'J8DD54p4bzjjHCJTzAmfWEtHkRLyPajZgcygk5gwIMsYuETzbz',
	access_token:					'213039395-NNe5fRWcZXJcORHb0qB4yvCTZxsyY6UVcz06Dwx1',
	access_token_secret:	'wrgpVsk3E5bafScyjRsRfvgyhUSd7v8KjG9qOWWpmmNmW'
}

app.get '/', (req, res) ->
	name = req.param 'name'
	console.log "PARAM NAME: #{name}"

	if name != ''
		followers = []
		following = []
		common = []

		f = (i) ->
			console.log 'API REQUEST: followers/list'
			t.get 'followers/list', {screen_name: name, count: 200, cursor: i, skip_status: true, include_user_entities: false}, (err, reply) ->
				if err
					console.log err
					res.render 'error', err
					i = 0
				else
					followers = followers.concat(reply.users)
					#i = 0
					i = reply.next_cursor
					if i is 0 then f2(-1) else f(i)

		f2 = (i) ->
			console.log 'API REQUEST: friends/list'
			t.get 'friends/list', {screen_name: name, count: 200, cursor: i, skip_status: true, include_user_entities: false}, (err, reply) ->
				if err
					console.log err
					res.render 'error', err
					i = 0
				else
					following = following.concat(reply.users)
					#i = 0
					i = reply.next_cursor
					if i is 0 then g() else f2(i)

		g = () ->
			#console.log 'FOLLOWING:'
			#for a in following
			#	console.log "\t #{a.screen_name}"

			#console.log 'FOLLOWERS:'
			#for a in followers
			#	console.log "\t #{a.screen_name}"

			al = following.length
			bl = followers.length
			for a in [0...al]
				for b in [0...bl]
					if following[a].id_str is followers[b].id_str
						console.log "COMMON: #{a}/#{al} = #{b}/#{bl} #{following[a].id_str}"
						following.splice(a, 1)
						common.push followers.splice(b, 1)[0]
						b--
						bl--
						a--
						al--
						break

			#console.log 'COMMON:'
			#for a in common
			#	console.log "\t #{a.screen_name}"
			console.log 'VIEW: RENDER home.jade'
			res.render 'home', {name: name, following: following, followers: followers, common: common}

		f(-1)

app.use express.static __dirname
app.set 'views', __dirname
app.set 'view engine', 'jade'

port = 80
app.listen port
console.log 'Express started on %d', port