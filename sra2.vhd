library IEEE; use IEEE.STD_LOGIC_1164.all;

entity sra2 is
    port (a: in STD_LOGIC_VECTOR (31 downto 0);
            y: out STD_LOGIC_VECTOR (31 downto 0));
end sra2;

architecture behave of sra2 is
-- if the msb is 1, then when we shift we add 1s to the left
-- if the msb is 0, then when we shift we add 0s to the left
begin
    process(a)
        begin
            if a(31) = '1' then y <= "11" & a(31 downto 2);
            else y <= "00" & a(31 downto 2);
            end if;        
    end process;
end behave;