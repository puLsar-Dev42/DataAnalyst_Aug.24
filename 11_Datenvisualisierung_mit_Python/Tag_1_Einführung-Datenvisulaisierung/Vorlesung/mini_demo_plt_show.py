import seaborn as sns
import matplotlib.pyplot as plt

flights = sns.load_dataset('flights')

sns.lineplot(flights, x='year', y='passengers', errorbar=None)

# Ohne plt.show wird uns der Plot nicht angezeigt werden:
plt.show()
