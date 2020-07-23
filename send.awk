BEGIN {
  time=2
  device=3
  type=4
  event=5
  value=6
 
  last_time=0
  diff=0
  address=0
}

function toDecimal(value, _value) {
  _value = value
  if (length(value) > 4) {
    _value = substr(value, length(value) - 4)
  }
  return sprintf("%d", "0x" _value) + 0; 
}

function toSeconds(value) {
  return 0 + substr(value, 0, length(value) -1 )
}

function short_aligned(value) {
  return lshift(value, 8)
}

/^\[/ {
  clean_device = substr($device, 0, length($device) - 1)
  if (!last_time) { last_time = toSeconds($time) }
  diff = toSeconds($time) - last_time
  sleep_time = sprintf("%.1f", diff)
  if (sleep_time != "0.0") {
    # print "sleep", sleep_time
  }

  decValue = toDecimal($value)
  upperSecond = 0x0000
  lowerSecond = 0x0000
  upperMicro = 0x0000
  lowerMicro = 0x0000
  dec_value = toDecimal($value)
  ascii_placeholder = "................"



  if (dec_value == 0xffff) {
    padding = 0xffff
  } else {
    padding = 0x0000
  }

  lowerValue = lshift(and(0x00ff, dec_value), 8)
  higherValue = rshift(and(0xff00, dec_value), 8)
  clean_value = or(lowerValue, higherValue);

  printf("%08x: %04x %04x %04x %04x %04x %04x %04x %04x %s\n", address, upperSecond, lowerSecond, upperMicro, lowerMicro, short_aligned(toDecimal($type)), short_aligned(toDecimal($event)), clean_value, padding, ascii_placeholder)
  address += 16 
  last_time = toSeconds($time)
}
