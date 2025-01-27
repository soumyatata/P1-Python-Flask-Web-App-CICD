# Step 1: Use an official Python runtime as a parent image
FROM python:3.12-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy the requirements.txt file from the src directory of the host to the /app directory inside the container
COPY src/* . 


# Step 4: Install additional tools like Bandit and Safety
RUN pip install bandit safety 

# Step 5: Make port 5000 available to the world outside this container
EXPOSE 5000

# Step 6: Define the environment variable for Flask app (pointing to app/app.py)
ENV FLASK_APP=app.py

# Step 7: Run the Flask application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
