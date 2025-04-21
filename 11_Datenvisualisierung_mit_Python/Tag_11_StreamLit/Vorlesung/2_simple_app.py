import pandas as pd
import plotly.express as px
import streamlit as st


# Dataframe laden:
customers = pd.read_csv('Customers.csv')

# Säulendiagramm generieren:
scores_by_profession = (customers.groupby('Profession')
                        ['Spending Score (1-100)']
                        .mean()
                        .sort_values(ascending=False))

scores_profession_barchart = px.histogram(
    scores_by_profession,
    scores_by_profession.index,
    'Spending Score (1-100)',
)

st.set_page_config(page_title='Kundenanalyse')

st.title('Kundenanalyse-App!')

# Fügt Plotly-Grafik hinzu:
st.plotly_chart(scores_profession_barchart)

# Fügt Dataframe hinzu:
st.dataframe(customers)

# Erstellt einen Knopf:
st.button('Klick mich!', type='primary')