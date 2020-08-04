require 'sinatra'
require 'json'
require 'yaml/store'
require 'i18n'
require 'rubygems'
require 'active_support/all'

# Routes
get '/' do
  return "Backup Receiver"
end

post '/backups' do
  # PARAMETERS STRUCTURE
  #
  # {
  #   "data": {
  #     "filename": "...",
  #     "key1": "value1",
  #     "key2": "value2",
  #   }
  # }

  # CALLING
  # require 'net/http'
  # require 'net/https' # for ruby 1.8.7
  # require 'json'

  # json = JSON.parse({
  #   data: {
  #     filename: "data",
  #     data: data,
  #   }.to_json
  # }.to_json)

  # url = URI.parse(ngrok_route + "/backups")
  # req = Net::HTTP::Post.new(url.request_uri)
  # req.set_form_data(json)
  # http = Net::HTTP.new(url.host, url.port)
  # http.use_ssl = (url.scheme == "https")

  # response = http.request(req)

  content_type :json

  puts params.inspect
  if params["data"].present?
    data = JSON.parse(params["data"])
    if data["filename"].present?
      directory_name = File.join(File.dirname(__FILE__), "backups")
      Dir.mkdir(directory_name) unless File.exists?(directory_name)

      data_file_name = data["filename"].parameterize
      file_name = "#{Time.now.strftime("%y%m%d%H%M%S")}-#{data_file_name}.json"
      file_path = File.join(
        File.dirname(__FILE__),
        "backups",
        file_name
      )

      data.delete("filename")

      data = { data_file_name.to_s => data }

      begin
        File.open(file_path, 'wb') do |f|
          f.write(data.to_json)
        end

        return { result: "Successfully", file_uri: "/backups/#{file_name}" }.to_json
      rescue Exception => ex
        halt(500, ex)
      end
    else
      halt(
        400,
        "The JSON should has a parameter key called \"filename\" with a name to use as file name."
      )
    end
  else
    halt(
      400,
      "The data should be send into a parameter key called \"data\"."
    )
  end
end

get '/backups/:id' do
  content_type :json

  directory_name = File.join(File.dirname(__FILE__), "backups", params[:id])
  if File.exists?(directory_name)
    f = File.read(directory_name)
    return f
  else
    halt(404, "File not found")
  end
end