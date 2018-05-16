require 'rack'

app = proc do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  # puts req.attributes
  res.write(req.path)
  res.write('<table>')
  res.write('<tr><th>key</th><th>value</th></tr>')
  req.env.sort_by{|k,v|v.to_s.length}.each do |k,v|
    res.write('<tr>')
      res.write('<td>')
      res.write("<strong>#{k}</strong>")
      res.write('</td>')
      res.write('<td>')
      res.write("#{v}")
      res.write('</td>')
    res.write('</tr>')
  end
  res.write('</table>')

  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3001
)
