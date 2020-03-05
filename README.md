# YnabConvert

Convert CSV files from online banking to a [format YNAB 4 can consume](https://docs.youneedabudget.com/article/921-formatting-csv-file).

## Installation

    $ gem install ynab_convert

## Usage

```shell
$ ynab_convert -f my_transactions.csv -i example
```

This will process the file `my_transactions.csv` downloaded from Example Bank's
online banking platform, using the `example` processor (see list of available
processors below.)

It will then output the converted file as
`my_transactions_example_bank_20191101-2019-1201_ynab4.csv`. The dates in the
filename match the interval of the transactions found in the original CSV file.
In that case, the earliest transaction recorded happened on 2019-11-01 and the
latest one on 2019-12-01.

## Available processors

`-i` argument | Institution's full name | Institution's website | Remarks
---|---|---|---
`example` | Example Bank | N/A | Reference processor implementation, not a real institution
`revolut` | Revolut Ltd | [revolut.com](https://www.revolut.com/) | The processor isn't aware of currencies. Make sure the statements processed with `revolut` are in the same currency that your YNAB is in
`ubs_chequing` | UBS Switzerland (private banking) | [ubs.ch](https://ubs.ch) | Private chequing and joint accounts
`ubs_credit` | UBS Switzerland (credit cards) | [ubs.ch](https://ubs.ch) | Both MasterCard and Visa

## Contributing

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

Bug reports and pull requests are welcome on GitHub at
https://github.com/coaxial/ynab_convert.

### Enable debug output

Run `ynab_convert` with `YNAB_CONVERT_DEBUG=true`, or use the rake task `spec:debug`. Debug logging goes to STDERR.

### Adding a new financial institution

If there is no processor for your financial institution, you can contribute one
to the project.

There is a commented example processor located at
`lib/ynab_convert/processor/example.rb`. Looking at the other, real-world
processors in that directory can also help.

Be sure to add tests to your processor as well before you make a PR.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

(c) coaxial 2019
