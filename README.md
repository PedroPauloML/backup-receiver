# Backup Receiver

This application is a simple way to send especifics data from server to localhost, whithout .dump or
similars backups. This application work with data format JSON.

## Prerequisites

- Sinatra: `gem install sinatra`
- Ngrok: (https://ngrok.com/download)[https://ngrok.com/download].

## Getting started

First, run the sinatra server: `path/to/application ruby app.rb`.

Then, run ngrok server: `path/to/application ./ngrok http 3000`

Send data to route of ngrok with the URI `/backups`, like this:

```ruby
# Ruby Language

require 'net/http'
require 'net/https' # for ruby 1.8.7
require 'json'

data = JSON.parse({
  data: {
    filename: "Example",
    key1: "value1",
    key2: "value2",
  }.to_json
}.to_json)

ngrok_route = "[ngrok route]"

url = URI.parse(ngrok_route + "/backups")
req = Net::HTTP::Post.new(url.request_uri)
req.set_form_data(data)

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = (url.scheme == "https")

response = http.request(req)

if response.code == "200"
  body = JSON.parse(response.body)
  `open #{ngrok_route + body["file_uri"]}`
else
  puts response.body
end
```