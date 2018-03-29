# <a href='https://hellostealth.org'><img src='data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgOTIgOTUuNzkiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGcgZmlsbD0iIzAwMGEzOCI+PHBhdGggZD0ibTUuNjMgOTIuMjdhMS42OSAxLjY5IDAgMCAwIDEuNzkgMS4xNWMuODggMCAxLjQ5LS4zOCAxLjQ5LTEuMDggMC0uNTMtLjM0LS43Ny0xLS45NGwtMi4xNy0uNGMtMS42Mi0uMzctMi44NC0xLjIzLTIuODQtMy4xNCAwLTIuMjEgMS44LTMuNjYgNC4yNS0zLjY2IDIuNyAwIDQuMjMgMS41MSA0LjUzIDMuNDVoLTIuODJhMS42NiAxLjY2IDAgMCAwIC0xLjctMS4xYy0uODIgMC0xLjM4LjM3LTEuMzggMXMuMzQuNzguOTIuOWwyLjE2LjUyYzEuODkuNDYgMi45MyAxLjUgMi45MyAzLjI1IDAgMi4zMS0xLjkxIDMuNjMtNC4zMiAzLjYzLTIuNjUgMC00LjQ1LTEuMy00Ljg0LTMuNTJ6Ii8+PHBhdGggZD0ibTE0LjcyIDg0LjM0aDkuNzN2Mi41M2gtMy40NXY4Ljc0aC0yLjg3di04Ljc0aC0zLjQxeiIvPjxwYXRoIGQ9Im0zNS44OCA4NC4zNHYyLjUzaC01LjA2djEuNzZoNC42MnYyLjQ4aC00LjYydjJoNS4wNnYyLjU1aC03Ljg4di0xMS4zMnoiLz48cGF0aCBkPSJtNDYuMTIgODQuMzQgNC4yMSAxMS4yN2gtMi45NGwtLjc5LTIuMTloLTRsLS43OCAyLjE5aC0yLjgybDQuMjEtMTEuMjd6bS0yLjY1IDYuNjZoMi4yN2wtMS4xNC0zLjE4eiIvPjxwYXRoIGQ9Im01My42MiA4NC4zNGgyLjl2OC43Mmg0Ljk1djIuNTVoLTcuODV6Ii8+PHBhdGggZD0ibTYzIDg0LjM0aDkuNzJ2Mi41M2gtMy40djguNzRoLTIuOXYtOC43NGgtMy40MnoiLz48cGF0aCBkPSJtODYuMzMgODQuMzR2MTEuMjdoLTIuOXYtNC40NmgtNC4yN3Y0LjQ2aC0yLjl2LTExLjI3aDIuOXY0LjI3aDQuMjd2LTQuMjd6Ii8+PHBhdGggZD0ibTkyIDQ2LTE0Ljg0LTE0Ljg0LTEuNDgtMS40OC0xMy4zNi0xMy4zNi0xLjQ4LTEuNDgtMTQuODQtMTQuODQtMTQuODQgMTQuODQtMS40OCAxLjQ4LTEzLjM2IDEzLjM2LTEuNDggMS40OC0xNC44NCAxNC44NCAxNi4zMiAxNi4zMiAxNC44NC0xNC44NCAxNC44NCAxNC44NCAxNC44NC0xNC44NCAxNC44NCAxNC44NHptLTMxLjE2LTI4LjE5IDEzLjM1IDEzLjM1LTYuNjcgNi42OC02LjY4IDYuNjgtMTMuMzYtMTMuMzYgNi42OC02LjY4em0tMTQuODQtMTQuODEgMTMuMzYgMTMuMzItNi42OCA2LjY4LTYuNjggNi42OC02LjY4LTYuNjgtNi42OC02LjY4em0tMjguMTkgMjguMTYgMTMuMzUtMTMuMzUgNi42OCA2LjY3IDYuNjggNi42OC0xMy4zNiAxMy4zNi02LjY4LTYuNjh6bS0xLjQ5IDI4LjItMTMuMzItMTMuMzYgMTMuMzItMTMuMzYgNi42OCA2LjY4IDYuNjggNi42OHptMjkuNjggMC0xMy4zNi0xMy4zNiAxMy4zNi0xMy4zNiAxMy4zNiAxMy4zNnptMjMtMjAgNi42OC02LjY4IDEzLjMyIDEzLjMyLTEzLjMyIDEzLjM2LTEzLjM2LTEzLjM2eiIvPjwvZz48L3N2Zz4=' height='100' alt='Stealth Logo' aria-label='hellostealth.org' /></a>

Stealth is a Ruby based framework for creating conversational (voice & chat) bots. It's design is inspired by Ruby on Rails and it even sports an MVC architecture.

## Service Integrations

Stealth is extensible. All service integrations are split out into separate Ruby Gems. Things like analytics and natural language processing ([NLP](https://en.wikipedia.org/wiki/Natural-language_processing)) can be added in as gems as well.

Currently, there are gems for:

### Message Services
* [Facebook Messenger](https://github.org/hellostealth/stealth-facebook)
* [Twilio SMS](https://github.org/hellostealth/stealth-twilio)

### Analytics
* [Mixpanel](https://github.org/hellostealth/stealth-mixpanel)

## Docs

Please check out our docs [here](https://docs.hellostealth.org).

## Thanks

Stealth wouldn't exist without the great work of many other open source projects including:

* [Ruby](https://www.ruby-lang.org/) for creating our favorite programming language;
* [Ruby on Rails](http://rubyonrails.org) for projects like `ActiveRecord` and serving as an inspiration;
* [Thor](http://whatisthor.com) for providing us with CLI tools and generators;
* [Sinatra](http://sinatrarb.com) for providing a fantastic, modular way for handling HTTP requests;
* [Sidekiq](https://sidekiq.org) for the super quick background jobs;
* Anthony Hopkins a.k.a. Dr. Robert Ford.

## License

MIT
