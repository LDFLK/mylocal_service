FROM python:3.10.9-slim-buster

WORKDIR /mylocal_service

# Install necessary packages and Twisted
RUN apt-get update \
    && apt-get install -y gcc libgl1 libglib2.0-0 \
    && pip install twisted \
    && apt-get clean

# Copy the requirements.txt file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a new user and group
RUN addgroup --gid 10014 choreo && \
    adduser --disabled-password --uid 10014 --ingroup choreo choreouser

# Create a directory for Matplotlib configuration
ENV MPLCONFIGDIR=/mylocal_service/matplotlib_config
RUN mkdir -p $MPLCONFIGDIR && \
    chown -R choreouser:choreo $MPLCONFIGDIR

# Copy application files to the container
COPY mylocal_service.py .
COPY config.py .
COPY application /mylocal_service/application

# Copy the data directory
COPY data ./data

# Copy the startup script and make it executable
COPY start.sh .
RUN chmod +x start.sh

# Set environment variables
ENV LOCAL_DATA_SET=True
ENV ENTS_BASE_URL=http://localhost:8000/mylocal-data
ENV CENSUS_BASE_URL=http://localhost:8000/gig-data
ENV API_HOST=0.0.0.0
ENV API_PORT=9000

# Change ownership of the working directory
RUN chown -R choreouser:choreo /mylocal_service

# Switch to the new user
USER 10014

# Expose ports for your application and the static file server
EXPOSE 9000 8000

# Use ENTRYPOINT to specify the startup script
ENTRYPOINT ["./start.sh"]
