# Bark and Tweet Weather App
<img width="1707" alt="Screenshot 2024-01-31 at 12 02 42 AM" src="https://github.com/jdalt/bark-and-tweet-weather/assets/2358067/c2197d15-d696-4ff4-9e12-09d442acd7f0">

Welcome to the Bark and Tweet Weather App! This application is built with Ruby on Rails and utilizes several important tools and services such as rspec (testing), rubocop (linting), PostgreSQL (database), and redis (caching). Below you will find all the necessary information to get started with this application.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [Code Linting](#code-linting)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.3.0
- Rails
- PostgreSQL
- Redis
- Bundler

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/jdalt/bark-and-tweet-weather.git
   cd bark-and-tweet-weather
   ```

2. **Get a copy of Master Key**

   Get a copy of the master encryption key from another developer on the project.

3. **Install Dependencies**

   ```bash
   bundle install
   ```

4. **Set Up Database**

   Ensure PostgreSQL is running, then execute:

   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Start Redis Server**

   Ensure Redis is running.

## Configuration

- Configure your database connection settings in `config/database.yml`.
- Additional environment specific settings can be configured in `config/environments/`.

## Running the Application

To run the application on your local server:

```bash
bundle exec rails s
```

The application will be available at `http://localhost:3000`.

## Testing

This application uses RSpec for testing. To run tests, execute:

```bash
bundle exec rspec
```

## Code Linting

RuboCop is used for code linting and formatting. To run RuboCop:

```bash
bundle exec rubocop
```

To auto-correct offenses:

```bash
bundle exec rubocop -A
```
