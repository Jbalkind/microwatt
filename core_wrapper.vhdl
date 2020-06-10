library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;
use work.wishbone_types.all;
use work.pmesh_types.all;
use work.core;

entity core_wrapper is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;

        wb_d_in_dat         : in  std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_d_in_ack         : in  std_ulogic;
        wb_d_in_stall       : in  std_ulogic;

        wb_d_out_adr        : out std_ulogic_vector(wishbone_addr_bits-1 downto 0);
        wb_d_out_dat        : out std_ulogic_vector(wishbone_data_bits-1 downto 0);
        wb_d_out_cyc        : out std_ulogic;
        wb_d_out_stb        : out std_ulogic;
        wb_d_out_sel        : out std_ulogic_vector(wishbone_sel_bits-1  downto 0);
        wb_d_out_we         : out std_ulogic;

        mw_l15_val                  : out std_ulogic;
        mw_l15_rqtype               : out std_ulogic_vector(4 downto 0);
        mw_l15_amo_op               : out std_ulogic_vector(3 downto 0);
        mw_l15_nc                   : out std_ulogic;
        mw_l15_size                 : out std_ulogic_vector(2 downto 0);
        mw_l15_threadid             : out std_ulogic;
        mw_l15_prefetch             : out std_ulogic;
        mw_l15_blockstore           : out std_ulogic;
        mw_l15_blockinitstore       : out std_ulogic;
        mw_l15_l1rplway             : out std_ulogic_vector(1 downto 0);
        mw_l15_invalidate_cacheline : out std_ulogic;
        mw_l15_address              : out std_ulogic_vector(39 downto 0);
        mw_l15_csm_data             : out std_ulogic_vector(32 downto 0);
        mw_l15_data                 : out std_ulogic_vector(63 downto 0);
        mw_l15_data_next_entry      : out std_ulogic_vector(63 downto 0);

        l15_mw_ack                  : in  std_ulogic;
        l15_mw_header_ack           : in  std_ulogic;

        l15_mw_val                  : in  std_ulogic;
        l15_mw_returntype           : in  std_ulogic_vector(3 downto 0);
        l15_mw_l2miss               : in  std_ulogic;
        l15_mw_error                : in  std_ulogic_vector(1 downto 0);
        l15_mw_noncacheable         : in  std_ulogic;
        l15_mw_atomic               : in  std_ulogic;
        l15_mw_threadid             : in  std_ulogic;
        l15_mw_prefetch             : in  std_ulogic;
        l15_mw_f4b                  : in  std_ulogic;
        l15_mw_data_0               : in  std_ulogic_vector(63 downto 0);
        l15_mw_data_1               : in  std_ulogic_vector(63 downto 0);
        l15_mw_data_2               : in  std_ulogic_vector(63 downto 0);
        l15_mw_data_3               : in  std_ulogic_vector(63 downto 0);
        l15_mw_inval_icache_all_way : in  std_ulogic;
        l15_mw_inval_dcache_all_way : in  std_ulogic;
        l15_mw_inval_address_15_4   : in  std_ulogic_vector(15 downto 4);
        l15_mw_cross_invalidate     : in  std_ulogic;
        l15_mw_cross_invalidate_way : in  std_ulogic_vector(1 downto 0);
        l15_mw_inval_dcache_inval   : in  std_ulogic;
        l15_mw_inval_icache_inval   : in  std_ulogic;
        l15_mw_inval_way            : in  std_ulogic_vector(1 downto 0);
        l15_mw_blockinitstore       : in  std_ulogic;

        mw_l15_req_ack              : out std_ulogic;

	    terminated_out      : out std_logic
        );
end core_wrapper;

architecture rtl of core_wrapper is

    constant alt_reset  : std_ulogic                    := '0';

    constant dmi_addr   : std_ulogic_vector(3 downto 0) := (others => '0');
    constant dmi_din    : std_ulogic_vector(63 downto 0):= (others => '0');
    constant dmi_req    : std_ulogic                    := '0';
    constant dmi_wr     : std_ulogic                    := '0';

    constant irq        : std_ulogic                    := '0';

    signal wishbone_insn_in : wishbone_slave_out;
    signal wishbone_insn_out: wishbone_master_out;

    signal wishbone_data_in : wishbone_slave_out;
    signal wishbone_data_out: wishbone_master_out;

    signal tri_insn_trans_out   : tri_trans_core_l15;
    signal tri_insn_trans_in    : tri_trans_l15_core;

    signal tri_insn_resp_out    : tri_resp_core_l15;
    signal tri_insn_resp_in     : tri_resp_l15_core;

    signal ext_irq : std_ulogic;

begin

    wishbone_insn_in.dat    <= (others => '0');
    wishbone_insn_in.ack    <= (others => '0');
    wishbone_insn_in.stall  <= (others => '0');

    wishbone_data_in.dat    <= wb_d_in_dat;
    wishbone_data_in.ack    <= wb_d_in_ack;
    wishbone_data_in.stall  <= wb_d_in_stall;

    wb_d_out_adr <= wishbone_insn_out.adr;
    wb_d_out_dat <= wishbone_insn_out.dat;
    wb_d_out_cyc <= wishbone_insn_out.cyc;
    wb_d_out_stb <= wishbone_insn_out.stb;
    wb_d_out_sel <= wishbone_insn_out.sel;
    wb_d_out_we  <= wishbone_insn_out.we;

    mw_l15_val                  <= tri_insn_trans_out.val;
    mw_l15_rqtype               <= tri_rqtype_decode(tri_insn_trans_out.rqtype);
    mw_l15_amo_op               <= tri_amo_op_decode(tri_insn_trans_out.amo_op);
    mw_l15_nc                   <= tri_insn_trans_out.nc;
    mw_l15_size                 <= tri_size_decode(tri_insn_trans_out.size);
    mw_l15_threadid             <= tri_insn_trans_out.threadid;
    mw_l15_prefetch             <= '0';
    mw_l15_blockstore           <= '0';
    mw_l15_blockinitstore       <= '0';
    mw_l15_l1rplway             <= tri_insn_trans_out.l1rplway;
    mw_l15_invalidate_cacheline <= '0';
    mw_l15_address              <= tri_insn_trans_out.addr;
    mw_l15_csm_data             <= (others => '0');
    mw_l15_data                 <= tri_insn_trans_out.data;
    mw_l15_data_next_entry      <= tri_insn_trans_out.data_next;

    tri_insn_trans_in.ack           <= l15_mw_ack;
    tri_insn_trans_in.header_ack    <= l15_mw_header_ack;

    tri_insn_resp_in.val            <= l15_mw_val;
    tri_insn_resp_in.return_type    <= tri_returntype_encode(l15_mw_returntype);
    tri_insn_resp_in.l2miss         <= l15_mw_l2miss;
    tri_insn_resp_in.err            <= l15_mw_error;
    tri_insn_resp_in.nc             <= l15_mw_noncacheable;
    tri_insn_resp_in.atomic         <= l15_mw_atomic;
    tri_insn_resp_in.threadid       <= l15_mw_threadid;
    tri_insn_resp_in.f4b            <= l15_mw_f4b;
    tri_insn_resp_in.data_0         <= l15_mw_data_0;
    tri_insn_resp_in.data_1         <= l15_mw_data_1;
    tri_insn_resp_in.data_2         <= l15_mw_data_2;
    tri_insn_resp_in.data_3         <= l15_mw_data_3;
    tri_insn_resp_in.inval_icache_all_way   <= l15_mw_inval_icache_all_way;
    tri_insn_resp_in.inval_dcache_all_way   <= l15_mw_inval_dcache_all_way;
    tri_insn_resp_in.inval_address_15_4     <= l15_mw_inval_address_15_4;
    tri_insn_resp_in.cross_invalidate       <= l15_mw_cross_invalidate;
    tri_insn_resp_in.cross_invalidate_way   <= l15_mw_cross_invalidate_way;
    tri_insn_resp_in.inval_icache_inval     <= l15_mw_inval_dcache_inval;
    tri_insn_resp_in.inval_dcache_inval     <= l15_mw_inval_icache_inval;
    tri_insn_resp_in.inval_way              <= l15_mw_inval_way;

    mw_l15_req_ack  <= tri_insn_resp_out.req_ack;

    ext_irq      <= irq;

    core: entity work.core
        generic map (
            SIM             => true,
	        DISABLE_FLATTEN => false,
            EX1_BYPASS      => true
        )
        port map (
            clk                 => clk,
            rst                 => rst,

            alt_reset           => alt_reset,

            wishbone_insn_in    => wishbone_insn_in,
            wishbone_insn_out   => wishbone_insn_out,

            wishbone_data_in    => wishbone_data_in,
            wishbone_data_out   => wishbone_data_out,

            tri_insn_trans_out  => tri_insn_trans_out,
            tri_insn_trans_in   => tri_insn_trans_in,

            tri_insn_resp_out   => tri_insn_resp_out,
            tri_insn_resp_in    => tri_insn_resp_in,

	        dmi_addr	        => dmi_addr,
	        dmi_din	            => dmi_din,
	        dmi_dout	        => open,
	        dmi_req	            => dmi_req,
	        dmi_wr		        => dmi_wr,
	        dmi_ack	            => open,

	        ext_irq		        => ext_irq,

	        terminated_out      => terminated_out
        );
end rtl;
