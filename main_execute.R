source('exec_data_mining.R')

# Ejemplo de ejecución para Segovia (todo junto), predicción a 1 día con soporte minimo de 0.3 y secuencias de longitud maxima 5
execute_all("segovia_general_nextday",segovia,days=1,sp=0.5,gap=1,msize=5)