from datetime import datetime
import sqlite3
import pandas as pd

##############
# CONNECTION #
##############

connection = sqlite3.connect(
	r"C:\Users\Admin\OneDrive\Dokumente\DataCraft\DataAnalyst_Aug.24\08_Datenbanken_und_SQL\databases\lernen.db")

################
# CREATE TABLE #
################

# create_table Query:

create_table_sql = '''
    CREATE TABLE IF NOT EXISTS gelerntes (
        Datum TIMESTAMP,
        Thema VARCHAR(100)
    );
'''


#############
# FUNCTIONS #
#############

# fn create_table:

def create_table():
	with connection:
		connection.execute(create_table_sql)


# fn insert_topic:

def insert_topic():
	"""Fragt den Nutzer nach einem Eintrag, den er hinzufügen will.
	und fügt diesen dann zur Tabelle gelerntes hinzu.
	"""
	thema = input(
		"Was hast du gelernt? (bitte Thema eintragen!): \n\n")  # Eingabeaufforderung (Thema)
	datum = datetime.now()  # erstellt Timestamp (Datum)
	with connection:
		connection.execute("INSERT INTO gelerntes (Datum, Thema) VALUES (?, ?)",
						   (datum, thema))  # insertion-Query
		connection.commit()  # commit um die Einträge zu speichern
		print(f"Thema hinzugefügt: {thema} am {datum.strftime('%Y-%m-%d %H:%M:%S')}")


# fn view_entries:

def view_entries():
	"""Zeigt dem Nutzer alle (alternativ auch die obersten zehn o.Ä.)
	Einträge in der Tabelle gelerntes an.
	"""
	with connection:
		cursor = connection.cursor()  # erstellt cursor
		cursor.execute(
			"SELECT * FROM gelerntes ORDER BY Datum DESC")  # cursor selection-Query, lädt cursor auf
		entries = cursor.fetchall()  # alle daten abrufen
	if entries:  # wenn es Einträge gibt...
		for entry in entries:  # für Eintrag in Einträge
			datum, thema = entry  # datum, thema ist der Eintrag
			print(f"{datum}: {thema} \n")
	else:
		print("keine Einträge vorhanden.")
