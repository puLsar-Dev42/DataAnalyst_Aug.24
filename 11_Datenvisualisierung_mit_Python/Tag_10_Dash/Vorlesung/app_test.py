from dash import Dash, html

# I. app object, instance
app = Dash(__name__)

# comments...

# II. app layout
app.layout = [
	html.H1("welcome to Dash...🐈‍⬛"),  # MainTitle
	html.Hr(),  # horizontal row (Trennlinie)
	html.Img(src="assets/kurs_logo_480.png", width=100),  # image input
	html.H2("DataCraft CourseLogo")  # SubTitle
]

# III. run server (debug-mode)
if __name__ == "__main__":
	app.run_server(debug=True)
