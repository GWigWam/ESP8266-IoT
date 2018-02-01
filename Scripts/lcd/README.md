# LCD

Control an LCD screen via i2c in lua code for the nodemcu.

Requires `i2c.lua` to provide `i2cw(data_table)` send function.

### Hardware

- 1602 LCD (16x2 display) HD44780
- i2c controller w/ PCF8574

### Usage

    dofile("i2c.lua") 			-- From ./Scripts/i2c/i2c.lua
    lcd = dofile("lcd1602.lua") -- Load LCD 'object' into own variable
    lcd:init()					-- 'init' must be called before all other use
    lcd:sendStr("Hello")
    lcd:setCursor(0, 1)			-- Set cursor to col 0, row 1 (Start of 2nd display row)
    lcd:sendStr("world!")
    lcd:cls()					-- Clears the screen, returns cursor to (0, 0)