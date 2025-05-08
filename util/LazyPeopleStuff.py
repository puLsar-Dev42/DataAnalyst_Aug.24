# TrainTestSplit
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)

# Mit Hyperparametern spielen.
# Was für ein Ergebnis gibt es, wenn nur 2 nächste Nachbarn die Clusterzugehörigkeit bestimmen?
# %%
knn = KNeighborsClassifier(n_neighbors=2)
knn.fit(X_train, y_train)

y_pred = knn.predict(X_train)

_, (ax1, ax2) = plt.subplots(ncols=2, figsize=(10, 4))

ax1.scatter(X_train[:, 0],
			X_train[:, 1],
			c=y_train,
			cmap='viridis')
ax1.set(title='True Clusters')

ax2.scatter(X_train[:, 0],
			X_train[:, 1],
			c=y_pred,
			cmap='viridis')
ax2.set(title='Predicted Clusters');

# Eigener Gridsearch mit For-Schleife
# Training mit verschiedenen k's und Vergleich der Fehlerraten
error_rates = []

for i in range(1, 31):
	knn = KNeighborsClassifier(n_neighbors=i)
	knn.fit(X_train, y_train)
	error_rate = 1 - knn.score(X_test, y_test)
	error_rates.append(error_rate)
