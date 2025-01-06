# Ein Kommandozeilen-Programm, mithilfe dessen der Nutzer
# Themen festhalten kann, die er gelernt hat (mit Datum)

from database import create_table, insert_topic, view_entries

welcome_message = 'Willkommen zur Lern-Datenbank!'

menu = '''Bitte wähle eine der folgenden Optionen (1-3):
1. Eintrag hinzufügen
2. Einträge anschauen
3. Programm schließen
'''

print(welcome_message, end='\n\n')

# Erstellt Tabelle, sofern noch nicht vorhanden:
create_table()

# Man hätte auch mit try & except + Casting arbeiten können.

while (user_choice := input(menu)) != '3':
	if user_choice == '1':
		insert_topic()
		print('Eintrag wurde hinzugefügt.')
	elif user_choice == '2':
		print('Das sind die Einträge:\n')
		view_entries()
		print('---------------------------')
	else:
		print('Ungültige Eingabe!')

print('\nDanke für die Nutzung dieser App!')
