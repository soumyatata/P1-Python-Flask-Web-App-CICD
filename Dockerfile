# Step 1: Use an official Python runtime as a parent image
FROM python:3.12-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy the contents from the src directory of the host to the /app directory inside the container
COPY src/ /app/

# Step 4: Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Step 6: Make port 5000 available to the world outside this container
EXPOSE 3000

# Step 7: Define the environment variable for Flask app (pointing to app/app.py)
ENV FLASK_APP=app.py

# Step 8: Run the Flask application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
