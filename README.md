# api-webserver
# Make sure to create a .env file with env variable which will be needed for the app to run
# we need to install python-dotenv to load the specific .env file 
# how to access the application 
1. we are using Nodeport we can directly access the app with localhost:nodeport/api/products
2. if we use ingress controller we can use localhost:80/api/products