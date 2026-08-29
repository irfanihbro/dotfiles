---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout  = "us",
    numlock_by_default = false,
    repeat_rate = 100,
    repeat_delay = 300,
    follow_mouse = 1,
    sensitivity = 0.0,
    scroll_factor = 1.0,
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
      tap_to_click = true,
      scroll_factor = 1.0,
    },
  },
})

hl.device({
  name = "elan06fa:00-04f3:31ad-touchpad",
  accel_profile = "adaptive",
})
