width = 800
height = 800

types = ['followers', 'following', 'common']

fill = d3.scale.category10()

nodes = []

total = window.twitinject.following.length +
	window.twitinject.followers.length +
	window.twitinject.common.length

if total < 500 or (window.twitinject.common.length < 500 and window.twitinject.following.length < 200)
	nodes = nodes.concat window.twitinject.following.map (user) ->
		{type: 'following', name: user.screen_name}
else
	nodes.push {type: 'following', name: "#{window.twitinject.following.length} others"}


if total < 500 or (window.twitinject.common.length < 500 and window.twitinject.followers.length < 200)
	nodes = nodes.concat window.twitinject.followers.map (user) ->
		{type: 'followers', name: user.screen_name}
else
	nodes.push {type: 'following', name: "#{window.twitinject.followers.length} others"}

nodes = nodes.concat window.twitinject.common.map (user) ->
	{type: 'common', name: user.screen_name}

svg = d3.select('body').append 'svg'
	.attr 'width', width
	.attr 'height', height

force = d3.layout.force()
	.nodes nodes
	.size [width, height]
	.start()

node = svg.selectAll '.node'
	.data nodes
	.enter().append 'g'
	.attr 'class', 'grup'
	.call force.drag
	.on 'mousedown', () -> d3.event.stopPropagation()

node.append 'circle'
	.attr 'class', 'node'
	.attr 'cx', 0
	.attr 'cy', 0
	.attr 'r', 8
	.style 'fill', (d) -> fill types.indexOf d.type
	.style 'stroke', (d) -> d3.rgb(fill types.indexOf d.type).darker 1

node.append 'a'
	.attr 'xlink:href', (d) -> "/?name=#{d.name}"
	.append 'text'
		.attr 'class', 'text'
		.attr 'fill', (d) -> d3.rgb(fill types.indexOf d.type).darker 2
		.attr 'font-family', 'sans-serif'
		.attr 'font-weight', 'bold'
		.attr 'font-size', '12px'
		.attr 'dx', -4
		.attr 'dy', '0.35em'
		.text (d) -> "@#{d.name}"

svg.style 'opacity', 1e-6
	.transition()
		.duration(1000)
		.style 'opacity', 1

force.on 'tick', (e) ->
	node.attr 'transform', (d) ->
		"translate(#{d.x}, #{d.y})"

d3.select('body').on 'mousedown', () ->
	nodes.forEach (o, i) ->
		o.x += (Math.random() - .5) * 40
		o.y += (Math.random() - .5) * 40
	force.resume()