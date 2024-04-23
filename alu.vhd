library IEEE; use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
	port (a, b: in STD_LOGIC_VECTOR(31 downto 0);
			      f: in STD_LOGIC_VECTOR (2 downto 0); -- Ajouter un bit de sélection
			      z: out STD_LOGIC;
			      y: out STD_LOGIC_VECTOR(31 downto 0):= X"00000000");
end;

architecture behave of alu is
	signal diff, tmp: STD_LOGIC_VECTOR(31 downto 0);
begin

	diff <= a - b;
	
	process (a, b, f, diff, tmp) begin
		case f is
			when "000" => tmp <= a and b; --
			when "001" => tmp <= a or b; --
			when "010" => tmp <= a + b; --
			when "100" => tmp <= a and (not b); --
			when "101" => tmp <= a or (not b); --
			when "110" => tmp <= diff; -- 
			when "111" => tmp <= X"0000000" & "000" & diff(31); -- SLT
			--when "0100" => tmp <= std_logic_vector(shift_right(signed(a), 2)); -- divInt4 
			when others => tmp <= X"FFFFFFFF"; 
		end case;
	end process;
	
	z <= '1' when tmp = X"00000000" else '0';
	
	y <= tmp;
end;