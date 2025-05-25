# Description

AtlasMaker is web-application for texture atlas generation. 
Authorize and create your own atlases for free. 
You can use three atlas packing algorithms, depending on your needs: inline, bookshelf and skyline. 
Save your works unlimited!

You can find this site on 

# How to run project 

## Prerequisites

- Ruby 3.0.0 or higher
- Rails 8.0.0 or higher
- Node.js 14.0.0 or higher
- Yarn
- Foreman

## Getting Started

1. Install dependencies:

    ```sh
    bundle install
    yarn install
    ```

2. Set up the database:

    ```sh
    rails db:create
    rails db:migrate
    ```

3. Start the application using Foreman:

    ```sh
    foreman start -f Procfile.dev
    ```

