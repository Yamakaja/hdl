# Place LDPC decoders at their required positions
set_property LOC FE_X0Y0 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_0/*}]
set_property LOC FE_X0Y1 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_1/*}]
set_property LOC FE_X0Y2 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_2/*}]
set_property LOC FE_X0Y5 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_3/*}]
set_property LOC FE_X0Y6 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_4/*}]
set_property LOC FE_X0Y7 [get_cells -hier -filter {REF_NAME == FE && NAME =~ */sd_fec_5/*}]

set_property -dict {PACKAGE_PIN J19   IOSTANDARD LVDS} [get_ports default_sysclk1_300mhz_clk_p]    ; ## USER_SI570_P
set_property -dict {PACKAGE_PIN J18   IOSTANDARD LVDS} [get_ports default_sysclk1_300mhz_clk_n]    ; ## USER_SI570_N
