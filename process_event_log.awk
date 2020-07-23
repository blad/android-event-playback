BEGIN {
  PROCINFO["sorted_in"] = "@ind_num_asc"
  time=2
  device=3
  type=4
  event=5
  value=6
 
  # Counters
  address=0
  last_event=0
  elapsed_delta=0

  if (!threshold) {
    print "No `threshold` defined...using default of: 20ms"
    threshold=100 # ms // Adjust threshold to throttle events
  }

  if (!output_directory) {
    print "No `output_directory` defined...using default of: ./out"
    output_directory="./out/"
  } 

  output_delay=0
  output_order=-1
  output_prefix="events."

  # Placeholders For Time:
  upperSecond = 0x0000
  lowerSecond = 0x0000
  upperMicro = 0x0000
  lowerMicro = 0x0000
  ascii_placeholder = "................"

  # Clean up old events
  print "rm out/events.* 2>/dev/null" | "sh"
  close("sh")
}

function to_ms(raw_value,  time_string, time_parts, seconds, milliseconds) {
  time_string = substr(raw_value, 1, length(raw_value) - 1)
  split(time_string, time_parts, ".")
  seconds = time_parts[1]
  milliseconds = time_parts[2]
  return seconds * 1000 + int(milliseconds/1000)
}

function to_decimal(value, _value) {
  _value = value
  if (length(value) > 4) {
    _value = substr(value, length(value) - 4)
  }

  return sprintf("%d", "0x" _value) + 0
}

function little_endian(short,  updated_short) {
  upper_byte = rshift(and(0xff00, short), 8)
  lower_byte = lshift(and(0x00ff, short), 8)
  updated_short = or(upper_byte, lower_byte)
  return updated_short
}

function set_output_location() {
  target_device = substr($device, 0, length($device) - 1)
  event_time = to_ms($time)
  delta = event_time - last_event
  elapsed_delta += delta

  is_over_threshold = elapsed_delta >= threshold
  is_different_device = target_device != current_device
  if (is_over_threshold || is_different_device) {
    if (output_order == -1) {
      output_delay = 0
      current_device = target_device
    } else {
      output_delay = elapsed_delta
      current_device = target_device
    }

    elapsed_delta = 0
    output_order += 1
    address = 0x0000 # Reset Addres for hex file
  }

  last_event = event_time
  output_file_name = output_directory output_prefix output_order 
  output_device[output_order] = current_device
  output_hex[output_order] = output_file_name ".hex"
  output_delay_value[output_order] = output_delay
  output_bin[output_order] = output_file_name ".bin"
}

function strip_output_directory_prefix(path) {
  return substr(path, length(output_directory) + 1)
}

/^\[/ {
  set_output_location()

  dec_value = to_decimal($value)
  if (dec_value == 0xffff) {
    padding = 0xffff
  } else {
    padding = 0x0000
  }

  # Print to format required for `xxd -r`:
  output_line = sprintf("%08x: %04x %04x %04x %04x %04x %04x %04x %04x %s", 
         address, 
         little_endian(lowerSecond), little_endian(upperSecond),
         little_endian(lowerMicro), little_endian(upperMicro),
         little_endian(to_decimal($type)),
         little_endian(to_decimal($event)),
         little_endian(dec_value), 
         little_endian(padding), 
         ascii_placeholder)

  print output_line >> output_hex[output_order]
  close(output_hex[output_order])

  # Inclement, Update stateful variables
  address += 16 
}

END {
  coordinator_script = output_directory "run_events.sh"
  printf("rm %s 2>/dev/null\n", coordinator_script) | "sh"
  close("sh")

  # Conver hexdump files into .bin files
  for (i in output_hex) {
    # Write binary files:
    hex_file = output_hex[i]
    bin_file = output_bin[i]
    printf("cat %s | xxd -r > %s\n", hex_file, bin_file) | "sh"
    close("sh")

    # Write script to run binary files:
    if (output_delay_value[i] > 0) {
      print "sleep " output_delay_value[i] / 1000 >> coordinator_script 
    }

    # print "dd if="strip_output_directory_prefix(bin_file)" of="output_device[i] >> coordinator_script
    print "cat "strip_output_directory_prefix(bin_file)" >> "output_device[i] >> coordinator_script
  }

  # Clean up old events
  print "rm " output_directory "/*.hex 2>/dev/null\n" | "sh"
  close("sh")
}
