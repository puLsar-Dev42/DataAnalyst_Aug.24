# imports
import pandas as pd
import os


# load data
def load_data():
	current_dir = os.path.dirname(__file__)
	csv_path = os.path.join(current_dir, "..", "src", "cleaned_exoplanet_data.csv")
	# source data
	exo_df = pd.read_csv(csv_path)
	exo_df = exo_df.sort_values(by="discovery_year")
	# copies of dataframe
	meta_df = exo_df.copy()
	# df with earth references
	e_df = exo_df[
		(exo_df["mass_wrt"] == "Earth") & (exo_df["radius_wrt"] == "Earth")].copy()
	# df with jupiter references
	j_df = exo_df[
		(exo_df["mass_wrt"] == "Jupiter") & (exo_df["radius_wrt"] == "Jupiter")].copy()
	
	return meta_df, e_df, j_df
