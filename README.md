##### Prerequisites

The setups steps expect following tools installed on the system.

- Github
- Ruby 3.3.4
- Rails 7.1.3

##### 1. Check out the repository

```bash
git clone https://github.com/Tushar-04/FeeInstallmentApp.git
```

##### 2. Bundle Install

Run the following command

```bash
bundle install
```

##### 3. Create and setup the database

Run the following commands to create and setup the database.

```bash
rails db:migrate
```

##### 4. Start the Rails server

You can start the rails server using the command given below.

```ruby
rails s
```

And now you can visit the site with the URL http://localhost:3000