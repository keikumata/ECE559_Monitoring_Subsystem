library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package vl2vh_common_pack is 
    type vl2vh_memory_type is      array  ( natural range <> , natural range <>  )  of std_logic ;
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic; 
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : unsigned;  constant falseval : unsigned)  return unsigned; 
	 function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector; 
	 
end package; 




package body vl2vh_common_pack is 
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic;  constant falseval : std_logic)  return std_logic is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
    function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : unsigned;  constant falseval : unsigned)  return unsigned is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
	 function vl2vh_ternary_func(  constant cond : Boolean;  constant trueval : std_logic_vector;  constant falseval : std_logic_vector)  return std_logic_vector is 
    begin
        if ( cond ) then 
             return trueval;
        else 
             return falseval;
        end if;
    end;
end; 


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.vl2vh_common_pack.all;
entity video_sync_generator is 
generic (
        hori_line : INTEGER := 800 ;
        hori_back : INTEGER := 144 ;
        hori_front : INTEGER := 16 ;
        vert_line : INTEGER := 525 ;
        vert_back : INTEGER := 34 ;
        vert_front : INTEGER := 11 ;
        H_sync_cycle : INTEGER := 96 ;
        V_sync_cycle : INTEGER := 2 ;
        H_BLANK : INTEGER := 112 
    );
     port (
        reset :  in std_logic;
        vga_clk :  in std_logic;
        blank_n :  out std_logic;
        HS :  out std_logic;
        VS :  out std_logic;
        oCurrent_X :  out unsigned( 10  downto 0  )
    );
end entity; 


architecture rtl of video_sync_generator is 
    signal h_cnt : unsigned( 10  downto 0  );
    signal v_cnt : unsigned( 9  downto 0  );
    signal cHD : std_logic;
    signal cVD : std_logic;
    signal cDEN : std_logic;
    signal hori_valid : std_logic;
    signal vert_valid : std_logic;
    begin 
        process 
        begin
            wait until (( vga_clk'EVENT and ( vga_clk = '0' )  )  ) ;
                if ( ( h_cnt = ( hori_line - 1  )  )  ) then 
                    h_cnt <= "00000000000" ;
                    if ( ( v_cnt = ( vert_line - 1  )  )  ) then 
                        v_cnt <= "0000000000" ;
                    else 
                        v_cnt <= ( v_cnt + 1  ) ;
                    end if;
                else 
                    h_cnt <= ( h_cnt + 1  ) ;
                end if;
        end process;
        cHD <= vl2vh_ternary_func( ( h_cnt < H_sync_cycle ) , '0', '1' );
        cVD <= vl2vh_ternary_func( ( v_cnt < V_sync_cycle ) , '0', '1' );
        hori_valid <= vl2vh_ternary_func( ( ( h_cnt < ( hori_line - hori_front )  )  and ( h_cnt >= hori_back )  ) , '1', '0' );
        vert_valid <= vl2vh_ternary_func( ( ( v_cnt < ( vert_line - vert_front )  )  and ( v_cnt >= vert_back )  ) , '1', '0' );
        oCurrent_X <= vl2vh_ternary_func( ( h_cnt >= H_BLANK ) , ( h_cnt - 112 ) , "00000000000"  );
        cDEN <= ( hori_valid and vert_valid ) ;
        process 
        begin
            wait until ( vga_clk'EVENT and ( vga_clk = '0' )  ) ;
            HS <= cHD;
            VS <= cVD;
            blank_n <= cDEN;
        end process;
    end; 


