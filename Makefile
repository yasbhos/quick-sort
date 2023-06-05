all: Hossein_Yasbolaghi_40010443_Project2
Hossein_Yasbolaghi_40010443_Project2: Hossein_Yasbolaghi_40010443_Project2.o asm_io.o
	gcc -m32 -o $@ $+ driver.c

Hossein_Yasbolaghi_40010443_Project2.o: Hossein_Yasbolaghi_40010443_Project2.asm 
	nasm -f elf Hossein_Yasbolaghi_40010443_Project2.asm -o Hossein_Yasbolaghi_40010443_Project2.o

asm_io.o: asm_io.asm 
	nasm -f elf -d ELF_TYPE asm_io.asm -o asm_io.o

clean:
	rm Hossein_Yasbolaghi_40010443_Project2 *.o
