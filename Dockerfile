# Use the official Ruby image as the base image
FROM ruby:3.1.0

# Install dependencies for building gems and connecting to PostgreSQL
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql postgresql-contrib

# Set the working directory inside the container
WORKDIR /sinatra-test-job-master

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Expose port 4567 to allow external access to the application
EXPOSE 4567

# Create database tables
COPY Rakefile .

# Command to run the Sinatra application
CMD ["ruby", "config/environment.rb", "-o", "0.0.0.0"]
