--
-- emsx_top_1chipmsx.vhd
--   ESE MSX-SYSTEM3 / MSX clone on a Cyclone FPGA (ALTERA)
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
--------------------------------------------------------------------------------------
-- OCM-PLD Pack v3.6.2 by KdL (2018.07.27) / MSX2+ Stable Release / MSXtR Experimental
-- Special thanks to t.hara, caro, mygodess & all MRC users (http://www.msx.org)
--------------------------------------------------------------------------------------
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use work.vdp_package.all;

entity emsx_top_1chipmsx is
    port(
        -- Clock, Reset ports
        pClk21m         : in    std_logic;                          -- VDP Clock ... 21.48MHz
        pExtClk         : in    std_logic;                          -- Reserved (for multi FPGAs)
        pCpuClk         : out   std_logic;                          -- CPU Clock ... 3.58MHz (up to 10.74MHz/21.48MHz)

        -- MSX cartridge slot ports
        pSltClk         : in    std_logic;                          -- pCpuClk returns here, for Z80, etc.
        pSltRst_n       : in    std_logic;                          -- pCpuRst_n returns here
        pSltSltsl_n     : inout std_logic;
        pSltSlts2_n     : inout std_logic;
        pSltIorq_n      : inout std_logic;
        pSltRd_n        : inout std_logic;
        pSltWr_n        : inout std_logic;
        pSltAdr         : inout std_logic_vector( 15 downto 0 );
        pSltDat         : inout std_logic_vector(  7 downto 0 );
        pSltBdir_n      : out   std_logic;                          -- Bus direction (not used in   master mode)

        pSltCs1_n       : inout std_logic;
        pSltCs2_n       : inout std_logic;
        pSltCs12_n      : inout std_logic;
        pSltRfsh_n      : inout std_logic;
        pSltWait_n      : inout std_logic;
        pSltInt_n       : inout std_logic;
        pSltM1_n        : inout std_logic;
        pSltMerq_n      : inout std_logic;

        pSltRsv5        : out   std_logic;                          -- Reserved
        pSltRsv16       : out   std_logic;                          -- Reserved (w/ external pull-up)
        pSltSw1         : inout std_logic;                          -- Reserved (w/ external pull-up)
        pSltSw2         : inout std_logic;                          -- Reserved

        -- SD-RAM ports
        pMemClk         : out   std_logic;                          -- SD-RAM Clock
        pMemCke         : out   std_logic;                          -- SD-RAM Clock enable
        pMemCs_n        : out   std_logic;                          -- SD-RAM Chip select
        pMemRas_n       : out   std_logic;                          -- SD-RAM Row/RAS
        pMemCas_n       : out   std_logic;                          -- SD-RAM /CAS
        pMemWe_n        : out   std_logic;                          -- SD-RAM /WE
        pMemUdq         : out   std_logic;                          -- SD-RAM UDQM
        pMemLdq         : out   std_logic;                          -- SD-RAM LDQM
        pMemBa1         : out   std_logic;                          -- SD-RAM Bank select address 1
        pMemBa0         : out   std_logic;                          -- SD-RAM Bank select address 0
        pMemAdr         : out   std_logic_vector( 12 downto 0 );    -- SD-RAM Address
        pMemDat         : inout std_logic_vector( 15 downto 0 );    -- SD-RAM Data

        -- PS/2 keyboard ports
        pPs2Clk         : inout std_logic;
        pPs2Dat         : inout std_logic;

        -- Joystick ports (Port_A, Port_B)
        pJoyA           : inout std_logic_vector(  5 downto 0);
        pStrA           : out   std_logic;
        pJoyB           : inout std_logic_vector(  5 downto 0);
        pStrB           : out   std_logic;

        -- SD/MMC slot ports
        pSd_Ck          : out   std_logic;                          -- pin 5
        pSd_Cm          : out   std_logic;                          -- pin 2
        pSd_Dt          : inout std_logic_vector(  3 downto 0);     -- pin 1(D3), 9(D2), 8(D1), 7(D0)

        -- DIP switch, Lamp ports
        pDip            : in    std_logic_vector(  7 downto 0);     -- 0=On, 1=Off (default on shipment)
        pLed            : out   std_logic_vector(  7 downto 0);     -- 0=Off, 1=On (green)
        pLedPwr         : out   std_logic;                          -- 0=Off, 1=On (red)

        -- Video, Audio/CMT ports
        pDac_VR         : inout std_logic_vector(  5 downto 0);     -- RGB_Red / Svideo_C
        pDac_VG         : inout std_logic_vector(  5 downto 0);     -- RGB_Grn / Svideo_Y
        pDac_VB         : inout std_logic_vector(  5 downto 0);     -- RGB_Blu / CompositeVideo
        pDac_SL         : out   std_logic_vector(  5 downto 0);     -- Sound-L
        pDac_SR         : inout std_logic_vector(  5 downto 0);     -- Sound-R / CMT

        pVideoHS_n      : out   std_logic;                          -- Csync(RGB15K), HSync(VGA31K)
        pVideoVS_n      : out   std_logic;                          -- Audio(RGB15K), VSync(VGA31K)

        pVideoClk       : out   std_logic;                          -- (Reserved)
        pVideoDat       : out   std_logic;                          -- (Reserved)

        -- Reserved ports (USB)
        pUsbP1          : inout std_logic;
        pUsbN1          : inout std_logic;
        pUsbP2          : inout std_logic;
        pUsbN2          : inout std_logic;

        -- Reserved ports
        pIopRsv14       : in    std_logic;
        pIopRsv15       : in    std_logic;
        pIopRsv16       : in    std_logic;
        pIopRsv17       : in    std_logic;
        pIopRsv18       : in    std_logic;
        pIopRsv19       : in    std_logic;
        pIopRsv20       : in    std_logic;
        pIopRsv21       : in    std_logic
    );
end emsx_top_1chipmsx;

architecture RTL of emsx_top_1chipmsx is

    -- Clock generator ( Altera specific component )
    component pll4x
        port(
            inclk0  : in    std_logic := '0';   -- 21.48MHz input to PLL    (external I/O pin, from crystal oscillator)
            c0      : out   std_logic;          -- 21.48MHz output from PLL (internal LEs, for VDP, internal-bus, etc.)
            c1      : out   std_logic;          -- 85.92MHz output from PLL (internal LEs, for SD-RAM)
            e0      : out   std_logic           -- 85.92MHz output from PLL (external I/O pin, for SD-RAM)
        );
    end component;

    -- ASMI (Altera specific component)
    component cyclone_asmiblock
        port (
            dclkin      : in    std_logic;      -- DCLK
            scein       : in    std_logic;      -- nCSO
            sdoin       : in    std_logic;      -- ASDO
            oe          : in    std_logic;      -- 1=disable(Hi-Z)
            data0out    : out   std_logic       -- DATA0
        );
    end component;

    -- CORE
    component emsx_top
        generic(
            deocmpldcv      : boolean := false
        );
        port(
            -- Clock, Reset ports
            clk21m          : in    std_logic;                          -- VDP Clock ... 21.48MHz
            memclk          : in    std_logic;                          -- Reserved (for multi FPGAs)
            pCpuClk         : out   std_logic;                          -- CPU Clock ... 3.58MHz (up to 10.74MHz/21.48MHz)
            pW10hz          : out   std_logic;

            -- MSX cartridge slot ports
            xSltRst_n       : out   std_logic;
            pSltRst_n       : in    std_logic;                          -- pCpuRst_n returns here
            pSltSltsl_n     : inout std_logic;
            pSltSlts2_n     : inout std_logic;
            pSltIorq_n      : inout std_logic;
            pSltRd_n        : inout std_logic;
            pSltWr_n        : inout std_logic;
            pSltAdr         : inout std_logic_vector( 15 downto 0 );
            pSltDat         : inout std_logic_vector(  7 downto 0 );
            pSltBdir_n      : out   std_logic;                          -- Bus direction (not used in   master mode)

            pSltCs1_n       : inout std_logic;
            pSltCs2_n       : inout std_logic;
            pSltCs12_n      : inout std_logic;
            pSltRfsh_n      : inout std_logic;
            pSltWait_n      : inout std_logic;
            pSltInt_n       : inout std_logic;
            pSltM1_n        : inout std_logic;
            pSltMerq_n      : inout std_logic;

            pSltRsv5        : out   std_logic;                          -- Reserved
            pSltRsv16       : out   std_logic;                          -- Reserved (w/ external pull-up)
            pSltSw1         : inout std_logic;                          -- Reserved (w/ external pull-up)
            pSltSw2         : inout std_logic;                          -- Reserved

            -- SD-RAM ports
            pMemCke         : out   std_logic;                          -- SD-RAM Clock enable
            pMemCs_n        : out   std_logic;                          -- SD-RAM Chip select
            pMemRas_n       : out   std_logic;                          -- SD-RAM Row/RAS
            pMemCas_n       : out   std_logic;                          -- SD-RAM /CAS
            pMemWe_n        : out   std_logic;                          -- SD-RAM /WE
            pMemUdq         : out   std_logic;                          -- SD-RAM UDQM
            pMemLdq         : out   std_logic;                          -- SD-RAM LDQM
            pMemBa1         : out   std_logic;                          -- SD-RAM Bank select address 1
            pMemBa0         : out   std_logic;                          -- SD-RAM Bank select address 0
            pMemAdr         : out   std_logic_vector( 12 downto 0 );    -- SD-RAM Address
            pMemDat         : inout std_logic_vector( 15 downto 0 );    -- SD-RAM Data

            -- PS/2 keyboard ports
            pPs2Clk         : inout std_logic;
            pPs2Dat         : inout std_logic;

            -- Joystick ports (Port_A, Port_B)
            pJoyA           : inout std_logic_vector(  5 downto 0);
            pStrA           : out   std_logic;
            pJoyB           : inout std_logic_vector(  5 downto 0);
            pStrB           : out   std_logic;

            -- SD/MMC slot ports
            pSd_Ck          : out   std_logic;                          -- pin 5
            pSd_Cm          : out   std_logic;                          -- pin 2
            pSd_Dt          : inout std_logic_vector(  3 downto 0);     -- pin 1(D3), 9(D2), 8(D1), 7(D0)

            -- DIP switch, Lamp ports
            pDip            : in    std_logic_vector(  7 downto 0);     -- 0=On, 1=Off (default on shipment)
            pLed            : out   std_logic_vector(  7 downto 0);     -- 0=Off, 1=On (green)
            pLedPwr         : out   std_logic;                          -- 0=Off, 1=On (red)

            -- Video, Audio/CMT ports
            pDac_VR         : inout std_logic_vector(  5 downto 0);     -- RGB_Red / Svideo_C
            pDac_VG         : inout std_logic_vector(  5 downto 0);     -- RGB_Grn / Svideo_Y
            pDac_VB         : inout std_logic_vector(  5 downto 0);     -- RGB_Blu / CompositeVideo

            pVideoHS_n      : out   std_logic;                          -- Csync(RGB15K), HSync(VGA31K)
            pVideoVS_n      : out   std_logic;                          -- Audio(RGB15K), VSync(VGA31K)

            pVideoClk       : out   std_logic;                          -- (Reserved)
            pVideoDat       : out   std_logic;                          -- (Reserved)

            pRemOut         : out   std_logic;
            pCmtOut         : out   std_logic;
            pCmtIn          : in    std_logic;
            pCmtEn          : out   std_logic;

            pDacOut         : out   std_logic;
            pDacLMute       : out   std_logic;
            pDacRInverse    : out   std_logic;

            -- EPCS ports
            EPC_CK          : out   std_logic;
            EPC_CS          : out   std_logic;
            EPC_OE          : out   std_logic;
            EPC_DI          : out   std_logic;
            EPC_DO          : in    std_logic

        );
    end component;


    -- Clock ports
    signal        clk21m       : std_logic;
    signal        memclk       : std_logic;

    -- EPCS ports
    signal        EPC_CK       : std_logic;
    signal        EPC_CS       : std_logic;
    signal        EPC_OE       : std_logic;
    signal        EPC_DI       : std_logic;
    signal        EPC_DO       : std_logic;

    -- CMT ports
    signal        pCmtOut      : std_logic;
    signal        pCmtIn       : std_logic;
    signal        pCmtEn       : std_logic;

    -- Audio ports
    signal        pDacOut      : std_logic;
    signal        pDacLMute    : std_logic;
    signal        pDacRInverse : std_logic;

begin

    ----------------------------------------------------------------
    -- Reserved ports (USB)
    ----------------------------------------------------------------
    pUsbP1      <= 'Z';
    pUsbN1      <= 'Z';
    pUsbP2      <= 'Z';
    pUsbN2      <= 'Z';

    -- Cassette Magnetic Tape (CMT) interface
    process( clk21m )
    begin
        if( clk21m'event and clk21m = '1' )then
            if( pCmtEn = '1' )then       -- when Scroll Lock is On
                pDac_SR(5 downto 4) <= "ZZ";
                pDac_SR(3 downto 1) <= pCmtIn & (not pCmtIn) & "0";
                pDac_SR(0)          <= pCmtOut;
                pCmtIn              <= pDac_SR(5);
            else                                                -- when Scroll Lock is Off (default)
                pCmtIn              <= '0';                     -- CMT data input is always '0' on MSX turbo-R
                if( pDacRInverse = '0' )then
                    pDac_SR         <= pDACout & "ZZZZ" & pDACout;
                else
                    pDac_SR         <= not pDACout & "ZZZZ" & not pDACout;
                end if;
            end if;
        end if;
    end process;

    pDac_SL   <=  "ZZZZZZ"  when( pDacLMute = '1' )else
                  pDACout & "ZZZZ" & pDACout;                   -- the DACout setting is used to balance the input line of external slots

    ----------------------------------------------------------------
    -- Connect components
    ----------------------------------------------------------------
    U90 : pll4x
        port map(
            inclk0   => pClk21m,                -- 21.48MHz external
            c0       => clk21m,                 -- 21.48MHz internal
            c1       => memclk,                 -- 85.92MHz = 21.48MHz x 4
            e0       => pMemClk                 -- 85.92MHz external
        );

    U91 : cyclone_asmiblock
        port map(EPC_CK, EPC_CS, EPC_DI, EPC_OE, EPC_DO);

    U92 : emsx_top
        port map(
            clk21m,
            memclk,
            pCpuClk,
            open,

            open,
            pSltRst_n,
            pSltSltsl_n,
            pSltSlts2_n,
            pSltIorq_n,
            pSltRd_n,
            pSltWr_n,
            pSltAdr,
            pSltDat,
            pSltBdir_n,

            pSltCs1_n,
            pSltCs2_n,
            pSltCs12_n,
            pSltRfsh_n,
            pSltWait_n,
            pSltInt_n,
            pSltM1_n,
            pSltMerq_n,

            pSltRsv5,
            pSltRsv16,
            pSltSw1,
            pSltSw2,

            pMemCke,
            pMemCs_n,
            pMemRas_n,
            pMemCas_n,
            pMemWe_n,
            pMemUdq,
            pMemLdq,
            pMemBa1,
            pMemBa0,
            pMemAdr,
            pMemDat,

            pPs2Clk,
            pPs2Dat,

            pJoyA,
            pStrA,
            pJoyB,
            pStrB,

            pSd_Ck,
            pSd_Cm,
            pSd_Dt,

            pDip,
            pLed,
            pLedPwr,

            pDac_VR,
            pDac_VG,
            pDac_VB,

            pVideoHS_n,
            pVideoVS_n,

            pVideoClk,
            pVideoDat,

            open,
            pCmtOut,
            pCmtIn,
            pCmtEn,

            pDacOut,
            pDacLMute,
            pDacRInverse,

            EPC_CK,
            EPC_CS,
            EPC_OE,
            EPC_DI,
            EPC_DO
        );

end RTL;
