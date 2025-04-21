# Eine Streamlit-App braucht kein App-Objekt, das erledigt der Import von
# streamlit as st für uns:

import streamlit as st

# Setzt den Titel im Tab:
st.set_page_config(page_title='Hello')

# Setzt den Haupttitel der App (wie H1):
st.title('Hello, Streamlit World!')

# Das "Schweizer Taschenmesser" unter den Methoden, kann sehr vieles
# Es können darin Textblöcke, DataFrames, Grafiken von Matplotlib und
# Plotly und vieles mehr genutzt werden.
st.write('Das ist ein Text mit st.write().')
st.write('*Kursiver Text mit write*')
st.write('Eine Formel mit write: $\sum_{i=1}^n x_i$')

# Fügt eine Trennlinie hinzu:
st.divider()

# st.text() hat relativ eingeschränkte Möglichkeiten:
st.text('Das ist ein Text mit st.text().')

# st.markdown() bietet den Spielraum von Markdown:
st.markdown('*Das ist ein kursiver Text mit st.markdown().*')
st.markdown('Eine Formel in Markdown: $\sum_{i=1}^n x_i$')

st.divider()

# Mit st.code() kann man Codeblöcke hinzufügen:
st.code('''import pandas as pd
penguins = pd.read_csv('penguins.csv')
penguins.head()
''')

st.slider('Das ist ein Slider zum Verstellen von Werten:', 0, 100, 10, 10)
st.number_input('Bitte Zahl eingeben:', min_value=0, max_value=10, value=5)

# Man startet die App über das Terminal mit streamlit run dateiname.py
