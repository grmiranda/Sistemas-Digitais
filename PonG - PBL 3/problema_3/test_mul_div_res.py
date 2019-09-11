import sys
from random import randint


def main(test_cases):
    n = 0
    while(n != int(test_cases)):
        a = randint(0, (2**32))
        b = randint(0, (2**32))
        resultMUL = a * b
        resultDIV = a / b
        resultRES = a % b
        print resultRES
        cont = 0
        

        # transforma em binario e corta o sinal
        bin_a = bin(a)
        str_a = str(bin_a)
        str_a_cut = str_a[2:]
        str_a_temp = str_a_cut        
        tamanhoA = 32 - len(str_a_cut)
        while(cont < tamanhoA):
            str_a_cut = "0" + str_a_cut[0:]
            cont += 1
        cont = 0

        bin_b = bin(b)
        str_b = str(bin_b)
        str_b_cut = str_b[2:]
        str_b_temp = str_b_cut
        temp_b_len = len(str_b_cut) 
        tamanhoB = 32 - len(str_b_cut)
        while(cont < tamanhoB):
            str_b_cut = "0" + str_b_cut[0:]
            cont += 1
        cont = 0

        bin_M = bin(resultMUL)
        str_M = str(bin_M)
        str_M_cut = str_M[2:]
        tamanhoM = 32 - len(str_M_cut)
        if((len(str_b_temp)+len(str_b_temp)) < 32):
            
            while(cont < tamanhoM):
                str_M_cut = "0" + str_M_cut[0:]
                cont += 1
        else:
            str_M_cut = str_M_cut [-32:]
            

        cont = 0

        bin_D = bin(resultDIV)
        str_D = str(bin_D)
        str_D_cut = str_D[2:]
        tamanhoD = 32 - len(str_D_cut)
        while(cont < tamanhoD):
            str_D_cut = "0" + str_D_cut[0:]
            cont += 1
        cont = 0    
        
        bin_R = bin(resultRES)
        str_R = str(bin_R)
        str_R_cut = str_R[2:]
        tamanhoR = 32 - len(str_R_cut)
        while(cont < tamanhoR):
            str_R_cut = "0" + str_R_cut[0:]
            cont += 1
        cont = 0

        print "valor de a : ", str_a_cut, " valor de b : ", str_b_cut, " resultado multiplicacao : ", str_M_cut, " resultado divisao : ", str_D_cut, " resultado resto : ", str_R_cut
        
        with open('test_mul.txt', 'a') as the_file:
            the_file.write(str_a_cut+str_b_cut+str_M_cut+"\n")
        
        with open('test_div.txt', 'a') as the_file:
            the_file.write(str_a_cut+str_b_cut+str_D_cut+"\n")

        with open('test_res.txt', 'a') as the_file:
            the_file.write(str_a_cut+str_b_cut+str_R_cut+"\n")    
        n += 1


if __name__ == '__main__':
    if(len(sys.argv) != 2):
        print "please usage: python test_mul_div_res.py test_cases"
    else:
        main(sys.argv[1])
