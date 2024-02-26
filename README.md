### Two-Factor Authentication Service

Two-Factor Authentication Service is a simple sinatra application that is use to authenticate the user using any authenticator application. This README will guide you through setting up the application and adding a new feature to the application.

### Requirements

1. Registration:

Users should be able to create a new account by providing their email and password.
Passwords should be encrypted and stored securely.
After successful registration, a confirmation email should be sent to the provided email address.

2. Login:

  After registration, users should be able to log in by providing their email and password.
  Two-factor authentication should be implemented using one-time codes (e.g., through SMS, authenticator app, or email).
  Users should enter the correct one-time code to successfully log in.

3. Account Settings Management:

  3.1 Users should be able to change their passwords.
  
  3.2 Users should be able to enable or disable two-factor authentication.
  
  3.3 When enabling two-factor authentication, users should be provided with a secret key (e.g., a QR code) to set up their authenticator app.

4. Error Handling and Security:

  4.1 Handle possible errors during registration, login, and account settings management, providing informative error messages.

  4.2 Follow secure practices and standards when storing and handling passwords and secret keys.


### Setup

  1. Clone your repository:

    https://github.com/shaily45/sinatra-test-job.git

  2. Change into the app directory:

    cd sinatra-test-job

  3. Install Ruby 3.1.0 and Bundler if you haven't already installed it:

    gem install bundler

  4. Install the required gems:

    bundle install

  5. Install latest version of docker and docker compose:


  6. Rename .env.example to .env


  7. Replace the values in the .env file with your own values


  8. Start the server (docker will handle db creation and migrations):

    docker-compose up --build` or `docker-compose up

  9. To enter into rake console:

    docker-compose run app bundle exec rake console

  10. For running tests:

    docker-compose run app bundle exec rspec {test_file_name}



### Postman Collection

  To import the Postman collection via the provided link, follow these steps:

  https://api.postman.com/collections/23980975-9be5ec07-cd00-4c54-9888-9dbdb50ade7e?access_key=PMAT-01HNA68NVKKAAVDD7Y7T44V2R2
  
    - Open the Postman application or navigate to the Postman web dashboard.
    - In the top-left corner, click on the "Import" button. Select the "Link" tab.
    - Paste the provided link into the input field.
    - Click on the "Continue" button.
    - Postman will fetch the collection from the link and present you with the import options.
    - Review the import settings and make any necessary adjustments.
    - Click on the "Import" button to complete the process.


### Postman Collection Documentation:
  
  https://documenter.getpostman.com/view/33291951/2sA2rGuyke

  Note: All the API documentation can be found at the link above, except for the QR code that needs to be scanned. When opening the QR code URL, a new request will be generated, and you will need to pass the authenticity token in the request header to open it.