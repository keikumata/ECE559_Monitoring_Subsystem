library IEEE;
use IEEE.std_logic_1164.all;
LIBRARY altera;
USE altera.altera_primitives_components.all;
 
entity reg32 is
   port (Clk_sig: in std_logic;
		Reset: in std_logic;
      D_sig : in std_logic_vector(31 DOWNTO 0);
      Q : out std_logic_vector(31 DOWNTO 0));
      
end reg32;
 
architecture bhv of reg32 is

	
SIGNAL Q_sig: STD_LOGIC_VECTOR(31 DOWNTO 0);

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
Dff16 : dff port map (d => D_sig(16), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(16));
Dff17 : dff port map (d => D_sig(17), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(17));
Dff18 : dff port map (d => D_sig(18), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(18));
Dff19 : dff port map (d => D_sig(19), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(19));
Dff20 : dff port map (d => D_sig(20), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(20));
Dff21 : dff port map (d => D_sig(21), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(21));
Dff22 : dff port map (d => D_sig(22), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(22));
Dff23 : dff port map (d => D_sig(23), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(23));
Dff24 : dff port map (d => D_sig(24), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(24));
Dff25 : dff port map (d => D_sig(25), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(25));
Dff26 : dff port map (d => D_sig(26), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(26));
Dff27 : dff port map (d => D_sig(27), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(27));
Dff28 : dff port map (d => D_sig(28), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(28));
Dff29 : dff port map (d => D_sig(29), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(29));
Dff30 : dff port map (d => D_sig(30), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(30));
Dff31 : dff port map (d => D_sig(31), prn => '1', clrn => Reset, clk => Clk_sig,q => Q_sig(31));

Q<=Q_sig;

end bhv;