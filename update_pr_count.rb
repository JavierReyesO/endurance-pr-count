# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'jwt' # https://rubygems.org/gems/jwt

# Private key contents
# private_pem = File.read('endurance-pr-count.2024-07-25.private-key.pem')
github_app_client_id = ARGV[0]
installation_id = ARGV[1]
private_pem = ARGV[2]
private_key = OpenSSL::PKey::RSA.new(private_pem)

# Generate the JWT
payload = {
  iat: Time.now.to_i - 60,
  exp: Time.now.to_i + (10 * 60),
  # GitHub App's client ID
  iss: github_app_client_id
}

jwt = JWT.encode(payload, private_key, 'RS256')

obtain_token_url = URI("https://api.github.com/app/installations/#{installation_id}/access_tokens")
headers = {
  'Accept' => 'application/vnd.github+json',
  'Authorization' => "Bearer #{jwt}",
  'X-GitHub-Api-Version' => '2022-11-28'
}

http = Net::HTTP.new(obtain_token_url.host, obtain_token_url.port)
http.use_ssl = true

request = Net::HTTP::Post.new(obtain_token_url)
headers.each { |key, value| request[key] = value }

response = http.request(request)
token = JSON.parse(response.body)['token']

obtain_last_pr_url = URI('https://api.github.com/repos/MigranteSF/endurance/pulls?state=all&sort=created&direction=desc&per_page=1')
headers = {
  'Accept' => 'application/vnd.github+json',
  'Authorization' => "Bearer #{token}",
  'X-GitHub-Api-Version' => '2022-11-28'
}

http = Net::HTTP.new(obtain_last_pr_url.host, obtain_last_pr_url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(obtain_last_pr_url)
headers.each { |key, value| request[key] = value }

response = http.request(request)
last_pr = JSON.parse(response.body)[0]

last_pr_number = last_pr['number']
puts last_pr_number

File.open('pr_count.txt', 'w') do |file|
  file.write(last_pr_number.to_s)
end
