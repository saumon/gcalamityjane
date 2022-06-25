# frozen_string_literal: true

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
CREDENTIALS_PATH = "#{__dir__}/conf/credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "#{__dir__}/conf/token.yaml".freeze
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

# For terminal coloration...
class String
  def black() = "\e[30m#{self}\e[0m"
  def red() = "\e[31m#{self}\e[0m"
  def green() = "\e[32m#{self}\e[0m"
  def brown() = "\e[33m#{self}\e[0m"
  def blue() = "\e[34m#{self}\e[0m"
  def magenta() = "\e[35m#{self}\e[0m"
  def cyan() = "\e[36m#{self}\e[0m"
  def gray() = "\e[37m#{self}\e[0m"

  def bg_black() = "\e[40m#{self}\e[0m"
  def bg_red() = "\e[41m#{self}\e[0m"
  def bg_green() = "\e[42m#{self}\e[0m"
  def bg_brown() = "\e[43m#{self}\e[0m"
  def bg_blue() = "\e[44m#{self}\e[0m"
  def bg_magenta() = "\e[45m#{self}\e[0m"
  def bg_cyan() = "\e[46m#{self}\e[0m"
  def bg_gray() = "\e[47m#{self}\e[0m"

  def bold() = "\e[1m#{self}\e[22m"
  def italic() = "\e[3m#{self}\e[23m"
  def underline() = "\e[4m#{self}\e[24m"
  def blink() = "\e[5m#{self}\e[25m"
  def reverse_color() = "\e[7m#{self}\e[27m"
end

def no_colors
  gsub(/\e\[\d+m/, '')
end

# puts "I'm back green".bg_green
# puts "I'm red and back cyan".red.bg_cyan
# puts "I'm bold and green and backround red".bold.green.bg_red

def in_event?(event, date_now)
  event_start = event.start.date || event.start.date_time
  event_end = event.end.date || event.end.date_time
  date_now_hm = date_now.hour * 100 + date_now.min
  event_start_hm = event_start.hour * 100 + event_start.min
  event_end_hm = event_end.hour * 100 + event_end.min

  date_now.year == event_start.year && date_now.month == event_start.month && date_now.day == event_start.day &&
    date_now_hm >= event_start_hm && date_now_hm <= event_end_hm
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

puts "Now it\'s #{date_now.strftime('%H:%M').red}, today\'s events:"
puts 'No events found' if response.items.empty?
response.items.each do |event|
  event_start = event.start.date || event.start.date_time
  event_end = event.end.date || event.end.date_time

  if in_event? event, date_now
    print '>> '.bold.red
    print event_start.strftime('%H:%M').bold.red
    print ' -> '.bold.red
    print event_end.strftime('%H:%M').bold.red
    print ' '
    puts event.summary.bold.red
  else
    print ' - '
    print event_start.strftime('%H:%M').green
    print ' -> '.green
    print event_end.strftime('%H:%M').green
    print ' '
    puts event.summary
  end
end
