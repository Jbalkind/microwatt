library ieee;
use ieee.std_logic_1164.all;

package pmesh_types is
    constant tri_addr_bits : integer := 40;
    constant tri_data_bits : integer := 64;

    subtype tri_addr_type is std_ulogic_vector(tri_addr_bits-1 downto 0);
    subtype tri_data_type is std_ulogic_vector(tri_data_bits-1 downto 0);

    type tri_trans_rqtype is (
        load,
        ifill,
        store,
        amo
    );
--    attribute enum_encoding : string;
--    attribute enum_encoding of tri_trans_rqtype:
--    type is "00000 10000 00001 00110";

    type tri_rqtype_encoding is array(tri_trans_rqtype) of std_ulogic_vector(4 downto 0);
    constant tri_rqtype_decode : tri_rqtype_encoding := (
        load => "00000",
        ifill => "10000",
        store => "00001",
        amo => "00110"
    );

    type tri_trans_amo_op is (
        op_none,
        op_lr,
        op_sc,
        op_swap,
        op_add,
        op_and,
        op_or,
        op_xor,
        op_max,
        op_maxu,
        op_min,
        op_minu,
        op_cas1,
        op_cas2
    );
--    attribute enum_encoding of tri_trans_amo_op:
--    type is "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101";

    type tri_amo_op_encoding is array(tri_trans_amo_op) of std_ulogic_vector(3 downto 0);
    constant tri_amo_op_decode : tri_amo_op_encoding := (
        op_none => "0000",
        op_lr   => "0001",
        op_sc   => "0010",
        op_swap => "0011",
        op_add  => "0100",
        op_and  => "0101",
        op_or   => "0110",
        op_xor  => "0111",
        op_max  => "1000",
        op_maxu => "1001",
        op_min  => "1010",
        op_minu => "1011",
        op_cas1 => "1100",
        op_cas2 => "1101"
    );

    type tri_trans_size is (
        size_0B,
        size_1B,
        size_2B,
        size_4B,
        size_8B,
        size_16B,
        size_32B,
        size_64B
    );
--    attribute enum_encoding of tri_trans_size:
--    type is "000 001 010 011 100 101 110 111";

    type tri_size_encoding is array(tri_trans_size) of std_ulogic_vector(2 downto 0);
    constant tri_size_decode : tri_size_encoding := (
        size_0B  => "000",
        size_1B  => "001",
        size_2B  => "010",
        size_4B  => "011",
        size_8B  => "100",
        size_16B => "101",
        size_32B => "110",
        size_64B => "111"
    );

    type tri_trans_core_l15 is record
        val       : std_ulogic;
        rqtype    : tri_trans_rqtype;
        amo_op    : tri_trans_amo_op;
        addr      : tri_addr_type;
        data      : tri_data_type;
        data_next : tri_data_type;
        nc        : std_ulogic;
        size      : tri_trans_size;
        threadid  : std_ulogic;
        l1rplway  : std_ulogic_vector(1 downto 0);
    end record;

    type tri_trans_l15_core is record
        header_ack : std_ulogic;
        ack        : std_ulogic;
    end record;

    type tri_resp_core_l15 is record
        req_ack    : std_ulogic;
    end record;

    type tri_resp_returntype is (
        load,
        ifill1,
        ifill2,
        inval,
        store_ack,
        interrupt,
        fwd_req,
        fwd_reply,
        atomic_res
    );
--    attribute enum_encoding of tri_resp_returntype:
--    type is "0000 0001 0001 0011 0100 0111 1010 1011 0011";

    type tri_returntype_encoding is array(tri_resp_returntype) of std_ulogic_vector(3 downto 0);
    constant tri_returntype_decode : tri_returntype_encoding := (
        load        => "0000",
        ifill1      => "0001",
        ifill2      => "0001",
        inval       => "0011",
        store_ack   => "0100",
        interrupt   => "0111",
        fwd_req     => "1010",
        fwd_reply   => "1011",
        atomic_res  => "0011"
    );

    function tri_returntype_encode(rtntype : std_ulogic_vector(3 downto 0)) return tri_resp_returntype;

    type tri_resp_l15_core is record
        val         : std_ulogic;
        return_type : tri_resp_returntype;
        l2miss      : std_ulogic;
        err         : std_ulogic_vector(1 downto 0);
        nc          : std_ulogic;
        atomic      : std_ulogic;
        threadid    : std_ulogic;
        f4b         : std_ulogic;
        data_0      : tri_data_type;
        data_1      : tri_data_type;
        data_2      : tri_data_type;
        data_3      : tri_data_type;
        inval_icache_all_way : std_ulogic;
        inval_dcache_all_way : std_ulogic;
        inval_address_15_4   : std_ulogic_vector(15 downto 4);
        cross_invalidate     : std_ulogic;
        cross_invalidate_way : std_ulogic_vector(1 downto 0);
        inval_icache_inval   : std_ulogic;
        inval_dcache_inval   : std_ulogic;
        inval_way            : std_ulogic_vector(1 downto 0);
    end record;
end pmesh_types;

package body pmesh_types is

    function tri_returntype_encode(rtntype : std_ulogic_vector(3 downto 0)) return tri_resp_returntype is
    begin
        case rtntype is
            when "0000" => return load;
            when "0001" => return ifill1;
            when "0011" => return inval;
            when "0100" => return store_ack;
            when "0111" => return interrupt;
            when "1010" => return fwd_req;
            when "1011" => return fwd_reply;
            when "1110" => return atomic_res;
            when others => return load;
        end case;
    end function tri_returntype_encode;

end pmesh_types;
