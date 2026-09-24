# frozen_string_literal: true

require 'rack/attack'

Rack::Attack.blocklist_ip '40.76.0.0/14'
Rack::Attack.blocklist_ip '207.46.0.0/19'
Rack::Attack.blocklist_ip '52.160.0.0/11'
Rack::Attack.blocklist_ip '157.55.0.0/16'

Rack::Attack.blocklist('block access to WP related URLs') do |request|
  request.path.start_with? '/wp-admin'
  request.path.start_with? '/wp-content'
  request.path.include? '.php'
  request.path.include? 'wp-json'
end

Rack::Attack.blocklist('block access to cofiguration related urls') do |request|
  request.path.include? '.env'
end

Rack::Attack.blocklisted_responder = lambda do |_request|
  [
    403,
    { 'Content-Type' => 'text/html' },
    File.read(Rails.root.join('public/403.html'))
  ]
end
