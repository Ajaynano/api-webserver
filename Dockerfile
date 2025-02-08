FROM python:3.9-slim

ARG DUMMY_USER
ARG DUMMY_PASSWORD
# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . /app/

# Set environment variables for dummyjson credentials
ENV DUMMY_USER=${DUMMY_USER}
ENV DUMMY_PASSWORD=${DUMMY_PASSWORD}

# Run the application
CMD ["python", "app.py"]