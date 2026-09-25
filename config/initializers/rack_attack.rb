# frozen_string_literal: true

require 'rack/attack'

Rack::Attack.blocklist_ip '40.76.0.0/14'
Rack::Attack.blocklist_ip '207.46.0.0/19'
Rack::Attack.blocklist_ip '52.160.0.0/11'
Rack::Attack.blocklist_ip '157.55.0.0/16'
Rack::Attack.blocklist_ip '103.96.36.0/22'

Rack::Attack.blocklist('block access to WP related URLs') do |request|
  request.path.start_with? '/wp-admin'
  request.path.start_with? '/wp-content'
  request.path.include? '.php'
  request.path.include? 'wp-json'
end

Rack::Attack.blocklist('block access to cofiguration related urls') do |request|
  request.path.include? '.env'
end
