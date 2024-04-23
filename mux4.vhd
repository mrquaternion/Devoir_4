library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux4 is
    generic(width: integer);
    port(d0, d1, d2, d3: in STD_LOGIC_VECTOR(width - 1 downto 0);
            s: in STD_LOGIC_VECTOR(1 downto 0);
            y: out STD_LOGIC_VECTOR(width - 1 downto 0));
end mux4;

architecture behave of mux4 is
    component mux2
        generic(width: integer);
        port(d0, d1: in STD_LOGIC_VECTOR(width - 1 downto 0);
                s: in STD_LOGIC;
                y: out STD_LOGIC_VECTOR(width - 1 downto 0));
    end component;

    signal low, high: STD_LOGIC_VECTOR(width - 1 downto 0);

begin
	  lowmux: mux2 generic map(width => width) port map(d0, d1, s(0), low);
	  highmux: mux2 generic map(width => width) port map(d2, d3, s(0), high);
	  finalmux: mux2 generic map(width => width) port map(low, high, s(1), y);
end behave;
    