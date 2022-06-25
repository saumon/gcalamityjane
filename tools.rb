module Tools

  module_function

  # For terminal coloration...
  def black(str) = "\e[30m#{str}\e[0m"
  def red(str) = "\e[31m#{str}\e[0m"
  def green(str) = "\e[32m#{str}\e[0m"
  def brown(str) = "\e[33m#{str}\e[0m"
  def blue(str) = "\e[34m#{str}\e[0m"
  def magenta(str) = "\e[35m#{str}\e[0m"
  def cyan(str) = "\e[36m#{str}\e[0m"
  def gray(str) = "\e[37m#{str}\e[0m"

  def bg_black(str) = "\e[40m#{str}\e[0m"
  def bg_red(str) = "\e[41m#{str}\e[0m"
  def bg_green(str) = "\e[42m#{str}\e[0m"
  def bg_brown(str) = "\e[43m#{str}\e[0m"
  def bg_blue(str) = "\e[44m#{str}\e[0m"
  def bg_magenta(str) = "\e[45m#{str}\e[0m"
  def bg_cyan(str) = "\e[46m#{str}\e[0m"
  def bg_gray(str) = "\e[47m#{str}\e[0m"

  def bold(str) = "\e[1m#{str}\e[22m"
  def italic(str) = "\e[3m#{str}\e[23m"
  def underline(str) = "\e[4m#{str}\e[24m"
  def blink(str) = "\e[5m#{str}\e[25m"
  def reverse_color(str) = "\e[7m#{str}\e[27m"

  def no_colors(str) = str.gsub(/\e\[\d+m/, '')
end
