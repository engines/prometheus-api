# Simple client to access the Prometheus API

You might ask why I've written this gem. And indeed you would be right to
question this! The main reason is error handling. If you use the high level
interface in the official ruby client and you make a mistake in a query then
you get a big fat nothing. Yup, nowt. This isn't that different from the official
gem but I've used a number of [dry-rb](https://dry-rb.org/) libraries to
generally improve the code and specifically to improve the error handling.


## Usage

This isn't on [Rubgems](https://rubygems.org) yet so you'll have to add it
to your `Gemfile` as a git repo:

```ruby
gem "prometheus-api",   "0.3",   :git => "https://github.com/filterfish/prometheus-api"
```
