# functions

##################################################################################################


# calculate_mean:
def calculate_mean(data_list: list) -> float:
	return sum(data_list) / len(data_list)


# calc_mean:
def calc_mean(numb: list) -> list:
	c_mean = sum(numb) / len(numb)
	return c_mean


##################################################################################################


# determine_mode imports:
from collections import Counter


# determine_mode:
def determine_mode(data_list: list) -> tuple:
	counter = Counter(data_list)
	most_common = counter.most_common()[0]
	return most_common


##################################################################################################


# permutation:
# Mit for-Schleife Anzahl der Permutationen von zb. 5 Elementen berechnen:

n = 5
result = 1

for num in range(1, n + 1):
	result *= num
	print(result)

print(result)


##################################################################################################


# calc_permu:
def calc_permu():
	n = int(input("Bitte Fakultät: n! eingeben"))
	result = 1
	
	for num in range(1, n + 1):
		result *= num
		print(result)
	
	print(result)

##################################################################################################
