-- 
-- kanji.vhd
--   Kanji ROM controller
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

entity kanji is
  port(
    clk21m  : in std_logic;
    reset   : in std_logic;
    clkena  : in std_logic;
    req     : in std_logic;
    ack     : out std_logic;
    wrt     : in std_logic;
    adr     : in std_logic_vector(15 downto 0);
    dbi     : out std_logic_vector(7 downto 0);
    dbo     : in std_logic_vector(7 downto 0);

    ramreq  : out std_logic;
    ramadr  : out std_logic_vector(17 downto 0);
    ramdbi  : in std_logic_vector(7 downto 0);
    ramdbo  : out std_logic_vector(7 downto 0)
 );
end kanji;

architecture rtl of kanji is

  signal UpdateReq   : std_logic;
  signal UpdateAck   : std_logic;
  signal KanjiSel    : std_logic;
  signal KanjiPtr1   : std_logic_vector(16 downto 0);
  signal KanjiPtr2   : std_logic_vector(16 downto 0);

begin

  ----------------------------------------------------------------
  -- Kanji ROM port access
  ----------------------------------------------------------------
  process(clk21m, reset)

  begin

    if (reset = '1') then

      ack <= '0';
      KanjiSel <= '0';
      KanjiPtr1 <= (others => '0');
      KanjiPtr2 <= (others => '0');
      UpdateReq <= '0';
      UpdateAck <= '0';

    elsif (clk21m'event and clk21m = '1') then

      if (wrt = '1') then
        ack <= req;
      else
        ack <= '0';
      end if;

      if (req = '1' and wrt = '1' and adr(1) = '0') then
        if (adr(0) = '0') then
          KanjiPtr1(10 downto 5) <= dbo(5 downto 0);
          KanjiPtr1(4 downto 0) <= (others => '0');
        else
          KanjiPtr1(16 downto 11) <= dbo(5 downto 0);
          KanjiPtr1(4 downto 0) <= (others => '0');
        end if;
      elsif (req = '1' and wrt = '1' and adr(1) = '1') then
        if (adr(0) = '0') then
          KanjiPtr2(10 downto 5) <= dbo(5 downto 0);
          KanjiPtr2(4 downto 0) <= (others => '1');
        else
          KanjiPtr2(16 downto 11) <= dbo(5 downto 0);
          KanjiPtr2(4 downto 0) <= (others => '1');
        end if;
      elsif (req = '1' and wrt = '0' and adr(0) = '1') then
        KanjiSel <= adr(1);
        UpdateReq <= not UpdateAck;
      elsif (req = '0' and (UpdateReq /= UpdateAck)) then
        dbi <= ramdbi;
        if (KanjiSel = '0') then
          KanjiPtr1(4 downto 0) <= KanjiPtr1(4 downto 0) + 1;
        else
          KanjiPtr2(4 downto 0) <= KanjiPtr2(4 downto 0) + 1;
        end if;
        UpdateAck <= not UpdateAck;
      end if;

    end if;

  end process;

  RamReq <= req when wrt = '0' and adr(0) = '1' else '0';
--RamReq <= req;
--RamAdr <= '0' & KanjiPtr1;
  RamAdr <= '0' & KanjiPtr1 when KanjiSel = '0' else
            '1' & KanjiPtr2;
  RamDbo <= dbo;

end rtl;
