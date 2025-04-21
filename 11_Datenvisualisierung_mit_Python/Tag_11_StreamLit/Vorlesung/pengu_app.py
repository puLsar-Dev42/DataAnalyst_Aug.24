import pandas as pd
import plotly.express as px
import streamlit as st
import time


st.set_page_config(page_title="Penguin-Analytics")


# Dataframe laden:
@st.cache_data
def load_data():
	time.sleep(5)
	return pd.read_csv("penguins.csv")

penguins = load_data()

# Spalten für x-Achse:
categorical_cols = ["species", "sex", "island"]
# Spalten für y-Achse:
numerical_cols = ["bill_length_mm", "bill_depth_mm",
				  "flipper_length_mm", "body_mass_g"]


st.title("Penguin-Analytics-App!")

# Bündelt verschiedene grafische Elemente zu einem zusammenhängenden Formular
# Nutzerangaben können übergeben und dann per Knopfdruck alle verarbeitet werden
with st.form('analysis_form'):
	col1, col2 = st.columns(2)
	
	# Leitet ein, was in Spalte 1 erscheint:
	with col1:
		# Selectbox erstellt einen Dropdown mit auswählbaren Werten:
		cat_selection = st.selectbox('Welche Kategorie interessiert dich?',
									 categorical_cols)
	with col2:
		# Radio buttons mit anklickbaren Werten:
		target_selection = st.radio('Von was willst du die Mittelwerte sehen?',
									numerical_cols)
	
	# Übermittlungsknopf hinzufügen (ohne Knopf nicht sinnvoll):
	st.form_submit_button('Diagramm erstellen', type='primary')

# Säulendiagramm dynamisch generieren:
scores_by_profession = (penguins.groupby(cat_selection)
						[target_selection]
						.mean()
						.sort_values(ascending=False))

scores_profession_barchart = px.bar(
	scores_by_profession,
	scores_by_profession.index,
	target_selection,
)

st.plotly_chart(scores_profession_barchart)

# Expander, um Dataframe ein- und auszublenden:
with st.expander('Daten anschauen', expanded=False):
	st.dataframe(penguins)
