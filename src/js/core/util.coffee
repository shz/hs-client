
dep.require 'lib'
dep.provide 'util'


String.prototype.truncateWords = (number) ->
  return this.substr(0) if this.length <= 67

  words = this.substr(0, number).split(' ')

  if words.length > 1
    words.pop()
    words = words.join(' ')+'...'

  else
    words = words[0]

  return words


Number.prototype.isFloat = (n) -> n == +n and not _.isInteger(n)
Number.prototype.isInteger = (n) -> n==+n && n==Math.floor(n)
Number.prototype.toRad = () -> this * Math.PI / 180
Number.prototype.toDeg = () -> this * 180 / Math.PI


Number.prototype.degreesToDirection = () ->
  dirs = [
    'north',
    'north west',
    'west',
    'south west',
    'south',
    'south east',
    'east',
    'north east',
    'north'
  ]
  return dirs[Math.round(this/(360/dirs.length))]



Date.prototype.since = (since) ->
  now = 0
  minute = 60 * 1000
  hour = 60 * minute
  day = 24 * hour
  week = 7 * day
  month = 4 * week
  year = 52 * week

  t = +(since || new Date()) - (+this)

  # Indiana Jones and the staircase of doom
  unit = if t % year < t then year else
           if t % month < t then month else
             if t % week < t then week else
               if t % day < t then day else
                 if t % hour < t then hour else
                   if t % minute < t then minute else
                     now
  num = Math.floor(t / unit)
  s = if num > 1 then 's' else ''

  return switch unit
    when year then {text: "year#{s} ago", num: num}
    when month then {text: "month#{s} ago", num: num}
    when week then {text: "week#{s} ago", num: num}
    when day then {text: "day#{s} ago", num: num}
    when hour then {text: "hour#{s} ago", num: num}
    when minute then {text: "minute#{s} ago", num: num}
    else {text: "just now", num: 0}



class window.URL

  reg: /^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/

  constructor: (@raw) ->
    throw 'raw url required' if not raw?

    parsed = this.reg.exec this

    if parsed?
      this.protocol = parsed[2]
      this.host = parsed[3]
      this.path = parsed[4]
      this.file = parsed[6]
      this.query = parsed[7]
      this.hash = parsed[8]


  toString: -> this.raw
  valueOf: -> this.raw
