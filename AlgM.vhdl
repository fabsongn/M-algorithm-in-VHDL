library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
ENTITY Algm IS 
	GENERIC(  constant palavra : integer :=13; -- palavra recebida
	constant n : integer := 3; -- numero de saidas
	constant k : integer := 2; -- numero de entradas
	constant p : integer := 2; -- numero de memorias
	constant m : integer := 3; -- os M estados escolhidos 
 	constant modulo : integer := 5; --(palavra/n);
	constant Trelica_a : std_logic_vector(0 to 11):= "000001111110"; --  AA=000, AB=001, AC=111, AD=110
	constant Trelica_b : std_logic_vector(0 to 11):= "101100010011"; --  BA=101, BB=100, BC=010, BD=011
	constant Trelica_c : std_logic_vector(0 to 11):= "110111001000"; --  CA=110, CB=111, CC=001, CD=000
	constant Trelica_d : std_logic_vector(0 to 11):= "011010100101" --  DA=011, DB=010, DC=100, DD=101
	);
	PORT( 
	Palavra_recebida: in std_logic_vector(0 to ((n*(palavra/n))-1)); -- 
	Palavra_corrigida: out std_logic_vector(0 to ((k*(palavra/n))-1))); -- 
	END Algm;
	ARCHITECTURE Logic_M OF Algm IS
		BEGIN
			PROCESS(Palavra_recebida)
			variable comp: integer;
			variable cont: integer;
			variable j: integer;
			type Caminho is array (0 to 3) of std_logic_vector(0 to ((k*(palavra/n))-1)); -- tamanho igual ao da palavra_corrigida
			type Rota is array (0 to 3) of integer;
			variable chegada : rota;
			variable partida : rota;
			variable posicao : integer;
			variable caminho_armazenado : caminho; -- = a1.caminho_armazenado  
	   	variable caminho_salvo : caminho; -- = a0.caminho_armazenado
		   variable menor_salva : Rota; -- = a0.menor_metrica
	   	variable menor_metrica : Rota; -- = a1.menor_metrica
	   	variable soma_acumulada : Rota; -- = a1.soma_acumulada
		   variable metrica_acumulada : Rota;
			variable auxv : Rota;
			variable soma : Rota;
			variable ind : Rota;
			variable aux : integer;
			BEGIN
			caminho_armazenado(0)(0 to 1) := "00";  
		   caminho_armazenado(1)(0 to 1) := "01"; 
		   caminho_armazenado(2)(0 to 1) := "10"; 
 		   caminho_armazenado(3)(0 to 1) := "11"; 
			for i in 0 to 3 loop 
		   caminho_salvo(i) := caminho_armazenado(i); 		end loop; 
         soma_acumulada := ( 0 to 3 => 0);
		   menor_metrica := ( 0 to 3 => 0);
			ind := ( 0 to 3 => 0);
			for i in 0 to 3 loop
		   for h in 0 to n-1 loop 
		   if((trelica_a(((i*n)+h)) xor palavra_recebida(h)) = '1') then
		   soma_acumulada(i) := soma_acumulada(i) + 1; 
		   end if;  
			partida(i):=i;
			end loop; end loop;
			chegada:=(0 to 3 =>0);
			-- logica M
			for i in 0 to 3 loop
			auxv(i):=soma_acumulada(i);
			soma(i):=soma_acumulada(i);
			end loop;
			for i in 0 to 2 loop
				for j in (i+1) to 3 loop
					if (soma(i)<soma(j)) then 
					aux:= soma(i);
					soma(i):=soma(j);
					soma(j):=aux;
					end if;
				end loop;
			end loop;
			cont:=0;
			for i in 0 to 3 loop
				for j in 0 to 3 loop
				if (soma(i) = auxv(j)) then 
					auxv(j):=4;
					ind(cont):=j;
					cont:=cont+1;
					end if;
				end loop;
			end loop;
			for i in 0 to (m-2) loop
				for j in (i+1) to (m-1) loop
				if(ind(i)>ind(j)) then 
					aux:=ind(i);
					ind(i):=ind(j);
					ind(j):=aux;
				end if;
				end loop;
			end loop;
		-- fim da logica M
		if ((palavra/n) /= 1) then 
		for j in 1 to ((palavra/n)-1) loop
		menor_salva:= (0 to 3 =>4);
		for i in 0 to ((2**p)-1) loop
	   for q in 0 to m loop 
		menor_metrica(i) := 0; 
				if (ind(q) = 0) then for 
				h in 0 to (n-1) loop 
					if ((trelica_a(((i*n)+h)) xor palavra_recebida(((j*n)+h))) = '1') then menor_metrica(i) := menor_metrica(i) + 1;  	end if; 	 end loop;
					   if (menor_metrica(i)<menor_salva(i)) then menor_salva(i) := menor_metrica(i);  
							                                                 chegada(i) := q;  		 end if;
					elsif (ind(q) = 1) then for h in 0 to (n-1) loop 	if ((trelica_b(((i*n)+h)) xor palavra_recebida(((j*n)+h)))='1') then menor_metrica(i) := menor_metrica(i) + 1; end if; 	   end loop;
						if ((menor_metrica(i)+soma_acumulada(ind(q)))<(menor_salva(i)+soma_acumulada(chegada(i)))) then menor_salva(i) := menor_metrica(i);
							                                                 chegada(i) := q; 		end if;
					elsif (ind(q) = 2) then for h in 0 to (n-1) loop if ((trelica_c((i*n)+h) xor palavra_recebida(((j*n)+h)))='1') then menor_metrica(i) := menor_metrica(i) + 1; 			end if; 	   end loop;
						if ((menor_metrica(i)+soma_acumulada(ind(q)))<(menor_salva(i)+soma_acumulada(chegada(i)))) then	menor_salva(i) := menor_metrica(i);
							                                                chegada(i) := q; 	end if;
					elsif (ind(q) = 3) then for h in 0 to (n-1) loop	if ((trelica_d((i*n)+h) xor palavra_recebida(((j*n)+h)))='1') then menor_metrica(i) := menor_metrica(i) + 1; 				end if;
					   end loop;
						if ((menor_metrica(i)+soma_acumulada(ind(q)))<(menor_salva(i)+soma_acumulada(chegada(i)))) then	menor_salva(i) := menor_metrica(i);
							                                                chegada(i) := q; 				end if; 	end if; 	end loop;
					metrica_acumulada(i) := soma_acumulada(chegada(i)) + menor_salva(i);
				   caminho_armazenado(i) := caminho_salvo(chegada(i));
					if (partida(i) = 0) then	caminho_armazenado(i)(0 to ((2*j)+1)) := (caminho_armazenado(i)(0 to ((2*j)-1)) & "00");
				elsif (partida(i) = 1) then	caminho_armazenado(i)(0 to ((2*j)+1)) := (caminho_armazenado(i)(0 to ((2*j)-1)) & "01");
				elsif (partida(i) = 2) then	caminho_armazenado(i)(0 to ((2*j)+1)) := (caminho_armazenado(i)(0 to ((2*j)-1)) & "10");
				elsif (partida(i) = 3) then	caminho_armazenado(i)(0 to ((2*j)+1)) := (caminho_armazenado(i)(0 to ((2*j)-1)) & "11"); 	end if; 	end loop;
		-- logica M
			for i in 0 to 3 loop
			auxv(i):=soma_acumulada(i);
			soma(i):=soma_acumulada(i);
			end loop;
			for i in 0 to 2 loop
				for j in (i+1) to 3 loop
					if (soma(i)<soma(j)) then 
					aux:= soma(i);
					soma(i):=soma(j);
					soma(j):=aux;
					end if;
				end loop;
			end loop;
			cont:=0;
			for i in 0 to 3 loop
				for j in 0 to 3 loop
				if (soma(i) = auxv(j)) then 
					auxv(j):=4;
					ind(cont):=j;
					cont:=cont+1;
					end if;
				end loop;
			end loop;
			for i in 0 to (m-2) loop
				for j in (i+1) to (m-1) loop
				if(ind(i)>ind(j)) then 
					aux:=ind(i);
					ind(i):=ind(j);
					ind(j):=aux;
				end if;
				end loop;
			end loop;
		-- fim da logica M
		for i in 0 to ((2**p)-1) loop soma_acumulada(i) := metrica_acumulada(i);
				                            caminho_salvo(i) := caminho_armazenado(i); 	end loop;
			for h in 0 to 3 loop if (h = 0) then posicao := h;
				                                   comp := soma_acumulada(h);
				                   else
			                         if(soma_acumulada(h)<comp) then	comp :=soma_acumulada(h);
						                                                      posicao := h; end if; end if; end loop;
      end loop;
		end if;	
		palavra_corrigida <= caminho_armazenado(posicao);
			END PROCESS;
	END Logic_M;					
