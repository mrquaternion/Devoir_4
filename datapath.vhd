library IEEE; use IEEE.STD_LOGIC_1164.all; use
IEEE.STD_LOGIC_ARITH.all;

entity datapath is -- MIPS datapath
	port(clk, reset: in STD_LOGIC;
			memtoreg, pcsrc: in STD_LOGIC;
			alusrc: in STD_LOGIC;
			regdst: in STD_LOGIC_VECTOR(1 downto 0); -- augmente la taille du registre de destination (2 bits)
			regwrite, jump: in STD_LOGIC;
			alucontrol: in STD_LOGIC_VECTOR (2 downto 0);
			zero: out STD_LOGIC;
			pc: buffer STD_LOGIC_VECTOR (31 downto 0);
			instr: in STD_LOGIC_VECTOR(31 downto 0);
			aluout, writedata: buffer STD_LOGIC_VECTOR (31 downto 0);
			readdata: in STD_LOGIC_VECTOR(31 downto 0);
			jal, shiftlog: in STD_LOGIC); -- nouveau signal jal pour le saut inconditionnel et un autre pour la logique du shift (sra à 2 bits dans notre cas)
end;

architecture struct of datapath is
	component alu
		port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
				f: in STD_LOGIC_VECTOR (2 downto 0);
				z: out STD_LOGIC;
				y: buffer STD_LOGIC_VECTOR(31 downto 0)); -- puisque c'est le shiftmux qui gère, on enlève?
	end component;
	component regfile
		port(clk: in STD_LOGIC;
				we3: in STD_LOGIC;
				ra1, ra2, wa3: in STD_LOGIC_VECTOR (4 downto 0);
				wd3: in STD_LOGIC_VECTOR (31 downto 0);
				rd1, rd2: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component adder
		port(a, b: in STD_LOGIC_VECTOR (31 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component sl2
		port(a: in STD_LOGIC_VECTOR (31 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	-- on ajoute le composant au datapath
	component sra2
		port(a: in STD_LOGIC_VECTOR (31 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component signext
		port(a: in STD_LOGIC_VECTOR (15 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component flopr generic (width: integer);
		port(clk, reset: in STD_LOGIC;
				d: in STD_LOGIC_VECTOR (width-1 downto 0);
				q: out STD_LOGIC_VECTOR (width-1 downto 0));
	end component;
	component mux2 generic (width: integer);
		port(d0, d1: in STD_LOGIC_VECTOR (width-1 downto 0);
				s: in STD_LOGIC;
				y: out STD_LOGIC_VECTOR (width-1 downto 0));
	end component;
	-- ajouter component mux4
	component mux4 generic(width: integer) ;
		port (d0, d1, d2, d3: in STD_LOGIC_VECTOR(width - 1 downto 0);
				s: in STD_LOGIC_VECTOR (1 downto 0);
				y: out STD_LOGIC_VECTOR (width - 1 downto 0));
	end component;

	signal writereg: STD_LOGIC_VECTOR (4 downto 0);
	signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR (31 downto 0);
	signal signimm, signimmsh: STD_LOGIC_VECTOR (31 downto 0);
	signal srca, srcb, result: STD_LOGIC_VECTOR (31 downto 0);
	-- nouveau signal qui connecte la sortie de linkmux à regfile (wd3)
	signal linkmux_y: STD_LOGIC_VECTOR(31 downto 0);
	-- nouveau signal qui connecte la sortie de shift à shiftmux
	signal sra2out: STD_LOGIC_VECTOR(31 downto 0); 
	-- nouveau signal qui sort de shiftmux et qui devrait entrée dans dmem
	signal shiftmux_y: STD_LOGIC_VECTOR(31 downto 0);
	
begin
-- next PC logic
	pcjump <= pcplus4 (31 downto 28) & instr (25 downto 0) & "00";
	pcreg: flopr generic map(32) port map(clk, reset, pcnext, pc);
	pcadd1: adder port map(pc, X"00000004", pcplus4);
	immsh: sl2 port map(signimm, signimmsh);
	pcadd2: adder port map(pcplus4, signimmsh, pcbranch);
	pcbrmux: mux2 generic map(32) port map(pcplus4, pcbranch, pcsrc, pcnextbr);
	pcmux: mux2 generic map(32) port map(pcnextbr, pcjump, jump, pcnext);
-- register file logic
	rf: regfile port map(clk, regwrite, instr(25 downto 21), instr(20 downto 16), writereg, linkmux_y, srca, writedata); -- register file ne prend plus son wd3 de result mais de la sortie de linkmux
	linkmux: mux2 generic map(32) port map(result, pcplus4, jal, linkmux_y); -- nouveau mux qui prend en entrée la sortie de resmux et pcplus4
	wrmux: mux4 generic map(5) port map(instr(20 downto 16), instr(15 downto 11), "11111", "00000", regdst, writereg); -- passe de mux2 à mux4 et deux nouvelles entrées: 10 = valeur binaire du registre $ra, 11 = dont care "x"
	resmux: mux2 generic map(32) port map(shiftmux_y, readdata, memtoreg, result); -- l'entree provient de notre shiftmux
	se: signext port map(instr(15 downto 0), signimm);
-- ALU logic
	srcbmux: mux2 generic map (32) port map(writedata, signimm, alusrc, srcb);
	mainalu: alu port map(srca, srcb, alucontrol, zero, aluout);
-- After ALU
	shift: sra2 port map(srca, sra2out); -- nouveau composant sra2 pour le shift
	shiftmux: mux2 generic map(32) port map(aluout, sra2out, shiftlog, shiftmux_y); -- nouveau mux qui prend en entrée la sortie de mainalu et sra2out
end;
