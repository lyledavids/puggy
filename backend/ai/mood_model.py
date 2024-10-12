import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
import numpy as np

# Define the model
model = Sequential([
    Dense(8, input_shape=(3,), activation='relu'),
    Dense(3, activation='softmax')
])

# Compile the model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Dummy training data (for demonstration purposes)
xs = np.array([
    [50, 50, 50],  # Balanced (Neutral)
    [20, 80, 60],  # Happy
    [80, 20, 40]   # Sad
], dtype=float)

ys = np.array([
    [0, 1, 0],  # Neutral
    [1, 0, 0],  # Happy
    [0, 0, 1]   # Sad
], dtype=float)

# Train the model
model.fit(xs, ys, epochs=100)

# Function to predict mood based on pet stats
def predict_mood(hunger, happiness, energy):
    input_data = np.array([[hunger, happiness, energy]])
    prediction = model.predict(input_data)
    mood_index = np.argmax(prediction)

    # Return mood based on index: 0 - Happy, 1 - Neutral, 2 - Sad
    return mood_index
