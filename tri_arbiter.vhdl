library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common.all;
use work.wishbone_types.all;
use work.pmesh_types.all;

entity tri_arbiter is
    port (
        clk                 : in std_ulogic;
        rst                 : in std_ulogic;

        tri_insn_trans_out  : in tri_trans_core_l15;
        tri_insn_trans_in   : out tri_trans_l15_core;
        tri_insn_resp_out   : in tri_resp_core_l15;
        tri_insn_resp_in    : out tri_resp_l15_core;

        tri_data_trans_out  : in tri_trans_core_l15;
        tri_data_trans_in   : out tri_trans_l15_core;
        tri_data_resp_out   : in tri_resp_core_l15;
        tri_data_resp_in    : out tri_resp_l15_core;

        tri_trans_out       : out tri_trans_core_l15;
        tri_trans_in        : in tri_trans_l15_core;
        tri_resp_out        : out tri_resp_core_l15;
        tri_resp_in         : in tri_resp_l15_core
    );
end tri_arbiter;

architecture behave of tri_arbiter is
    signal ongoing_insn_req : std_ulogic;
begin

    tri_insn_trans_in <= tri_trans_in;
    tri_data_trans_in <= tri_trans_in;

    tri_insn_resp_in <= tri_resp_in;
    tri_data_resp_in <= tri_resp_in;

    tri_resp_out.req_ack <= tri_insn_resp_out.req_ack or tri_data_resp_out.req_ack;

    tri_select_output : process(all)
    begin
        if (tri_insn_trans_out.val = '1' and tri_data_trans_out.val = '0') or ongoing_insn_req = '1' then
            tri_trans_out <= tri_insn_trans_out;
        else
            tri_trans_out <= tri_data_trans_out;
        end if;
    end process;

    tri_trans_insn_req : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ongoing_insn_req <= '1';
            else
                if tri_insn_trans_out.val = '1' and tri_data_trans_out.val = '0' and tri_trans_in.ack = '0' then
                    ongoing_insn_req <= '1';
                end if;
                if tri_trans_in.ack = '1' and ongoing_insn_req = '1' then
                    ongoing_insn_req <= '0';
                end if;
            end if;
        end if;
    end process;

end behave;
