# functions

###################################################################################################


# calculate_mean:
def calculate_mean(data_list: list) -> float:
	return sum(data_list) / len(data_list)


# calc_mean:
def calc_mean(numb: list) -> list:
	c_mean = sum(numb) / len(numb)
	return c_mean


###################################################################################################


# determine_mode imports:
from collections import Counter


# determine_mode:
def determine_mode(data_list: list) -> tuple:
	counter = Counter(data_list)
	most_common = counter.most_common()[0]
	return most_common


###################################################################################################


# permutation:
# Mit for-Schleife Anzahl der Permutationen von zb. 5 Elementen berechnen:

n = 5
result = 1

for num in range(1, n + 1):
	result *= num
	print(result)

print(result)


###################################################################################################


# calc_permu:
def calc_permu():
	n = int(input("Bitte Fakultät: n! eingeben"))
	result = 1
	
	for num in range(1, n + 1):
		result *= num
		print(result)
	
	print(result)


###################################################################################################


# char_counter
def char_counter(text: str, char_u_wanna_count: str) -> Counter:
	"""
	Prints all positions where a specified character appears in a given text,
    followed by the total count of that character.
    Args:
        text (str): The text to be searched.
        char_u_wanna_count (str): The character to search for within the text.
    Returns:
        None: This function only prints the occurrences and the current count but
        does not return any value.
	"""
	count = 0
	print(f"Word you want to get searched: => {text}")
	print(f"Char you want to search & get counted: => {char_u_wanna_count}\n")
	for idx, char in enumerate(text.lower()):
		if char == char_u_wanna_count:
			count += 1
			print(f"{char} on position {idx} => Counter: {count - 1} + 1")
	print(f"\nTotal of counted {char_u_wanna_count}'s: == {count}\n"
		  f"▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬ ▬\n\n")


###################################################################################################


# rename_col_by_user
def rename_cols_by_user(df: pd.DataFrame) -> pd.DataFrame:
	"""
	function:
    Interactively prompts the user to rename columns in a DataFrame.

	This function prints the current column names of the given DataFrame,
	then asks whether the user wants to rename any columns. If confirmed,
	it iterates through each column, prompting the user for a new name.
	The user can enter a new name or skip to leave the column name unchanged.
    Args:
        df (pd.DataFrame): The DataFrame whose columns will be considered for renaming.
    Returns:
        pd.DataFrame: The modified DataFrame with updated column names (if any).
    """
	print("\nCurrent column names:\n")
	for col_name in df.columns:
		print(f" - {col_name}")
	
	rename_question = input("\nYou want to change column names? (y/n):")
	if rename_question.lower() == "y":
		for old_col_name in list(df.columns):
			new_col_name = input(
				f"\nPlease enter new name for {old_col_name}, or click OK button to go to next column .")
			if new_col_name.strip():
				df.rename(columns={old_col_name: new_col_name}, inplace=True)
	return df


##################################################################################################
# ML:


# Vorarbeit:

probs = classifier.predict_proba(X_train)
probs_df = pd.DataFrame(probs, columns=['prob_0', 'prob_1'])

probs


def colorize_prob(probs: tuple) -> str:
	"""
    Nimmt ein Tupel von vorhergesagten Klassenwahrscheinlichkeiten und gibt eine Farbe zurück, die das Konfidenzniveau anzeigt.

    Args:
        probs (tuple): Tupel von Wahrscheinlichkeiten aus classifier.predict_proba(X_Train), das die
                      vorhergesagten Wahrscheinlichkeiten für jede Klasse enthält

    Returns:
        str: Farbe, die das Vorhersage-Konfidenzniveau repräsentiert:
            "green" für maximale Wahrscheinlichkeit >= 0.9 (sehr sicher)
            "yellow" für maximale Wahrscheinlichkeit >= 0.8 (sicher)
            "orange" für maximale Wahrscheinlichkeit >= 0.6 (unsicher)
            "red" für maximale Wahrscheinlichkeit < 0.6 (sehr unsicher)
    """
	max_prob = max(probs)
	if max_prob >= 0.9:
		return "green"
	elif max_prob >= 0.8:
		return "yellow"
	elif max_prob >= 0.6:
		return "orange"
	else:
		return "red"

##################################################################################################
