library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.vl2vh_common_pack.all;
entity vga_controller_test is 
     port (
        iRST_n :  in std_logic;
        write_CLK :  in std_logic;
        VGA_CLK_in :  in std_logic;
        write_address :  in std_logic_vector( 23  downto 0  );
        data :  in std_logic;
        oBLANK_n :  out std_logic;
        oHS :  out std_logic;
        oVS :  out std_logic;
        b_data :  out std_logic_vector( 3  downto 0  );
        g_data :  out std_logic_vector( 3  downto 0  );
        r_data :  out std_logic_vector( 3  downto 0  )
    );
end entity; 


architecture rtl of vga_controller_test is 
    signal ADDR : unsigned( 18  downto 0  );
    signal bgr_data : std_logic_vector( 23  downto 0  );
    signal VGA_CLK_n : std_logic;
    signal iVGA_CLK : std_logic;
	 signal data_vector: std_logic_vector(0 downto 0);
    signal index : std_logic_vector(0 downto 0);
    signal bgr_data_raw : std_logic_vector( 23  downto 0  );
    signal cBLANK_n : std_logic;
    signal cHS : std_logic;
    signal cVS : std_logic;
    signal rst : std_logic;
    signal Current_X : unsigned( 10  downto 0  );
    signal DLY_RST : std_logic;
    signal mbgr_data : std_logic_vector( 23  downto 0  );
    signal mVGA_B : std_logic_vector( 7  downto 0  );
    signal mVGA_G : std_logic_vector( 7  downto 0  );
    signal mVGA_R : std_logic_vector( 7  downto 0  );
    component Reset_Delay is 
         port (
            iCLK :  in std_logic;
            oRESET :  out std_logic
        );
    end component; 
    component alteraPLL is 
         port (
            refclk :  in std_logic;
            rst :  in std_logic;
            outclk_0 :  out std_logic
        );
    end component; 
    component video_sync_generator is 
         port (
            vga_clk :  in std_logic;
            reset :  in std_logic;
            blank_n :  out std_logic;
            HS :  out std_logic;
            VS :  out std_logic;
            oCurrent_X :  out unsigned( 10  downto 0  )
        );
    end component; 
    component img_data_3 is 
         port (
            wrclock :  in std_logic;
            wraddress :  in std_logic_vector( 18  downto 0  );
            data :  in std_logic_vector(0 downto 0);
            wren :  inout std_logic;
            rdaddress :  inout std_logic_vector( 18  downto 0  );
            rdclock :  inout std_logic;
            q :  inout std_logic_vector(0 downto 0)
        );
    end component; 
    component index_logo_3 is 
         port (
            address :  inout STD_LOGIC_VECTOR (0 DOWNTO 0);
            clock :  inout std_logic;
            q :  inout std_logic_vector( 23  downto 0  )
        );
    end component; 
    begin 
        rst <= (  not iRST_n ) ;
        r0 : Reset_Delay
            port map (
                iCLK => write_CLK,
                oRESET => DLY_RST
                );
        u1 : alteraPLL
            port map (
                outclk_0 => iVGA_CLK,
                refclk => VGA_CLK_in,
                rst => (  not DLY_RST ) 
                );
        LTM_ins : video_sync_generator
            port map (
                HS => cHS,
                VS => cVS,
                blank_n => cBLANK_n,
                oCurrent_X => Current_X,
                reset => rst,
                vga_clk => iVGA_CLK
                );
        process 
        begin
            wait until ( ( iVGA_CLK'EVENT and ( iVGA_CLK = '1' )  )  ) ;
                if ( ( ( cHS = '0' )  and ( cVS = '0' )  )  ) then 
                    ADDR <= "0000000000000000000" ;
                else 
                    if ( ( cBLANK_n = '1' )  ) then 
                        ADDR <= ( ADDR + 1  ) ;
                    end if;
                end if;
        end process;
        VGA_CLK_n <= (  not iVGA_CLK ) ;
		  data_vector(0) <= data;
        img_data_inst : img_data_3
            port map (
                data => data_vector,
                q => index,
                rdaddress => std_logic_vector(ADDR),
                rdclock => VGA_CLK_n,
                wraddress => write_address(18 DOWNTO 0),
                wrclock => write_CLK,
                wren => '1'
                );
        img_index_inst : index_logo_3
            port map (
                address => index,
                clock => iVGA_CLK,
                q => bgr_data_raw
                );
        process 
        begin
            wait until ( VGA_CLK_n'EVENT and ( VGA_CLK_n = '1' )  ) ;
            bgr_data <= bgr_data_raw;
        end process;
        --mbgr_data <= vl2vh_ternary_func( ( bgr_data = X"ffffff"  ) , X"ffffff" , X"800000"  );
        mVGA_B <= bgr_data(23  downto 16 );
        mVGA_G <= bgr_data(15  downto 8 );
        mVGA_R <= bgr_data(7  downto 0 );
        b_data <= vl2vh_ternary_func( ( Current_X > to_unsigned(0,1)  ) , mVGA_B(7  downto 4 ), std_logic_vector(to_unsigned(0,4))  );
        g_data <= vl2vh_ternary_func( ( Current_X > to_unsigned(0,1)  ) , mVGA_G(7  downto 4 ),  std_logic_vector(to_unsigned(0,4)) );
        r_data <= vl2vh_ternary_func( ( Current_X > to_unsigned(0,1)  ) , mVGA_R(7  downto 4 ),  std_logic_vector(to_unsigned(0,4))  );
        process 
        begin
            wait until ( iVGA_CLK'EVENT and ( iVGA_CLK = '0' )  ) ;
            oHS <= cHS;
            oVS <= cVS;
            oBLANK_n <= cBLANK_n;
        end process;
    end; 


