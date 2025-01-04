import sqlite3
import pandas as pd

# Erstellt eine Datenbank, sofern nicht vorhanden. Stellt sonst einfach Verbindung her:
connection = sqlite3.connect(r'/Users/Admin/Documents/1_augustkurs/08_SQL/databases/lernen.db')

create_table_sql = '''
    CREATE TABLE IF NOT EXISTS gelerntes (
        Datum TIMESTAMP,
        Thema VARCHAR(100)
    );
'''

def create_table():
    with connection:
        connection.execute(create_table_sql)

def insert_topic():
    """Fragt den Nutzer nach einem Eintrag, den er hinzufügen will.
    und fügt diesen dann zur Tabelle gelerntes hinzu.
    """
    pass

def view_entries():
    """Zeigt dem Nutzer alle (alternativ auch die obersten zehn o.Ä.)
    Einträge in der Tabelle gelerntes an.
    """
    pass