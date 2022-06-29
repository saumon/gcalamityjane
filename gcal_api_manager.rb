# frozen_string_literal: true

$LOAD_PATH << File.dirname(__FILE__)

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'
require 'tools'

# Google Calendar API Manager
class GcalApiManager
  include Tools

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'gcalamityjane'
  CREDENTIALS_PATH = "#{__dir__}/conf/credentials.json".freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = "#{__dir__}/conf/token.yaml".freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  def initialize
    @calendar_id = 'primary'
    @user_id = 'default'

    # Initialize the API
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

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
    credentials = authorizer.get_credentials @user_id
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts 'Open the following URL in the browser and enter the ' \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: @user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def in_event?(event, date_now)
    event_start = event.start.date || event.start.date_time
    event_end = event.end.date || event.end.date_time
    date_now_hm = date_now.hour * 100 + date_now.min
    event_start_hm = event_start.hour * 100 + event_start.min
    event_end_hm = event_end.hour * 100 + event_end.min

    date_now.year == event_start.year && date_now.month == event_start.month && date_now.day == event_start.day &&
      date_now_hm >= event_start_hm && date_now_hm <= event_end_hm
  end

  def printTodaysEvents
    # Fetch the events for the user
    date_now = DateTime.now
    date_min = DateTime.new(date_now.year, date_now.mon, date_now.day, 0, 0)
    date_max = DateTime.new(date_now.year, date_now.mon, date_now.day, 23, 59)

    response = @service.list_events(@calendar_id,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: date_min.rfc3339,
                                    time_max: date_max.rfc3339)

    print "Now it\'s #{bold red date_now.strftime('%H:%M')} (#{magenta date_now.strftime('%A %e %B %Y, W%W')})"
    puts ", today\'s events:"
    puts 'No events found' if response.items.empty?
    response.items.each do |event|
      event_start = event.start.date || event.start.date_time
      event_end = event.end.date || event.end.date_time

      if in_event? event, date_now
        print bold red '>> '
        print bold red event_start.strftime('%H:%M')
        print bold red ' -> '
        print bold red event_end.strftime('%H:%M')
        print ' '
        puts bold red event.summary
      else
        print ' - '
        print green event_start.strftime('%H:%M')
        print green ' -> '
        print green event_end.strftime('%H:%M')
        print ' '
        puts event.summary
      end
    end
  end
end
