require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
CREDENTIALS_PATH = __dir__ + '/conf/credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = __dir__ + '/conf/token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = 'default'
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

def str_green(str)
  "\033[32m#{str}\033[0m"
end

def str_red(str)
  "\033[31m#{str}\033[0m"
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Fetch the next 10 events for the user
calendar_id = 'primary'

date_now = DateTime.now
date_min = DateTime.new(date_now.year, date_now.mon, date_now.day, 0, 0)
date_max = DateTime.new(date_now.year, date_now.mon, date_now.day, 23, 59)

response = service.list_events(calendar_id,
                               single_events: true,
                               order_by: 'startTime',
                               time_min: date_min.rfc3339,
                               time_max: date_max.rfc3339)

puts "Now it\'s #{str_red(date_now.strftime('%H:%M'))}, today\'s events:"
puts 'No events found' if response.items.empty?
response.items.each do |event|
  start = event.start.date || event.start.date_time
  # puts "- #{event.summary} (#{start})"
  puts "- #{str_green(start.strftime('%H:%M'))} #{event.summary}"
end
