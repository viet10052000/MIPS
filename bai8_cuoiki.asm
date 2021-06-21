.data
mInput:	.asciiz "Nhap chuoi ky tu: "
hex: 		.byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
array1: 	.space 4		# disk chua du lieu
array2: 	.space 4		# disk chua du lieu
		.align 2			# dua dia chi arrayparity ve dia chi boi cua 4
arrayParity: 	.space 32
stringInput: 	.space 5000		#xau ki tu nhap vao
enter:		.asciiz "\n"
error_length:	.asciiz "Do dai chuoi khong hop le! Nhap lai.\n"
m: 		.asciiz "      Disk 1                 Disk 2               Disk 3\n"
m2: 		.asciiz "----------------       ----------------       ----------------\n"
m3:		.asciiz "|     "
m4:		.asciiz "     |       "
m5: 		.asciiz "[[ "
m6: 		.asciiz "]]       "
comma: 	.asciiz ","
ms: 		.asciiz "Try again?"

.text

main:
		jal	input			# nhap du lieu
		nop
		jal	check_lengthInput	# check du lieu
		nop
		jal	split			# phan tach du lieu vao cac disk
		nop
		
exit:		li 	$v0, 10		# ket thuc chuong trinh
		syscall
#=====================Nhap du lieu dau vào===========================
input:	
		li 	$v0, 4				# nhap ten (chuoi)
		la 	$a0, mInput			# doc message yeu cau nhap
		syscall
	
		li	$v0, 8				# doc chuoi
		la 	$a0, stringInput		# a0 luu chuoi ki tu nhap vao
		li 	$a1, 1000		
		syscall
	
		move $s0, $a0				# s0 chua dia chi chuoi moi nhap
	
		li	$v0, 4
		la 	$a0, m
		syscall
	
		li 	$v0, 4
		la 	$a0, m2
		syscall
		
		jr	$ra

#======================check du lieu dau vào chia het cho 8=======================
check_lengthInput:	
		addi 	$t3, $zero, 0 			# t3 = length
		addi	$t0, $zero, 0 			# t0 = index

count_char: 
		add 	$t1, $s0, $t0 			# t1 = address of string[i]
		lb 	$t2, 0($t1) 			# t2 = string[i]
		nop
		beq 	$t2, 10, check_length 	# t2 = '\n' ket thuc xau
		nop
		addi 	$t3, $t3, 1 			# length++
		addi 	$t0, $t0, 1			# index++
		j 	count_char
		nop
check_length: 
		move 	$t5, $t3
		and 	$t1, $t3, 0x0000000f		# xoa het cac byte cua $t3 ve 0, chi giu lai byte cuoi
		beq 	$t1, 0, nCheck			# byte_cuoi # 0 -> test1
		beq 	$t1, 8, nCheck
		j 	error1
		nop
error1:	
		li 	$v0, 4				# dua ra canh báo n?u input không ?úng
		la 	$a0, error_length
		syscall
		j 	main
		nop
nCheck:
		jr $ra
		nop
#=====================Phan tach block du lieu va in ra man hinh=======================
split:
		jal 	reset
		nop
		jal	splitting
		nop
		la 	$a0, m3			# in "|	"
		jal	print_message
		nop
		jal	print_disk1			# in ra block 4 ky tu trong disk luu du lieu dau tien
		nop
		la 	$a0, m4			# in "		|	"
		jal	print_message
		nop
		la 	$a0, m3			# in "|	"
		jal	print_message
		nop
		jal	print_disk2			# in ra block 4 ky tu trong disk luu du lieu thu hai
		nop
		la 	$a0, m4			# in "		|	"
		jal	print_message
		nop

		jal	print_arrayParity		# in ra du lieu parity
		nop
		la 	$a0, enter
		jal	print_message
		nop
		beq 	$t3, 0, check_exit
		nop

#---------------split2--------------------------
		addi	$s0, $s0, 4
		jal 	reset
		nop
		
		jal	splitting
		nop
		la 	$a0, m3
		jal	print_message
		nop
		jal	print_disk1
		nop
		la 	$a0, m4
		jal	print_message
		nop
		
		jal	print_arrayParity
		nop
		la 	$a0, m3
		jal	print_message
		nop
		jal	print_disk2
		nop
		la 	$a0, m4
		jal	print_message
		nop
		la 	$a0, enter
		jal	print_message
		nop
		beq 	$t3, 0, check_exit
		nop
#---------------split3--------------------------
		addi	$s0, $s0, 4
		jal 	reset
		nop
		
		jal	splitting
		nop

		jal	print_arrayParity
		nop

		la 	$a0, m3
		jal	print_message
		nop
		jal	print_disk1
		nop
		la 	$a0, m4
		jal	print_message
		nop
		
		la 	$a0, m3
		jal	print_message
		nop
		jal	print_disk2
		nop
		la 	$a0, m4
		jal	print_message
		nop
		la 	$a0, enter
		jal	print_message
		nop
		
		beq 	$t3, 0, check_exit
		nop
		addi 	$s0, $s0, 4
		j split
		nop

#=========================D?ch bit L?y mã Parity==============================
HEX:		li 	$t4, 1				
loopH:	
		sll 	$s6, $t4, 2			# s6 = t4*4 vd: ... 0000 0011 = 3 -> ... 0000 1100 =12
		srlv 	$a0, $t8, $s6			# a0 = t8>>s6: vd: s6 =4 & t8: 0x00000021 => a0 = 0x00000002
		andi 	$a0, $a0, 0x0000000f 		# a0 = a0 & ... 0000 1111 => lay byte cuoi cung cua a0
		la 	$t7, hex 			# doc dia chi mang hex vao t7
		add 	$t7, $t7, $a0 			# cong gia tri a0 vs t7 de dua ra dung ki tu theo gia tri a0

		lb	$a0, 0($t7) 			# print hex[a0]
		li 	$v0, 11			# print character
		syscall
		addi 	$t4, $t4, -1			# t4--
		bgez	$t4, loopH			# neu t4>=0 thi tiêp tuc 

		jr $ra
		nop
#=======================================================================
reset:	
		addi 	$t0, $zero,0			# t0: index
		la 	$s1, array1			# disk1,2 luu du lieu
		la 	$s2, array2
		la	$a2, arrayParity		# luu du lieu parity
		jr	$ra
		nop

splitting:	
		lb 	$t1, ($s0)		# t1 = input[0]...			
		addi 	$t3, $t3, -1		# length: t3 = t3-1
		sb 	$t1, ($s1)		# luu input[0] -> disk1[0]
	
		addi 	$s5, $s0, 4		# s5 = input[4]
		lb 	$t2, ($s5)		# t2 chua dia chi tung byte cua dick 2
		addi 	$t3, $t3, -1		# length--
		sb 	$t2, ($s2)		# luu input[4] -> disk2[0]
	
		xor 	$a3, $t1, $t2		# xor disk1[0] vs disk2[0]-> a3
		sw 	$a3, ($a2)		# a3-> array (disk3)
		addi 	$a2, $a2, 4		# array[++]
		addi 	$t0, $t0, 1		# numEle in disk ++
		addi 	$s0, $s0, 1		# input++
		addi 	$s1, $s1, 1		# disk1++
		addi 	$s2, $s2, 1		# disk2++
		bgt 	$t0, 3, reset		# neu so phan tu trong disk ==4 -> reset disk
		j splitting
		nop

print_disk1:
		lb 	$a0, ($s1)		# print disk1[++] 
		li 	$v0, 11
		syscall
		addi $t0, $t0, 1		# index++
		addi $s1, $s1, 1		# disk1++
		bgt 	$t0, 3, nprint		# neu so phan tu in ra >4 thi ket thuc print
		j 	print_disk1
	
print_disk2:
		lb 	$a0, ($s2)		# tuong tu print disk2
		li 	$v0, 11
		syscall
		addi 	$t0, $t0, 1		# index_disk2++
		addi 	$s2, $s2, 1		# disk2*++
		bgt 	$t0, 3, nprint		# neu so phan tu in ra >4 thi ket thuc print
		j 	print_disk2
		
print_arrayParity:
		addi 	$sp, $sp,-4
		sw	$ra, ($sp)			# luu dia chi de ket thúc print_arrayParity nhay ve vi trí lúc yêu cau gui hàm print_arrayParity
		la 	$a0, m5			# in "[[	"
		jal	print_message
		nop
loopParity:
		lb 	$t8, ($a2)			# t8 = array[i]
		jal 	HEX				# jump -> lay ma parity
		li 	$v0, 4
		la 	$a0, comma			#print " , "
		syscall
		addi 	$t0, $t0, 1			#index++
		addi 	$a2, $a2, 4			#array++
		bgt 	$t0, 2, end_printArray		# in ra 3 parity dau co dau ",", parity cuoi cung k co
		j 	loopParity	
end_printArray:	
		lb 	$t8, ($a2)			#array[3]
		jal	HEX				# jump -> lay ma parity
		li	$v0, 4
		la	$a0, m6			# in "}]	"
		syscall
		addi 	$t0, $zero,0			# tra index ve 0
		lw	$ra, ($sp)			# doc lai dia chi jjump den printArray ban dau
		jr 	$ra
		nop

nprint:
		addi 	$t0, $zero,0			# tra index ve 0
		jr	$ra
		nop
#================Try Again======================
ask:	li 	$v0, 50				# hoi xem tiep tuc chuong trinh hay ko
	la 	$a0, ms					
	syscall
	beq	 $a0, 0, clear				# neu co thi clear tring ve trang thai ban dau
	nop
	j exit						# neu ko thi exit chuong trinh
	nop
# clear: dua string ve trang thai ban dau de thuc hien lai qua trinh
clear:	
	la 	$s0, stringInput
	add 	$s3, $s0, $t5		# s2: dia chi byte cuoi cung duoc su dung trong string
	li 	$t1, 0
goAgain: 
	sb 	$t1, ($s3)		# set byte o dia chi s0 thanh 0
	nop
	addi 	$s0, $s0, 1		# array* ++
	bge 	$s0, $s2, main 	# s0>s2 --> input
	nop
	j 	goAgain
	nop
#=======================Exit=====================
check_exit:	
		li 	$v0, 4			# in ra ---------------	 ---------------		----------------
		la 	$a0, m2
		syscall
		j 	ask			# jump ask

#======================= print các message=======================
print_message:
		li 	$v0, 4
		syscall
		jr	$ra
		nop?
