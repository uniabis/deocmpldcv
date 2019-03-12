#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20 [get_ports CLOCK_50]
#create_clock -period 20 [get_ports CLOCK2_50]
#create_clock -period 20 [get_ports CLOCK3_50]
#create_clock -period 20 [get_ports CLOCK4_50]



#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {U00|pll_de0cv_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {PLL|audiopll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50 -multiply_by 86 -divide_by 10 -master_clock {CLOCK_50} [get_pins {U00|pll_de0cv_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {U00|pll_de0cv_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {PLL|audiopll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50 -multiply_by 1 -divide_by 20 -master_clock {PLL|audiopll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {U00|pll_de0cv_inst|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
create_generated_clock -name {U00|pll_de0cv_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {PLL|audiopll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50 -multiply_by 1 -divide_by  5 -master_clock {PLL|audiopll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {U00|pll_de0cv_inst|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]



#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
##**************************************************************

#**************************************************************
# Set False Path
#**************************************************************

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************
