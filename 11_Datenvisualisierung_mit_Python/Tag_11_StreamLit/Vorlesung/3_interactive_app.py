import pandas as pd
import plotly.express as px
import streamlit as st

# Dataframe laden:
customers = pd.read_csv('Customers.csv')

# Spalten für x-Achse:
categorical_cols = ['Gender', 'Profession', 'Work Experience', 'Family Size']
# Spalten für y-Achse:
numerical_cols = ['Annual Income ($)', 'Spending Score (1-100)']

st.set_page_config(page_title='Kundenanalyse')

st.title('Kundenanalyse-App!')

# Selectbox erstellt einen Dropdown mit auswählbaren Werten:
cat_selection = st.selectbox('Welche Kategorie interessiert dich?',
                             categorical_cols)

# Radio buttons mit anklickbaren Werten:
target_selection = st.radio('Von was willst du die Mittelwerte sehen?',
                            numerical_cols)

# Säulendiagramm dynamisch generieren:
scores_by_profession = (customers.groupby(cat_selection)
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
    st.dataframe(customers)