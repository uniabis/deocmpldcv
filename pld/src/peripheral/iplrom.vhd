-- 
-- iplrom.vhd
--   initial program loader for Cyclone & EPCS (Altera)
--   Revision 1.00
-- 
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
-- 
-- Redistribution and use of this source code or any derivative works, are 
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright 
--    notice, this list of conditions and the following disclaimer in the 
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial 
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity iplrom is
    port(
      clk   : in std_logic;
      adr   : in std_logic_vector(15 downto 0);
      dbi   : out std_logic_vector(7 downto 0)
    );
end iplrom;

architecture rtl of iplrom is
type rom_type is array (0 to 511) of std_logic_vector(7 downto 0);
constant ipl_data : rom_type := (
        X"F3", X"18", X"03", X"C3", X"3E", X"F1", X"01", X"00", 
        X"02", X"11", X"00", X"F0", X"21", X"00", X"00", X"ED", 
        X"B0", X"21", X"21", X"F0", X"01", X"99", X"02", X"ED", 
        X"B3", X"01", X"9A", X"20", X"ED", X"B3", X"C3", X"43", 
        X"F0", X"00", X"90", X"00", X"00", X"00", X"00", X"11", 
        X"06", X"33", X"07", X"17", X"01", X"27", X"03", X"51", 
        X"01", X"27", X"06", X"71", X"01", X"73", X"03", X"61", 
        X"06", X"64", X"06", X"11", X"04", X"65", X"02", X"55", 
        X"05", X"77", X"07", X"31", X"FF", X"FF", X"3E", X"40", 
        X"32", X"00", X"60", X"01", X"00", X"01", X"11", X"00", 
        X"00", X"21", X"00", X"C0", X"CD", X"03", X"F0", X"38", 
        X"22", X"CD", X"6F", X"F1", X"38", X"13", X"CD", X"90", 
        X"F1", X"38", X"18", X"D5", X"C5", X"06", X"01", X"21", 
        X"00", X"C0", X"CD", X"03", X"F0", X"C1", X"D1", X"38", 
        X"1C", X"CD", X"A8", X"F1", X"38", X"05", X"CD", X"A0", 
        X"F0", X"18", X"12", X"21", X"BD", X"F0", X"22", X"04", 
        X"F0", X"3E", X"60", X"32", X"00", X"60", X"11", X"00", 
        X"02", X"4B", X"CD", X"A0", X"F0", X"AF", X"32", X"00", 
        X"60", X"3C", X"32", X"00", X"68", X"32", X"00", X"70", 
        X"32", X"00", X"78", X"3E", X"C0", X"D3", X"A8", X"C7", 
        X"06", X"10", X"3E", X"80", X"32", X"00", X"70", X"3C", 
        X"32", X"00", X"78", X"3C", X"F5", X"C5", X"06", X"20", 
        X"21", X"00", X"80", X"CD", X"03", X"F0", X"C1", X"E1", 
        X"D8", X"7C", X"10", X"E8", X"C9", X"D5", X"C5", X"CB", 
        X"23", X"CB", X"12", X"78", X"87", X"4F", X"06", X"00", 
        X"E5", X"21", X"00", X"40", X"36", X"03", X"72", X"73", 
        X"70", X"7E", X"D1", X"7E", X"12", X"13", X"10", X"FB", 
        X"0D", X"20", X"F8", X"3A", X"00", X"50", X"C1", X"E1", 
        X"AF", X"57", X"58", X"19", X"EB", X"89", X"4F", X"C9", 
        X"7E", X"CB", X"23", X"CB", X"12", X"CB", X"11", X"70", 
        X"71", X"72", X"73", X"36", X"00", X"36", X"95", X"7E", 
        X"06", X"10", X"7E", X"FE", X"FF", X"3F", X"D0", X"10", 
        X"F9", X"37", X"C9", X"06", X"0A", X"3A", X"00", X"50", 
        X"10", X"FB", X"01", X"00", X"40", X"59", X"51", X"CD", 
        X"E8", X"F0", X"D8", X"E6", X"F7", X"FE", X"01", X"37", 
        X"C0", X"06", X"77", X"CD", X"E8", X"F0", X"E6", X"04", 
        X"28", X"07", X"06", X"41", X"CD", X"E8", X"F0", X"18", 
        X"05", X"06", X"69", X"CD", X"E8", X"F0", X"D8", X"FE", 
        X"01", X"28", X"E6", X"B7", X"C8", X"37", X"C9", X"CD", 
        X"03", X"F1", X"C1", X"D1", X"E1", X"D8", X"E5", X"D5", 
        X"C5", X"06", X"51", X"21", X"00", X"40", X"CD", X"E8", 
        X"F0", X"38", X"EC", X"C1", X"D1", X"E1", X"B7", X"37", 
        X"C0", X"D5", X"C5", X"EB", X"01", X"00", X"02", X"21", 
        X"00", X"40", X"7E", X"FE", X"FE", X"20", X"FB", X"ED", 
        X"B0", X"EB", X"1A", X"C1", X"1A", X"D1", X"13", X"7A", 
        X"B3", X"20", X"01", X"0C", X"10", X"D0", X"C9", X"21", 
        X"00", X"C0", X"01", X"80", X"00", X"3E", X"46", X"ED", 
        X"B1", X"28", X"02", X"B7", X"C9", X"E5", X"56", X"23", 
        X"5E", X"21", X"54", X"41", X"B7", X"ED", X"52", X"E1", 
        X"20", X"EB", X"0E", X"00", X"59", X"51", X"37", X"C9", 
        X"06", X"04", X"21", X"C6", X"C1", X"E5", X"5E", X"23", 
        X"56", X"23", X"4E", X"79", X"B2", X"B3", X"E1", X"C0", 
        X"11", X"10", X"00", X"19", X"10", X"EF", X"37", X"C9", 
        X"DD", X"21", X"00", X"C0", X"DD", X"6E", X"0E", X"DD", 
        X"66", X"0F", X"79", X"19", X"CE", X"00", X"4F", X"DD", 
        X"5E", X"11", X"DD", X"56", X"12", X"7B", X"E6", X"0F", 
        X"06", X"04", X"CB", X"3A", X"CB", X"1B", X"10", X"FA", 
        X"B7", X"28", X"01", X"13", X"D5", X"DD", X"46", X"10", 
        X"DD", X"5E", X"16", X"DD", X"56", X"17", X"79", X"19", 
        X"CE", X"00", X"10", X"FB", X"D1", X"19", X"EB", X"4F", 
        X"D5", X"C5", X"06", X"01", X"21", X"00", X"C0", X"CD", 
        X"03", X"F0", X"D8", X"2A", X"00", X"C0", X"11", X"41", 
        X"42", X"B7", X"ED", X"52", X"C1", X"D1", X"C8", X"37", 
        X"C9", X"00", X"00", X"00", X"00", X"00", X"00", X"00"  
);

begin

process (clk)
begin
  if (clk'event and clk = '1') then
    dbi <= ipl_data(conv_integer(adr(8 downto 0)));
  end if;
end process;

end rtl;
