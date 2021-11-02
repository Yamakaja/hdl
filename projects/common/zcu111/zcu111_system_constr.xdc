
# constraints
# gpio (switches, leds and such)

set_property  -dict {PACKAGE_PIN  AR13  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[0]]           ; ## GPIO_LED_0
set_property  -dict {PACKAGE_PIN  AP13  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[1]]           ; ## GPIO_LED_1
set_property  -dict {PACKAGE_PIN  AR16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[2]]           ; ## GPIO_LED_2
set_property  -dict {PACKAGE_PIN  AP16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[3]]           ; ## GPIO_LED_3
set_property  -dict {PACKAGE_PIN  AP15  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[4]]           ; ## GPIO_LED_4
set_property  -dict {PACKAGE_PIN  AN16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[5]]           ; ## GPIO_LED_5
set_property  -dict {PACKAGE_PIN  AN17  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[6]]           ; ## GPIO_LED_6
set_property  -dict {PACKAGE_PIN  AV15  IOSTANDARD LVCMOS18} [get_ports gpio_bd_o[7]]           ; ## GPIO_LED_7

set_property  -dict {PACKAGE_PIN  AF16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[0]]           ; ## GPIO_DIP_SW0
set_property  -dict {PACKAGE_PIN  AF17  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[1]]           ; ## GPIO_DIP_SW1
set_property  -dict {PACKAGE_PIN  AH15  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[2]]           ; ## GPIO_DIP_SW2
set_property  -dict {PACKAGE_PIN  AH16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[3]]           ; ## GPIO_DIP_SW3
set_property  -dict {PACKAGE_PIN  AH17  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[4]]           ; ## GPIO_DIP_SW4
set_property  -dict {PACKAGE_PIN  AG17  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[5]]           ; ## GPIO_DIP_SW5
set_property  -dict {PACKAGE_PIN  AJ15  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[6]]           ; ## GPIO_DIP_SW6
set_property  -dict {PACKAGE_PIN  AJ16  IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[7]]           ; ## GPIO_DIP_SW7

set_property  -dict {PACKAGE_PIN  AW3   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[8]]           ; ## GPIO_SW_N
set_property  -dict {PACKAGE_PIN  AW6   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[9]]           ; ## GPIO_SW_W
set_property  -dict {PACKAGE_PIN  AW5   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[10]]          ; ## GPIO_SW_C
set_property  -dict {PACKAGE_PIN  AW4   IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[11]]          ; ## GPIO_SW_E
set_property  -dict {PACKAGE_PIN  E8    IOSTANDARD LVCMOS18} [get_ports gpio_bd_i[12]]          ; ## GPIO_SW_S

