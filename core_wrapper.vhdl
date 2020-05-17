library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;
use work.wishbone_types.all;
use work.core;

entity core_wrapper is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;

        wb_i_in_dat         : in  std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_i_in_ack         : in  std_ulogic;
        wb_i_in_stall       : in  std_ulogic;

        wb_i_out_adr        : out std_ulogic_vector(wishbone_addr_bits-1 downto 0);
        wb_i_out_dat        : out std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_i_out_cyc        : out std_ulogic;
        wb_i_out_stb        : out std_ulogic;
        wb_i_out_sel        : out std_ulogic_vector(wishbone_sel_bits-1  downto 0);
        wb_i_out_we         : out std_ulogic;

        wb_d_in_dat         : in  std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_d_in_ack         : in  std_ulogic;
        wb_d_in_stall       : in  std_ulogic;

        wb_d_out_adr        : out std_ulogic_vector(wishbone_addr_bits-1 downto 0);
        wb_d_out_dat        : out std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_d_out_cyc        : out std_ulogic;
        wb_d_out_stb        : out std_ulogic;
        wb_d_out_sel        : out std_ulogic_vector(wishbone_sel_bits-1  downto 0);
        wb_d_out_we         : out std_ulogic;

	    terminated_out      : out std_logic
        );
end core_wrapper;

architecture rtl of core_wrapper is

    constant dmi_addr   : std_ulogic_vector(3 downto 0) := (others => '0');
    constant dmi_din    : std_ulogic_vector(63 downto 0):= (others => '0');
    constant dmi_req    : std_ulogic                    := '0';
    constant dmi_wr     : std_ulogic                    := '0';

    constant irq        : std_ulogic                    := '0';

    signal wishbone_insn_in : wishbone_slave_out;
    signal wishbone_insn_out: wishbone_master_out;

    signal wishbone_data_in : wishbone_slave_out;
    signal wishbone_data_out: wishbone_master_out;

    signal xics_in          : XicsToExecute1Type;
begin

    wishbone_insn_in.dat    <= wb_i_in_dat;
    wishbone_insn_in.ack    <= wb_i_in_ack;
    wishbone_insn_in.stall  <= wb_i_in_stall;

    wb_i_out_adr <= wishbone_insn_out.adr;
    wb_i_out_dat <= wishbone_insn_out.dat;
    wb_i_out_cyc <= wishbone_insn_out.cyc;
    wb_i_out_stb <= wishbone_insn_out.stb;
    wb_i_out_sel <= wishbone_insn_out.sel;
    wb_i_out_we  <= wishbone_insn_out.we;

    wishbone_data_in.dat    <= wb_d_in_dat;
    wishbone_data_in.ack    <= wb_d_in_ack;
    wishbone_data_in.stall  <= wb_d_in_stall;

    wb_d_out_adr <= wishbone_insn_out.adr;
    wb_d_out_dat <= wishbone_insn_out.dat;
    wb_d_out_cyc <= wishbone_insn_out.cyc;
    wb_d_out_stb <= wishbone_insn_out.stb;
    wb_d_out_sel <= wishbone_insn_out.sel;
    wb_d_out_we  <= wishbone_insn_out.we;

    xics_in.irq  <= irq;

    core: entity work.core
        generic map (
            SIM             => true,
	        DISABLE_FLATTEN => false,
            EX1_BYPASS      => true
        )
        port map (
            clk                 => clk,
            rst                 => rst,

            wishbone_insn_in    => wishbone_insn_in,
            wishbone_insn_out   => wishbone_insn_out,

            wishbone_data_in    => wishbone_data_in,
            wishbone_data_out   => wishbone_data_out,

	        dmi_addr	        => dmi_addr,
	        dmi_din	            => dmi_din,
	        dmi_dout	        => open,
	        dmi_req	            => dmi_req,
	        dmi_wr		        => dmi_wr,
	        dmi_ack	            => open,

	        xics_in		        => xics_in,

	        terminated_out      => terminated_out
        );
end rtl;
