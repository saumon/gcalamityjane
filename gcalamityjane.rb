# frozen_string_literal: true

$LOAD_PATH << File.dirname(__FILE__)

require 'gcal_api_manager'

# Gcalamityjane
class Gcalamityjane
  def initialize
    gcal_api_manager = GcalApiManager.new
    gcal_api_manager.printTodaysEvents
  end
end

# Go go go!
Gcalamityjane.new
