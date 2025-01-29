from flask import Flask

# Create a Flask instance
app = Flask(__name__)

# Define a route for the root URL
@app.route('/')
def hello_world():
    return '''
    <html>
        <head><title>Welcome Page</title></head>
        <body>
            <h1>Welcome to My Page</h1>
            <p>This is my FLASK WEB APP to deploy in AWS through Jenkins pipeline</p>
        </body>
    </html>
    '''
# Run the app
if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0')