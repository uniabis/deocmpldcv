--
--  text12.vhd
--    Imprementation of Text Mode 1,2.
--
--  Copyright (C) 2006 Kunihiko Ohnaka
--  All rights reserved.
--                                     http://www.ohnaka.jp/ese-vdp/
--
--  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
--  満たす場合に限り、再頒布および使用が許可されます。
--
--  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
--    免責条項をそのままの形で保持すること。
--  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
--    著作権表示、本条件一覧、および下記免責条項を含めること。
--  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
--    に使用しないこと。
--
--  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
--  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
--  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
--  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
--  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
--  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
--  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
--  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
--  たは結果損害について、一切責任を負わないものとします。
--
--  Note that above Japanese version license is the formal document.
--  The following translation is only for reference.
--
--  Redistribution and use of this software or any derivative works,
--  are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  3. Redistributions may not be sold, nor may they be used in a 
--     commercial product or activity without specific prior written
--     permission.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
--  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
--  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
--  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
-- Contributors
--  
--   Alex Wulms
--     - Improvement of the TEXT2 mode such as 'blink function'.
--
-------------------------------------------------------------------------------
-- Memo
--   Japanese comment lines are starts with "JP:".
--   JP: 日本語のコメント行は JP:を頭に付ける事にする
--
-------------------------------------------------------------------------------
-- Revision History
--
-- 29th,October,2006 modified by Kunihiko Ohnaka
--   - Insert the license text.
--   - Add the document part below.
--
-- 12th,August,2006 created by Kunihiko Ohnaka
-- JP: VDPのコアの実装とスクリーンモードの実装を分離した
--
-------------------------------------------------------------------------------
-- Document
--
-- JP: TEXTモード1,2のメイン処理回路です。
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity text12 is
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;

    dotState : in std_logic_vector(1 downto 0);
    dotCounterX : in std_logic_vector(8 downto 0);
    dotCounterY : in std_logic_vector(8 downto 0);

    vdpModeText1: in std_logic;
    vdpModeText2: in std_logic;

    -- registers
    vdpR7FrameColor : in std_logic_vector( 7 downto 0);
    vdpR12BlinkColor : in std_logic_vector( 7 downto 0);
    vdpR13BlinkPeriod : in std_logic_vector( 7 downto 0);
    
    vdpR2PtnNameTblBaseAddr : in std_logic_vector(6 downto 0);
    vdpR4PtnGeneTblBaseAddr : in std_logic_vector(5 downto 0);
    VdpR10R3ColorTblBaseAddr : in std_logic_vector(10 downto 0);
    --
    pRamDat : in std_logic_vector(7 downto 0);
    pRamAdr : out std_logic_vector(16 downto 0);
    txVramReadEn : out std_logic;

    pColorCode : out std_logic_vector(3 downto 0)
    );
end text12;
architecture rtl of text12 is
  signal iTxVramReadEn : std_logic;
  signal iTxVramReadEn2 : std_logic;
  signal dotCounter24 : std_logic_vector(4 downto 0);
  signal txWindowX : std_logic;
  signal txPreWindowX : std_logic;

  signal logicalVramAddrNam : std_logic_vector(16 downto 0);
  signal logicalVramAddrGen : std_logic_vector(16 downto 0);
  signal logicalVramAddrCol : std_logic_vector(16 downto 0);

  signal txCharCounter  : std_logic_vector(11 downto 0);
  signal txCharCounterX : std_logic_vector(6 downto 0);
  signal txCharCounterStartOfLine : std_logic_vector(11 downto 0);

  signal patternNum : std_logic_vector( 7 downto 0);
  signal prePattern : std_logic_vector( 7 downto 0);
  signal preBlink : std_logic_vector( 7 downto 0);
  signal pattern : std_logic_vector( 7 downto 0);
  signal blink : std_logic_vector( 7 downto 0);
  signal txColorCode : std_logic;       -- only 2 colors
  signal txColor : std_logic_vector( 7 downto 0);

  -- for blink
  signal blinkFrameCount :std_logic_vector( 3 downto 0);
  signal blinkState : std_logic;
  signal blinkPeriodCount : std_logic_vector( 3 downto 0);
begin

  -- JP: RAMは dotStateが"10","00"の時にアドレスを出して"01"でアクセスする。
  -- JP: eightDotStateで見ると、
  -- JP:  0-1    Read pattern num.
  -- JP:  1-2    Read pattern
  -- JP: となる。
  --

  ----------------------------------------------------------------
  -- 
  ----------------------------------------------------------------

  txCharCounter <= txCharCounterStartOfLine + txCharCounterX;
  -- JP: 各エリアのVRAMマッピング
  logicalVramAddrNam <=  (VdpR2PtnNameTblBaseAddr & txCharCounter(9 downto 0)) when vdpModeText1 = '1' else
                         (VdpR2PtnNameTblBaseAddr(6 downto 2) & txCharCounter);

  logicalVramAddrGen <=  VdpR4PtnGeneTblBaseAddr & patternNum & dotCounterY(2 downto 0);

  logicalVramAddrCol <=  VdpR10R3ColorTblBaseAddr(10 downto 3) & TXCharCounter(11 downto 3);

  txVramReadEn <= iTxVramReadEn when vdpModeText1 = '1' else
                  iTxVramReadEn or iTxVramReadEn2 when vdpModeText2 = '1' else
                  '0';
  --
  txColor <= vdpR12BlinkColor when (vdpModeText2 = '1') and (blinkState = '1') and (blink(7) = '1') else
             vdpR7FrameColor;
  pColorCode <= txColor(7 downto 4) when (txWindowX = '1') and (txColorCode = '1') else
                txColor(3 downto 0) when (txWindowX = '1') and (txColorCode = '0') else
                vdpR7FrameColor(3 downto 0);

  --
  --
  process( clk21m, reset )
    variable blinkFrameCountIsMax : std_logic;
  begin
    if(reset = '1' ) then
      txCharCounterX <= (others => '0');
      txCharCounterStartOfLine <= (others => '0');
      patternNum <= (others => '0');
      pattern <= (others => '0');
      prePattern <= (others => '0');
      preBlink <= (others => '0');
      txWindowX <= '0';
      txPreWindowX <= '0';
      pRamAdr <= (others => '0');
      iTxVramReadEn <= '0';
      iTxVramReadEn2 <= '0';
      blinkFrameCount <= (others => '0');
      dotCounter24 <= (others => '0');
    elsif (clk21m'event and clk21m = '1') then

      -- timing generation
      case dotState is
        when "10" =>
          if( dotCounterX = 12 ) then
            -- JP: dotcounterは"10"のタイミングでは既にカウントアップしているので注意
            txPreWindowX <= '1';
            dotCounter24 <= (others => '0');
          else
            if( dotCounterX = 240+12 ) then
              txPreWindowX <= '0';
            end if;
            -- The dotCounter24(2 downto 0) counts up 0 to 5,
            -- and the dotCounter24(4 downto 3) counts up 0 to 3.
            if( dotCounter24(2 downto 0) = "101" ) then
              dotCounter24(4 downto 3) <= dotCounter24(4 downto 3) + 1;
              dotCounter24(2 downto 0) <= "000";
            else
              dotCounter24(2 downto 0) <= dotCounter24(2 downto 0) + 1;
            end if;
          end if;
        when "00" =>
          null;
        when "01" =>
          if( dotCounterX = 16 ) then
            txWindowX <= '1';
          elsif( dotCounterX = 240+16) then
            txWindowX <= '0';
          end if;
        when "11" =>
          null;
        when others => null;
      end case;
      
      
      case dotState is
        when "11" =>
          if( txPreWindowX = '1' ) then
            -- VRAM read address output.
            case dotCounter24(2 downto 0) is
              when "000" =>
                if( dotCounter24(4 downto 3) = "00" ) then
                  -- read color table(TEXT2 BLINK)
                  -- It is used only one time per 8 characters.
                  pRamAdr <= logicalVramAddrCol;
                  iTxVramReadEn2 <= '1';
                end if;
              when "001" =>
                -- read pattern name table
                pRamAdr <= logicalVramAddrNam;
                iTxVramReadEn <= '1';
                txCharCounterX <= txCharCounterX + 1;
              when "010" =>
                -- read pattern generator table
                pRamAdr <= logicalVramAddrGen;
                iTxVramReadEn <= '1';
              when "100" =>
                -- read pattern name table
                -- It is used if vdpmode is TEST2.
                pRamAdr <= logicalVramAddrNam;
                iTxVramReadEn2 <= '1';
                if( vdpModeText2 = '1' ) then
                  txCharCounterX <= txCharCounterX + 1;
                end if;
              when "101" =>
                -- read pattern generator table
                -- It is used if vdpmode is TEST2.
                pRamAdr <= logicalVramAddrGen;
                iTxVramReadEn2 <= '1';
              when others =>
                null;
            end case;
          end if;
        when "10" =>
          iTxVramReadEn <= '0';
          iTxVramReadEn2 <= '0';
        when "00" =>
          if( dotCounterX = 11) then
            txCharCounterX <= (others => '0');
            if( dotCounterY = 0 )  then
              txCharCounterStartOfLine <= (others => '0');
            end if;
          elsif( (dotCounterX = 240+11) and (dotCounterY(2 downto 0) = "111") ) then
              txCharCounterStartOfLine <= txCharCounterStartOfLine + txCharCounterX;
          end if;
        when "01" =>
          case dotCounter24(2 downto 0) is
            when "001" =>
              -- read color table(TEXT2 BLINK)
              -- It is used only one time per 8 characters.
              if( dotCounter24(4 downto 3) = "00" ) then
                preBlink <= pRamDat;
              end if;
            when "010" =>
              -- read pattern name table
              patternNum <= pRamDat;
            when "011" =>
              -- read pattern generator table
              prePattern <= pRamDat;
            when "101" =>
              -- read pattern name table
              -- It is used if vdpmode is TEST2.
              patternNum <= pRamDat;
            when "000" =>
              -- read pattern generator table
              -- It is used if vdpmode is TEST2.
              if( vdpModeText2 = '1' ) then
                prePattern <= pRamDat;
              end if;
            when others =>
              null;
          end case;
        when others => null;
      end case;

      -- Color code decision
      -- JP: "01"と"10"のタイミングでかラーコードを出力してあげれば、
      -- JP: VDPエンティティの方でパレットをデコードして色を出力してくれる。
      -- JP: "01"と"10"で同じ色を出力すれば横256ドットになり、違う色を
      -- JP: 出力すれば横512ドット表示となる。
      case dotState is
        when "00" =>
          if( dotCounter24(2 downto 0) = "100" ) then
            -- load next 8 dot data
            -- JP: キャラクタの描画は dotCounter24が、
            -- JP:   "0:4"から"1:3"の6ドット
            -- JP:   "1:4"から"2:3"の6ドット
            -- JP:   "2:4"から"3:3"の6ドット
            -- JP:   "3:4"から"0:3"の6ドット
            -- JP: で行われるので"100"のタイミングでロードする
            pattern <= prePattern;
          elsif( (dotCounter24(2 downto 0) = "001") and (vdpModeText2 = '1') ) then
            -- JP: TEXT2では"001"のタイミングでもロードする。
            pattern <= prePattern;
          end if;
          if( (dotCounter24(2 downto 0) = "100") or
              (dotCounter24(2 downto 0) = "001") ) then
            -- evaluate blink signal
            if(dotCounter24(4 downto 0) = "00100") then
              blink <= preBlink;
            else
              blink <= blink(6 downto 0) & "0";
            end if;
          end if;
        when "01" =>
          -- パターンに応じてカラーコードを決定
          txColorCode <= pattern(7);
          -- パターンをシフト
          pattern <= pattern(6 downto 0) & '0';
        when "11" =>
          null;
        when "10" =>
          if( vdpModeText2 = '1' ) then
            txColorCode <= pattern(7);
            -- パターンをシフト
            pattern <= pattern(6 downto 0) & '0';
          end if;

        when others => null;
      end case;
    end if;

    --
    -- Blink timing generation
    --
    if( (dotCounterX = 0) and (dotCounterY = 0) and (dotState = "00") ) then
      if (blinkFrameCount = "1001") then
        blinkFrameCountIsMax := '1';
        blinkFrameCount <= (others => '0');
      else
        blinkFrameCountIsMax := '0';
        blinkFrameCount <= blinkFrameCount + 1;
      end if;

      if (blinkFrameCountIsMax = '1') then
        if( VdpR13BlinkPeriod(7 downto 4) = "0000" ) then
          -- When ON period is 0, the blink color is always OFF
          blinkState <= '0';
        elsif( VdpR13BlinkPeriod(3 downto 0) = "0000") then
          -- When OFF period is 0, the blink color is always ON
          blinkState <= '1';
        elsif( (blinkState = '0') and (blinkPeriodCount >= VdpR13BlinkPeriod(3 downto 0)) ) then
          blinkState <= '1';
          blinkPeriodCount <= (others => '0');
        elsif( (blinkState = '1') and (blinkPeriodCount >= VdpR13BlinkPeriod(7 downto 4)) ) then
          blinkState <= '0';
          blinkPeriodCount <= (others => '0');
        end if;
      end if;
    end if;
    
  end process;
end rtl;
