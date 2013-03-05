$memstat = {}
$timestat = {}
$memusage = `pmap #{Process.pid} | tail -1`[10,40].strip.to_i
$memstat['base'] = $memusage
$timestamp = Time.now
$timestat['base'] = nil
$level = 0

alias :old_require :require
def require *args
  $level += 1
  $timestat['base'] ||= Time.now - $timestamp
  timestamp = Time.now
  result = old_require *args
  timedelta = Time.now - timestamp
  p "Spent %.6f s %s %s" % [timedelta, ":"*$level, args[0]]
  oldmem = $memusage
  $memusage = `pmap #{Process.pid} | tail -1`[10,40].strip.to_i
  delta = $memusage - oldmem
#  p "Used %s KBytes" % [delta]
#  p caller.inspect
  $memstat[args[0]] ||= 0
  $memstat[args[0]] += delta
  $timestat[args[0]] ||= 0
  $timestat[args[0]] += timedelta
  $level -= 1
  result
end

