library IEEE;
use IEEE.std_logic_1164.all;
LIBRARY altera;
USE altera.altera_primitives_components.all;
 
entity reg16 is
   port (Clk_sig: in std_logic;
		Reset: in std_logic;
      D_sig : in std_logic_vector(15 DOWNTO 0);
      Q : out std_logic_vector(15 DOWNTO 0));
      
end reg16;
 
architecture bhv of reg16 is

	
SIGNAL Q_sig: STD_LOGIC_VECTOR(15 DOWNTO 0);

begin
Dff0 : dff port map (d => D_sig(0), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(0));
Dff1 : dff port map (d => D_sig(1), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(1));
Dff2 : dff port map (d => D_sig(2), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(2));
Dff3 : dff port map (d => D_sig(3), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(3));
Dff4 : dff port map (d => D_sig(4), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(4));
Dff5 : dff port map (d => D_sig(5), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(5));
Dff6 : dff port map (d => D_sig(6), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(6));
Dff7 : dff port map (d => D_sig(7), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(7));
Dff8 : dff port map (d => D_sig(8), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(8));
Dff9 : dff port map (d => D_sig(9), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(9));
Dff10 : dff port map (d => D_sig(10), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(10));
Dff11 : dff port map (d => D_sig(11), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(11));
Dff12 : dff port map (d => D_sig(12), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(12));
Dff13 : dff port map (d => D_sig(13), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(13));
Dff14 : dff port map (d => D_sig(14), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(14));
Dff15 : dff port map (d => D_sig(15), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(15));
Q<=Q_sig;

end bhv;